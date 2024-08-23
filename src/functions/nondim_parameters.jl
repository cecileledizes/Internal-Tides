default_inputs = (; δ=0.3, E=0.5, β=0.5, B=14, H=3000, Nx=300, Ny=300, Nz=150, T₂=12.421)

@inline function create_simulation_parameters(input_parameters=(; ))
    ip = (; default_inputs..., input_parameters...)
    (; ip...)
end

@inline function create_simulation_parameters(; input_parameters...)
    create_simulation_parameters(input_parameters)
end
