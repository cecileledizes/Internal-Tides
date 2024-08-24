# Creates a NamedTuple of simulation parameters

default_inputs = (; H=3000, Nx=512, Ny=512, Nz=256, h₀=900, width=15558, ω₂=0.00014, Nᵢ²=4e-6, f=0)
# meters, no units, no units, no units, meters, meters, rad/sec, s⁻², rad/sec

@inline function create_simulation_parameters(input_parameters=(; ))
    ip = (; default_inputs..., input_parameters...)
    (; ip...)
end

@inline function create_simulation_parameters(; input_parameters...)
    create_simulation_parameters(input_parameters)
end
