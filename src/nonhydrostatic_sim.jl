using Oceananigans
using Oceananigans.Units
using JLD2
using Oceananigans.ImmersedBoundaries
using Oceananigans: Fields.FunctionField

include("functions/parameters.jl")
include("functions/closures.jl")
include("functions/grid_spacings.jl")
include("functions/forcings.jl")

@inline function it_create_simulation(stop_time, output_folder, simulation_parameters)
    
    sp = create_simulation_parameters(simulation_parameters)
    z_spacing = create_spacings(sp)
    
    # Grid
    underlying_grid = RectilinearGrid(GPU(); size = (sp.Nx, sp.Ny, sp.Nz),
                                  x = ((-1000)kilometers, (1000)kilometers),
                                  y = ((-1000)kilometers, (1000)kilometers),
                                  z = z_spacing.z_faces_256,
                                  halo = (4, 4, 4),
                                  topology = (Periodic, Periodic, Bounded)
    )
    
    @inline hill(x, y) = (sp.h₀)meters * exp((-x^2 - y^2)/ (2(((sp.width)meters)^2)))
    @inline bottom(x, y) = - (sp.H)meters + hill(x, y)
    
    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bottom))
    @info grid
    
    # Tidal forcing
    coriolis = FPlane(latitude = sp.latitude)
    T₂ = (2π / sp.ω₂)seconds
    
    closures = create_closures(1e-3, 1e-3, grid, sp)
    forcings = create_forcings(coriolis.f, sp)
    
    # Model
    model = NonhydrostaticModel(; grid, coriolis,
                                      buoyancy = BuoyancyTracer(),
                                      tracers = :b,
                                      advection = WENO(),
                                      forcing = (; u = (forcings.u_forcing))
    )
    @info model

    @inline uᵢ(x, y, z) = 0
    @inline bᵢ(x, y, z) = sp.Nᵢ² * z # [s⁻²] initial buoyancy frequency / stratification

    set!(model, u=uᵢ, b=bᵢ)

    # Simulation setup
    Δt = 2minutes # 2 minutes for Δx,y=3906.25, adjust linearly with Δx,y
    simulation = Simulation(model; Δt, stop_time=(stop_time)days)
    
    wizard = TimeStepWizard(cfl=0.2, diffusive_cfl = 0.2, max_Δt = Δt, min_Δt = 10seconds)
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(20))
    
    # Output
    b = model.tracers.b
    u, v, w = model.velocities
    pHY = model.pressures.pHY′

    U = Field(Average(u))
    V = Field(Average(v))

    u′ = u - U
    v′ = v - V 

    N² = ∂z(b)
    
    pbar = FunctionField{Nothing, Nothing, Center}((z, p)->0.5 * p.N^2 * z^2, grid; parameters=(; N=sqrt(sp.Nᵢ²)))
    P = pHY - pbar
    u′P = Field(u′ * P)
    v′P = Field(v′ * P)
    u′Pz = Field(Integral(u′P, dims = 3))
    v′Pz = Field(Integral(v′P, dims = 3))
    
    filename_1 = "variable.jld2"
    filename_2 = "variable_average.jld2"
    save_fields_interval = 30minutes
    timeaverage_schedule = AveragedTimeInterval(T₂, window = T₂)
    
    #Output writers
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

    #Call simulation
    simulation
end