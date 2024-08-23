# 3D Simulation of Internal Tides using Oceananigans

## Technical details
Tested with Julia v1.10.4, Oceananigans v0.91.2, JLD2 v0.4.48, CUDA v5.3.5, and CairoMakie v0.12.2. This code uses GPU, but can be adapted to CPU by changing 'GPU()' to 'CPU()' in the grid of the simulation, in which case the jobscripts are not necessary. 

## Description
Using Oceananigans, creates a 3D simulation of internal tides with modifiable parameters. In the "src" folder, the "create_NAME_sim.jl" files contain functions which return the appropriate simulation. To run the simulations, run the "run_NAME_sim.jl" files using the corresponding "NAME.sh" scripts in the "jobscripts" folder. Unlike the other files, the jobscripts are written with shell script. There is a version of the simulation using the HydrostaticFreeSurfaceModel, and a version using the Nonhydrostatic Model (barring some necessary modifications due to differences between the models, the two have the same code). Additionally, there is a nondimensional HydrostaticFreeSurfaceModel simulation which has a separate set of nondimensional parameters. 

In the "src" folder, the "functions" subfolder contains functions which produce relevant or potentially relevant forcings, closures, grid spacings, ocean bottom topographies, and simulation parameters. Each function returns a 'NamedTuple'. Can add to or modify this 'NamedTuple' to modify or define more forcings, closures, parameters, etc. 

The analysis folder contains code to produce visualizations of results, including videos of the velocity fields (u', v', w) at y-slices or z-slices, and plots of the energy flux. I have been using a JupyterNotebook for visualization, but they could probably also be run as scripts. 
