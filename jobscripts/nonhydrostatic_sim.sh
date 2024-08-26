#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --time=4:00:00
#SBATCH --job-name=[NAME]
#SBATCH --output=[OUTPUT]
module load julia/1.10.4
export JULIA_DEPOT_PATH=$SCRATCH/.julia-mist
export JULIA_SCRATCH_TRACK_ACCESS=0

cd ~/project

# file to run, (; foldername, stop_time(days), H(m), Nx, Ny, Nz, h₀(m), width(m), ω₂(rad/s), Nᵢ²(s^-2), f)
julia src/run_nonhydrostatic_sim.jl ../scratch 4 3000 512 512 256 900 15558 "0.00014" "4e-6" 0
