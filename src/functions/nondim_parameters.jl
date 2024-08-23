default_inputs = (; δ=0.3, E=0.5, β=0.5, B=14, H=3000, Nx=512, Ny=512, Nz=256, ω₂=0.00014)
# (; height ratio, relative steepness, frequency ratio (f/ω₂), frequency ratio (N/ω₂), 
     domain height, x grid size, y grid size, z grid size, tidal frequency)

@inline function create_simulation_parameters(input_parameters=(; ))
    ip = (; default_inputs..., input_parameters...)
    (; ip...)
end

@inline function create_simulation_parameters(; input_parameters...)
    create_simulation_parameters(input_parameters)
end
