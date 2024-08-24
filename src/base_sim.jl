using Oceananigans
using Oceananigans.Units
using JLD2
using Oceananigans.ImmersedBoundaries
using Oceananigans: Fields.FunctionField

# Files containing supplementary functions
include("functions/parameters.jl")
include("functions/closures.jl")
include("functions/grid_spacings.jl")
include("functions/forcings.jl")

@inline function it_create_simulation(stop_time::Number, foldername, simulation_parameters::NamedTuple) # (simulation stop time, output folder for results, simulation parameters) 
    """Creates a HydrostaticFreeSurfaceModel simulation of an internal tide created by a tidal flow"""
    
    # NamedTuples of functions, call specific ones with "[TUPLE_NAME].[FUNCTION_NAME]" format
    sp = create_simulation_parameters(simulation_parameters)
    z_spacing = vertical_spacings_256(sp)
    bottom = create_gaussian_topography(sp) 
    
    # Grid
    underlying_grid = RectilinearGrid(GPU(); size = (sp.Nx, sp.Ny, sp.Nz),
                                  x = ((-1000)kilometers, (1000)kilometers),
                                  y = ((-1000)kilometers, (1000)kilometers),
                                  z = z_spacing,
                                  halo = (4, 4, 4),
                                  topology = (Periodic, Periodic, Bounded)
    )
    
    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bottom))
    @info grid
    
    # Model
    coriolis = FPlane(f = sp.f)
    T₂ = (2π / sp.ω₂)seconds
    closures = create_closures(1e-3, 1e-3, grid, sp) # closure functions
    u_forcing = create_tidal_forcing(sp) # forcing functions

    model = HydrostaticFreeSurfaceModel(; grid, coriolis,
                                      buoyancy = BuoyancyTracer(),
                                      tracers = :b,
                                      momentum_advection = WENO(),
                                      tracer_advection = WENO(),
                                      forcing = (; u = (u_forcing)) 
    )
    @info model

    @inline uᵢ(x, y, z) = 0
    @inline bᵢ(x, y, z) = sp.Nᵢ² * z # [s⁻²] initial buoyancy frequency / stratification

    set!(model, u=uᵢ, b=bᵢ)

    # Simulation setup
    Δt = 2minutes # 2 minutes for Δx,y=3906.25, adjust linearly with Δx,y
    simulation = Simulation(model; Δt, stop_time=(stop_time)days)
    
    wizard = TimeStepWizard(cfl=0.2, diffusive_cfl = 0.2, max_Δt = Δt, min_Δt = 10seconds) # To ensure simulation stability
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
    
    filename_1 = "[FILENAME].jld2"
    filename_2 = "[AVERAGES_FILENAME].jld2"
    save_fields_interval = 30minutes
    timeaverage_schedule = AveragedTimeInterval(T₂, window = T₂)
    
    # Output writers
    simulation.output_writers[:fields] = JLD2OutputWriter(model, (; u′, u, v′, v, w, P); #u, u′, U, v, v′, V, w, b, P, N²
                     filename = "$foldername/$filename_1",
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true,
                     with_halos = true)
    
    simulation.output_writers[:averages] = JLD2OutputWriter(model, (; u′Pz, v′Pz); #u, u′, U, v, v′, V, w, b, P, N²
                     filename = "$foldername/$filename_2",
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true,
                     with_halos = true)

    @info simulation

    # Function returns the simulation
    simulation
end
