# 3D Simulation of Internal Tides using Oceananigans

## Technical details
Tested with Julia v1.10.4, Oceananigans v0.91.2, JLD2 v0.4.48, CUDA v5.3.5, and CairoMakie v0.12.2 on the Mist GPU cluster. This code is for GPU, but can be adapted to CPU by changing `GPU()` to `CPU()` in the grid of the simulation, in which case the jobscripts are not necessary. 

```
 # Grid
underlying_grid = RectilinearGrid(GPU(); size = (sp.Nx, sp.Ny, sp.Nz), # Change the GPU() in this line to CPU()
                                  x = ((-1000)kilometers, (1000)kilometers),
                                  y = ((-1000)kilometers, (1000)kilometers),
                                  z = z_spacing.z_faces_256,
                                  halo = (4, 4, 4),
                                  topology = (Periodic, Periodic, Bounded)
)
```

## Description
Using Oceananigans, creates 3D simulations of internal tides with modifiable parameters. 

## Implementation
My file system setup: 
- project 
  - analysis
  - jobscript
  - src
- scratch

If using a different setup, file paths and file names will probably be different, and should be replaced. 

Procedure for getting Julia v1.10.4 installed:
```
$ module load NiaEnv/2022a julia/1.10.4 python
$ python -m venv --system-site-packages /dev/shm/$USER/tempenv
$ source /dev/shm/$USER/tempenv/bin/activate
$ pip install jupyter
$ julia
julia> using Pkg
julia> Pkg.add("IJulia")
julia> exit()
$ deactivate
$ rm -rf /dev/shm/$USER/tempenv
```
Here, commands starting with "$" should be entered at the bash prompt and those starting with "julia>" at the julia prompt.
Note that the temporary virtual python environment is just needed here for getting the "jupyter" command, which the "Pkg.add(...)" julia command calls behind the scenes. Since this environment is temporary, we can use ramdisk to speed up the python installation process.

Procedure for getting Oceananigans and CUDA installed: 
```
# in Mist login node

$ module load julia/1.10.4
$ export JULIA_DEPOT_PATH=$SCRATCH/.julia-mist
$ julia
julia> ]add CUDA@5.3
julia> ]pin CUDA
julia> ]add Oceananigans
julia> using Oceananigans

# in a debugjob, check it works:

$ module load julia/1.10.4
$ export JULIA_DEPOT_PATH=$SCRATCH/.julia-mist
$ export JULIA_SCRATCH_TRACK_ACCESS=0
$ julia
julia> using Oceananigans
```

All scripts need the following:

```
module load julia/1.10.4
export JULIA_DEPOT_PATH=$SCRATCH/.julia-mist
export JULIA_SCRATCH_TRACK_ACCESS=0

julia simulation.jl
```

## Details
In the "src" folder, the `NAME_sim.jl` files contain `it_create_simulation(stop_time, foldername, simulation_parameters)` functions which return the appropriate simulation. The `run_NAME_sim.jl` files convert the arguments listed in the jobscripts to the function arguments, and call the function. In order to run the simulations, run the corresponding `NAME.sh` jobscript in a terminal with the required arguments separated by spaces. If an argument is a non-natural number, it should be in quotation marks (e.g. "0.04" "-45" "4e6"). The jobscripts are written in shell script. 

There are 3 simulations. `base_sim.jl` is the main version, which uses the HydrostaticFreeSurfaceModel. `nonhydrostatic_sim.jl` uses the Nonhydrostatic model. Barring some necessary modifications due to differences between the models, the two have the same code; however, the two models do not produce the same results. Additionally, `nondim_sim.jl` is a HydrostaticFreeSurfaceModel simulation which has a different set of nondimensional parameters.

The "functions" subfolder in "src" contains functions which produce relevant or potentially relevant forcings, closures, grid spacings, ocean bottom topographies, and simulation parameters. These functions are called and used in the `NAME_sim.jl` files. `forcings.jl` contains forcing functions (`relaxation_mask.jl` is used in `forcings.jl` for the damping function), `closures.jl` contains turbulence closure functions, `grid spacing.jl` provides variable grid spacing functions in the vertical and horizontal directions, and `topographies.jl` contains functions describing ocean bottom topography. `parameters.jl` and `nondim_parameters.jl` each return a `NamedTuple` of the simulation parameters specified.  

The analysis folder contains code to produce visualizations of results, including videos of the velocity fields (u', v', w) at x-slices, y-slices, or z-slices, and plots of the energy flux. I've been using a JupyterNotebook for visualization, but they could probably also be run as scripts with some modifications. 

## Credits
Adapted from Oceananigans "Internal Tide by a Seamount" example, modified with help, code, and technical support from Erin Atkinson. 
