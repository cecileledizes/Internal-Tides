# Internal-Tides

# 3D Simulation of Internal Tides using Oceananigans for GPU

## Description
Creates a 3D simulation of internal tides with modifiable parameters. Includes functions which produce relevant and potentially relevant forcings, closures, grid spacings, and simulation parameters. There is a version using the HydrostaticFreeSurfaceModel, and a version using the Nonhydrostatic Model (barring some necessary modifications, the two have the same code). Additionally, there is a nondimensional HydrostaticFreeSurfaceModel version which can be initialized with nondimensional parameters. The simulations are written as scripts, which can be run with the bash files in the jobscript folder. The analysis folder contains code to produce visualization of relevant results, including videos of the velocity fields (u', v', w) at y-slices or z-slices, and plots of the energy flux. 

Created and tested with Julia v1.10.4, Oceananigans v0.91.2, JLD2 v0.4.48, CUDA v5.3.5, and CairoMakie v0.12.2. 
