ENV["JULIA_SCRATCH_TRACK_ACCESS"] = 0 

using Oceananigans

include("nonhydrostatic_sim.jl")

# (; stop_time, H, Nx, Ny, Nz, h₀, width, ω₂, Nᵢ², f)
# Matches the arguments in the jobscript with relevant function arguments and simulation parameters
foldername = ARGS[1]
stop_time = Meta.parse(ARGS[2])

H = Meta.parse(ARGS[3])
Nx = Meta.parse(ARGS[4])
Ny = Meta.parse(ARGS[5])
Nz = Meta.parse(ARGS[6])
h₀ = Meta.parse(ARGS[7])
width = Meta.parse(ARGS[8])
ω₂ = Meta.parse(ARGS[9])
Nᵢ² = Meta.parse(ARGS[10])
f = Meta.parse(ARGS[11])

simulation_parameters = (; H, Nx, Ny, Nz, h₀, width, ω₂, Nᵢ², f)

simulation = it_create_simulation(stop_time, foldername, simulation_parameters)
run!(simulation)
