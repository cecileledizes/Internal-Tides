#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --time=4:00:00
#SBATCH --job-name=[NAME]
#SBATCH --output=[OUTPUT]
module load julia/1.10.4
export JULIA_DEPOT_PATH=$SCRATCH/.julia-mist
export JULIA_SCRATCH_TRACK_ACCESS=0

cd ~/[FOLDER_CONTAINING_JULIA]

# COMMENT: file to run, (; foldername, stop_time, δ=0.3, E=0.5, β=0.5, B=14, H=3000, Nx=512, Ny=512, Nz=256, ω₂=0.00014, L=15558)
julia .[/PATH_TO_SRC_FOLDER]/src/run_nondim_sim.jl .[/PATH_TO_OUTPUT_FOLDER]/[OUTPUT_FOLDERNAME] 4 "0.3" "0.5" "0.5" 14 3000 512 512 256 "0.00014" 15558
