using Oceananigans
using Oceananigans.Units
using JLD2
using Oceananigans: Fields.FunctionField
using Oceananigans.ImmersedBoundaries: PartialCellBottom

# Files containing supplementary functions
include("functions/parameters.jl")
include("functions/closures.jl")
include("functions/forcings.jl")
include("functions/topographies.jl")

@inline function it_create_simulation(stop_time::Number, foldername, simulation_parameters::NamedTuple) # (simulation stop time, output folder for results, simulation parameters) 
    """Creates a HydrostaticFreeSurfaceModel simulation of an internal tide created by a tidal flow"""
    
    sp = create_simulation_parameters(simulation_parameters)
    hmax = (sp.δ*sp.H)meters
    μ = sqrt((sp.Nᵢ²-sp.ω^2)/(1-sp.β^2))/sp.ω
    width = (μ*hmax/sp.ϵ/sqrt(exp(1)))meters
    bottom = create_gaussian_topography(sp, hmax, width) 
    
    # Grid
    Lmode1 = 2*μ*sp.H                      # Horizontal wavelength of mode-1
    xextend = max(3*Lmode1, 6*sp.width)    # Horizontal extend of the simulation box
    underlying_grid = RectilinearGrid(GPU(); size = (sp.Nx, sp.Ny, sp.Nz),
                                  x = ((-xextend)kilometers,(xextend)kilometers), #xy_spacing,
                                  y = ((-xextend)kilometers,(xextend)kilometers), 
                                  z = ((-sp.H)meters, 0meters), #z_spacing,
                                  halo = (4, 4, 4),
                                  topology = (Periodic, Periodic, Bounded)
    )
    grid = ImmersedBoundaryGrid(underlying_grid, PartialCellBottom(bottom))
    @info grid
    
    # Model
    coriolis = FPlane(f = sp.β*sp.ω)
    T = (2π / sp.ω)seconds
    closures = create_closures(1e-3, 1e-3, grid, sp) # closure functions
    u_forcing = create_tidal_forcing(sp, width) # forcing functions
    sponge = create_sponge_layers(sp, grid)

    model = HydrostaticFreeSurfaceModel(; grid, coriolis,
                                      buoyancy = BuoyancyTracer(),
                                      tracers = :b,
                                      closure = closures.biharmonic,                   
                                      momentum_advection = WENO(),
                                      tracer_advection = WENO(),
                                      forcing=(; u=(u_forcing,sponge.uvw), v=sponge.uvw, w=sponge.uvw, b=sponge.b, p=sponge.p)
    )
    @info model

    @inline uᵢ(x, y, z) = 0
    @inline bᵢ(x, y, z) = sp.Nᵢ² * z # [s⁻²] initial buoyancy frequency / stratification

    set!(model, u=uᵢ, b=bᵢ)

    # Simulation setup
    Δx = 2*xextend/sp.Nx
    Δt = (2*60/3906.25*Δx)seconds # 2 minutes for Δx,y=3906.25, adjust linearly with Δx,y
    simulation = Simulation(model; Δt, stop_time=(stop_time)days)
    
    wizard = TimeStepWizard(cfl=0.2, diffusive_cfl = 0.2, max_Δt = Δt, min_Δt = (Δt/12)seconds) # To ensure simulation stability
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(20))
    
    # Simulation output
    b = model.tracers.b
    u, v, w = model.velocities
    pHY = model.pressure.pHY′

    U = Field(Average(u))
    V = Field(Average(v))

    u′ = u - U
    v′ = v - V 

    N² = ∂z(b)

    # To calculate energy flux 
    pbar = FunctionField{Nothing, Nothing, Center}((z, p)->0.5 * p.N^2 * z^2, grid; parameters=(; N=sqrt(sp.Nᵢ²)))
    P = pHY - pbar
    u′P = Field(u′ * P)
    v′P = Field(v′ * P)
    u′Pz = Field(Integral(u′P, dims = 3))
    v′Pz = Field(Integral(v′P, dims = 3))
    
    timeaverage_schedule = AveragedTimeInterval(T, window = T)
    
    # Output writers
    save_fields_interval = 6hours
    simulation.output_writers[:fields] = JLD2OutputWriter(model, (; u′, u, v′, v, w, P); #u, u′, U, v, v′, V, w, b, P, N²
                     filename = "$foldername/"*"3Dfields_hydro.jld2",
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true,
                     with_halos = true)
    
    save_fields_interval = 30minutes
    simulation.output_writers[:XYslice] = JLD2OutputWriter(model, (; u′, u, v′, v, w, P, b, N²);
                     filename = "$foldername/"*"XYslice_hydro.jld2",
                     indices = (:, :, div(2*sp.Nz,3)),
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true,
                     with_halos = true)

    simulation.output_writers[:YZslice] = JLD2OutputWriter(model, (; u′, u, v′, v, w, P, b, N²);
                     filename = "$foldername/"*"YZslice_hydro.jld2",
                     indices = (div(sp.Nx, 2), :, :),
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true,
                     with_halos = true)

    simulation.output_writers[:XZslice] = JLD2OutputWriter(model, (; u′, u, v′, v, w, P, b, N²);
                     filename = "$foldername/"*"XZslice_hydro.jld2",
                     indices = (:, div(sp.Ny, 2), :),
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true,
                     with_halos = true)

    simulation.output_writers[:averages] = JLD2OutputWriter(model, (; u′Pz, v′Pz);
                     filename = "$foldername/"*"average_hydro.jld2",
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true,
                     with_halos = true)

    @info simulation

    # Function returns the simulation
    simulation
end
