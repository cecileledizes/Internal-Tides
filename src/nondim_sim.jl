using Oceananigans
using Oceananigans.Units
using JLD2
using Printf
using Oceananigans: Fields.FunctionField

# Supplementary functions
include("functions/nondim_parameters.jl")
include("functions/closures.jl")
include("functions/forcings.jl")
include("functions/grid_spacings.jl")

# This has a different set of parameters than base_sim and nonhydrostatic_sim
@inline function create_nondim_simulation(stop_time::Number, output_folder, simulation_parameters::NamedTuple)
    
    sp = create_simulation_parameters(simulation_parameters)
    
    # Grid
    underlying_grid = RectilinearGrid(GPU(); size = (sp.Nx, sp.Ny, sp.Nz),
                                  x = ((-1000)kilometers, (1000)kilometers),
                                  y = ((-1000)kilometers, (1000)kilometers),
                                  z = (-(sp.H)meters, 0),
                                  halo = (4, 4, 4),
                                  topology = (Periodic, Periodic, Bounded)
    )
    
    h₀ = (sp.δ * sp.H)
    width = sp.width
    # (h₀ * exp(-1/2) / sp.E) * sqrt(((sp.B^2) - 1) / (1 - (sp.β^2))) --width calculated from the slope of the Gaussian
    # @info width --useful for double checking 
    @inline hill(x, y) = (h₀)meters * exp((-x^2 - y^2)/ (2(((width)meters)^2)))
    @inline bottom(x, y) = - (sp.H)meters + hill(x, y)
    
    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bottom))
    @info grid
    
    # Tidal forcing
    T₂ = 2π / sp.ω₂ # sec
    ϵ = 0.1 # excursion parameter
    coriolis = FPlane(f = sp.β * sp.ω₂)
    Nᵢ² = (sp.B * ω₂) ^ 2  # [s⁻²] initial buoyancy frequency / stratification

    U_tidal = ϵ * sp.ω₂ * width
    tidal_forcing_amplitude = U_tidal * (sp.ω₂^2 - coriolis.f^2) / sp.ω₂
    @inline tidal_forcing(x, y, z, t, p) = p.tidal_forcing_amplitude * cos(p.ω₂ * t)
    u_forcing = Forcing(tidal_forcing, parameters=(; tidal_forcing_amplitude, sp.ω₂))
    
    # Model
    model = HydrostaticFreeSurfaceModel(; grid, coriolis,
                                      buoyancy = BuoyancyTracer(),
                                      tracers = :b,
                                      momentum_advection = WENO(),
                                      tracer_advection = WENO(),
                                      forcing = (; u = u_forcing)
    )
    @info model
    
    @inline uᵢ(x, y, z) = 0
    @inline bᵢ(x, y, z) = Nᵢ² * z

    set!(model, u=uᵢ, b=bᵢ)
    
    # Simulation setup
    Δt = 2minutes # 2minutes for 512 horizontal grid points, reduce for higher resolutions
    simulation = Simulation(model; Δt, stop_time=(stop_time)days)

    wall_clock = Ref(time_ns())

    function progress(sim)
        elapsed = 1e-9 * (time_ns() - wall_clock[])

        msg = @sprintf("iteration: %d, time: %s, wall time: %s, max|w|: %6.3e, m s⁻¹\n",
                   iteration(sim), prettytime(sim), prettytime(elapsed),
                   maximum(abs, sim.model.velocities.w))

        wall_clock[] = time_ns()

        @info msg

        return nothing
    end
    
    add_callback!(simulation, progress, name=:progress, IterationInterval(200))
    
    wizard = TimeStepWizard(cfl=0.2, diffusive_cfl = 0.2, max_Δt = Δt)
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(20))

    # Output
    b = model.tracers.b
    u, v, w = model.velocities

    U = Field(Average(u))
    V = Field(Average(v))

    u′ = u - U
    v′ = v - V 

    N² = ∂z(b)
    
    pHY = model.pressure.pHY′
    pbar = FunctionField{Nothing, Nothing, Center}((z, p)->0.5 * p.N^2 * z^2, grid; parameters=(; N=sqrt(Nᵢ²)))
    P = pHY - pbar
    u′P = Field(u′ * P)
    v′P = Field(v′ * P)
    u′Pz = Field(Integral(u′P, dims = 3))
    v′Pz = Field(Integral(v′P, dims = 3))

    filename_1 = "[FILENAME].jld2"
    filename_2 = "[AVERAGES_FILENAME].jld2"
    save_fields_interval = 30minutes
    timeaverage_schedule = AveragedTimeInterval(T₂, window = T₂)
    
    simulation.output_writers[:slices] = JLD2OutputWriter(model, (; u′, v′, w, b);
                     filename = "$foldername/$filename_1",
                     schedule = TimeInterval(save_fields_interval),
                     overwrite_existing = true, 
                     with_halos = true)
    
    simulation.output_writers[:timeaverage] = JLD2OutputWriter(model, (; u′Pz, v′Pz); #u, v, U, V, P, uPz, vPz
                     filename = "$foldername/$filename_2",
                     schedule = timeaverage_schedule,
                     overwrite_existing = true,
                     with_halos = true)

    @info simulation
    simulation
end
