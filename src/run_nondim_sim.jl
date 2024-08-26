ENV["JULIA_SCRATCH_TRACK_ACCESS"] = 0

using Oceananigans

include("nondim_sim.jl")

# (; stop_time, δ=0.3, E=0.5, β=0, B=(0.002/0.00014), H=3000, Nx=512, Ny=512, Nz=256, ω₂=0.00014, width=15558)
# (; stop time, height ratio, relative steepness, frequency (f), frequency (N), domain height, x grid size, y grid size, z grid size, tidal frequency, width)
# (; no units, no units, no units, rad/sec, rad/sec, m, no units, no units, no units, rad/sec, m)
foldername = ARGS[1]

stop_time = Meta.parse(ARGS[2])
δ = Meta.parse(ARGS[3])
E = Meta.parse(ARGS[4])
β = Meta.parse(ARGS[5])
B = Meta.parse(ARGS[6])
H = Meta.parse(ARGS[7])
Nx = Meta.parse(ARGS[8])
Ny = Meta.parse(ARGS[9])
Nz = Meta.parse(ARGS[10])
ω₂ = Meta.parse(ARGS[11])
width = Meta.parse(ARGS[12])

simulation_parameters = (; δ, E, β, B, H, Nx, Ny, Nz, ω₂, width)

simulation = create_nondim_simulation(stop_time, foldername, simulation_parameters)
run!(simulation)
