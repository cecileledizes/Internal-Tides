# Opening main file
using Oceananigans
using CairoMakie
using JLD2
using Oceananigans.Units
using Printf

filename = "../../[FOLDERNAME]/[FILENAME].jld2"
file = jldopen(filename)

# Retrieve simulation velocity data, masking immersed field for velocity fields
u′_t = FieldTimeSeries(filename, "u′")
v′_t = FieldTimeSeries(filename, "v′")
w_t = FieldTimeSeries(filename, "w")
times = u′_t.times

# Constants and grid data
Lx = file["grid/underlying_grid/Lx"]
Ly = file["grid/underlying_grid/Ly"]
Lz = file["grid/underlying_grid/Lz"]
Nx = file["grid/underlying_grid/Nx"]
Ny = file["grid/underlying_grid/Ny"]
Nz = file["grid/underlying_grid/Nz"]

ω₂ = 0.00014 # default value, change if value of ω₂ changes
T₂ = 2π / ω₂
coriolis_f = file["coriolis/f"]

# Plotting u′, v′, w (z-slices)
slice_point = trunc(Int, Nz/2) # Alter this for slices at different values of z

umax = maximum(abs, u′_t[end][:, :, slice_point])
vmax = maximum(abs, v′_t[end][:, :, slice_point])
wmax = maximum(abs, w_t[end][:, :, slice_point])

times = u′_t.times

xu,  yu,  zu  = nodes(u′_t[1]) ./ 1e3
xv,  yv,  zv  = nodes(v′_t[1]) ./ 1e3
xw, yw, zw = nodes(w_t[1]) ./ 1e3

n = Observable(1)

title = @lift @sprintf("t = %1.2f days = %1.2f T₂",
                       round(times[$n] / day, digits=2) , round(times[$n] / T₂, digits=2))

u′ₙ = @lift interior(u′_t[$n], :, :, slice_point)
v′ₙ = @lift interior(v′_t[$n], :, :, slice_point)
w = @lift interior(w_t[$n], :, :, slice_point)

axis_kwargs = (xlabel = "x [km]",
               ylabel = "y [km]",
               limits = ((-Lx/2e3, Lx/2e3), (-Ly/2e3, Ly/2e3)), # note conversion to kilometers
               titlesize = 20)

fig = Figure(size = (500, 1100))

fig[1, :] = Label(fig, title, fontsize=24, tellwidth=false)

ax_u = Axis(fig[2, 1]; title = "u′-velocity, z-slices", axis_kwargs...)
hm_u = heatmap!(ax_u, xu, yu, u′ₙ; colorrange = (-umax, umax), colormap = :balance)
Colorbar(fig[2, 2], hm_u, label = "m s⁻¹")

ax_v = Axis(fig[3, 1]; title = "v′-velocity, z-slices", axis_kwargs...)
hm_v = heatmap!(ax_v, xv, yv, v′ₙ; colorrange = (-umax, umax), colormap = :balance)
Colorbar(fig[3, 2], hm_v, label = "m s⁻¹")

ax_w = Axis(fig[4, 1]; title = "w-velocity, z-slices", axis_kwargs...)
hm_w = heatmap!(ax_w, xw, yw, w; colorrange = (-wmax, wmax), colormap = :balance)
Colorbar(fig[4, 2], hm_w, label = "m s⁻¹")

fig

# Animation of u′, v′, w (z-slices)
@info "Making an animation from saved data..."

frames = 1:length(times)

record(fig, filename * ".mp4", frames, framerate=16) do i
    n[] = i
end