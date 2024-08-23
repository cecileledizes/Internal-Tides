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
In the "src" folder, the `NAME_sim.jl` files contain functions which return the appropriate simulation. To run the simulations, run the corresponding `NAME.sh` scripts in a terminal. Unlike the other files, the jobscripts are written with shell script. There is a version of the simulation using the HydrostaticFreeSurfaceModel (called `base_sim.jl`), and a version using the Nonhydrostatic Model (`nonhydrostatic_sim.jl`). Barring some necessary modifications due to differences between the models, the two have the same code. Additionally, there is a nondimensional HydrostaticFreeSurfaceModel simulation which has a separate set of nondimensional parameters (`nondim_sim.jl`). 

In the "src" folder, the "functions" subfolder contains functions which produce relevant or potentially relevant forcings, closures, grid spacings, ocean bottom topographies, and simulation parameters to modify the simulations with. Each function returns a `NamedTuple`. Can add to or modify this `NamedTuple` to modify or define more forcings, closures, parameters, etc. As an example, the `forcings.jl` file contains the `create_forcings(f, sp::NamedTuple)` function which returns `forcings = (; u_forcing = forcing, damping = damping)` when called. 

The analysis folder contains code to produce visualizations of results, including videos of the velocity fields (u', v', w) at y-slices or z-slices, and plots of the energy flux. I've been using a JupyterNotebook for visualization, but they could probably also be run as scripts. 
