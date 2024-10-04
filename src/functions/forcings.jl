# forcing functions: create_tidal_forcing, create_relaxation

using Oceananigans
using Oceananigans.Units

include("relaxation_mask.jl")
include("topographies.jl") # Needed for bottom function if mask_2 is used for the Relaxation

@inline function create_tidal_forcing(sp::NamedTuple, width) # f is the coriolis frequency
    # Tidal forcing function
    U_tidal = sp.α * sp.ω * (width)meters
    tidal_forcing_amplitude = U_tidal * (sp.ω^2 - sp.f^2) / sp.ω
    @inline tidal_forcing(x, y, z, t, p) = p.tidal_forcing_amplitude * cos(p.ω * t)
    
    # return this
    forcing = Forcing(tidal_forcing, parameters=(; tidal_forcing_amplitude, sp.ω))
end

@inline function create_sponge_layers(sp::NamedTuple, grid)
    @inline σ₁(x) = abs(x) > 1 ? 1 : 1 - (1-abs(x))^2

    @inline function mask(x, y, z)
        widthX = grid.Lx/6
        widthY = grid.Ly/6
        abs(1 - σ₁((x-grid.Lx/2)/widthX)*σ₁((x+grid.Lx/2)/widthX)) * abs(1 - σ₁((y-grid.Ly/2)/widthY)*σ₁((x+grid.Ly/2)/widthY))
    end
    
    damping_rate = sqrt(sp.Nᵢ²)/(2pi) # Nᵢ is ~frequency of the internal tide, want the rate to be less
    @inline target_buoyancy(x,y,z,t) = sp.Nᵢ²*z
    @inline target_pressure(x,y,z,t) = 0.5*sp.Nᵢ²*z^2
    (;  uvw = Relaxation(; damping_rate, mask=mask, target=(x, y, z, t)->0), 
        b = Relaxation(; damping_rate, mask=mask, target=target_buoyancy),
        p = Relaxation(; damping_rate, mask=mask, target=target_pressure))
end


@inline function create_relaxation(sp::NamedTuple)
    "Damping function (this doesn't seem to work...)"
    mask = create_gaussian_mask(sp) # or any of the other mask options

    # return this
    damping = Relaxation(; rate = sqrt(sp.Nᵢ²)/(2pi), target = 0, mask = mask) # Nᵢ is ~frequency of the internal tide, want the rate to be less
end
