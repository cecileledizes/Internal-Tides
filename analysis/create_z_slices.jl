

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
