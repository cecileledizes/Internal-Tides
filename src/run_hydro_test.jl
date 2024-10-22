ENV["JULIA_SCRATCH_TRACK_ACCESS"] = 0

using Oceananigans

include("hydro_test.jl")

# (; height ratio, relative steepness, excursion, frequency ratio (f/ω), x grid size, y grid size, z grid size, 
#  domain height (m), tidal frequency (rad/s), buoyancy gradient (s⁻²))
# Matches the arguments in the jobscript with relevant function arguments and simulation parameters
foldername = ARGS[1]
stop_time = Meta.parse(ARGS[2])
δ = Meta.parse(ARGS[3])
ϵ = Meta.parse(ARGS[4])
α = Meta.parse(ARGS[5])
β = Meta.parse(ARGS[6])
Nx = Meta.parse(ARGS[7])
Ny = Meta.parse(ARGS[8])
Nz = Meta.parse(ARGS[9])
H = Meta.parse(ARGS[10])
ω = Meta.parse(ARGS[11])
Nᵢ² = Meta.parse(ARGS[12])
simulation_parameters = (; δ, ϵ, α, β, Nx, Ny, Nz, H, ω, Nᵢ²)

simulation = it_create_simulation(stop_time, foldername, simulation_parameters)
run!(simulation)

