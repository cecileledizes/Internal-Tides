# Open time-averaged file
using Oceananigans
using CairoMakie
using JLD2
using Oceananigans.Units
using Printf

filename = "../../[FOLDERNAME]/[AVERAGES_FILENAME].jld2"
file = jldopen(filename)

# Retrieve time-averaged data
uPz = FieldTimeSeries(filename, "u′Pz")
vPz = FieldTimeSeries(filename, "v′Pz")

# Get grid data
Nx = file["grid/underlying_grid/Nx"]
Ny = file["grid/underlying_grid/Ny"]
Lx = file["grid/underlying_grid/Lx"]
Ly = file["grid/underlying_grid/Ly"]

Δy = Ly/Ny

# Plot energy flux with streamlines
f = Figure(size = (600, 600))
Axis(f[1, 1], backgroundcolor = "white", 
    limits = ((Nx/2)-80, (Nx/2)+80, (Ny/2)-80, (Ny/2)+80), 
    xticks = LinRange(-1000, 1000, 100), yticks = [(-80 * Δy)/1000, 0, (80 * Δy)/1000])

period = 7 # change the period to be plotted
step = 4

reduced_uPz = interior(uPz[period], 1:step:Nx, 1:step:Ny, 1) # start:step:stop
reduced_vPz = interior(vPz[period], 1:step:Nx, 1:step:Ny, 1)
xy = LinRange(0, Nx, trunc(Int, Nx/step)) # start stop num_elements

arrows!(xy, xy, reduced_uPz, reduced_vPz, arrowsize = 5, lengthscale = 20)

f
