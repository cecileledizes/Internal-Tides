# Creates a NamedTuple of simulation parameters

default_inputs = (; δ=0.3, ϵ=0.5, α=0.1, β=0.0, Nx=512, Ny=512, Nz=256, H=3000, ω=0.00014, Nᵢ²=4e-6)
# (; height ratio, relative steepness, excursion, frequency ratio (f/ω₂), x grid size, y grid size, z grid size, 
#  domain height (m), tidal frequency (rad/s), buoyancy gradient (s⁻²))

@inline function create_simulation_parameters(input_parameters=(; ))
    ip = (; default_inputs..., input_parameters...)
    (; ip...)
end

@inline function create_simulation_parameters(; input_parameters...)
    create_simulation_parameters(input_parameters)
end
