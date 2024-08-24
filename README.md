# 3D Simulation of Internal Tides using Oceananigans

## Technical details
Tested with Julia v1.10.4, Oceananigans v0.91.2, JLD2 v0.4.48, CUDA v5.3.5, and CairoMakie v0.12.2. This code is for GPU, but can be adapted to CPU by changing `GPU()` to `CPU()` in the grid of the simulation, in which case the jobscripts are not necessary. 

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

## Details
In the "src" folder, the `NAME_sim.jl` files contain `it_create_simulation(stop_time, foldername, simulation_parameters)` functions which return the appropriate simulation. The `run_NAME_sim.jl` files convert the arguments in the jobscript to the function arguments and call the function. To run the simulations, run the corresponding `NAME.sh` jobscripts in a terminal with the required arguments separated by spaces. The jobscripts are written in shell script, while all other files use Julia. `base_sim.jl` is the main version, which uses the HydrostaticFreeSurfaceModel. `nonhydrostatic_sim.jl` uses the Nonhydrostatic model. Barring some necessary modifications due to differences between the models, the two have the same code—however, the two models do not produce the same results. Additionally, there is a HydrostaticFreeSurfaceModel simulation which has a different set of nondimensional parameters (`nondim_sim.jl`). 

In the "src" folder, the "functions" subfolder contains functions which produce relevant or potentially relevant forcings, closures, grid spacings, ocean bottom topographies, and simulation parameters. These functions are called and used in the `NAME_sim.jl` files. Changing the values of the parameters in `parameters.jl` and `nondim_parameters.jl` can be done in the jobscript. 

The analysis folder contains code to produce visualizations of results, including videos of the velocity fields (u', v', w) at x-slices, y-slices, or z-slices, and plots of the energy flux. I've been using a JupyterNotebook for visualization, but they could probably also be run as scripts. 

## Miscellaneous observations
For some reason, using triple quotation marks to comment after the "create_simulation" functions—
```
@inline function create_simulation(A, B, C)
   simulation stuff
end

"""@inline function create_simulation(A, B, C)
   different simulation stuff
end"""
```
—causes "foldername" to throw an UndefVar error. I have no idea why. 
