#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --time=4:00:00
#SBATCH --job-name=nonhydro
#SBATCH --output='output.txt'
module load julia/1.10.4
export JULIA_DEPOT_PATH=$SCRATCH/.julia-mist
export JULIA_SCRATCH_TRACK_ACCESS=0

# COMMENT: file to run, (; foldername, stop_time, δ=0.3, ϵ=0.5, α=0.1, β=0.5, Nx=512, Ny=512, Nz=256, H=3000, ω₂=0.00014, N2=4e-6
julia ~/Internal-Tides/src/run_base_sim.jl . 4 "0.3" "0.5" "0.1" "0.5" 512 512 256 3000 "0.00014" "4e-6"