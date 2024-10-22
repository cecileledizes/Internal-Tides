# forcing functions: create_tidal_forcing, create_relaxation

using Oceananigans
using Oceananigans.Units

include("relaxation_mask.jl")
include("topographies.jl") # Needed for bottom function if mask_2 is used for the Relaxation

@inline function create_tidal_forcing(sp::NamedTuple, width) # f is the coriolis frequency
    # Tidal forcing function
    U_tidal = sp.α * sp.ω * width
    tidal_forcing_amplitude = U_tidal * (1 - sp.β^2) * sp.ω
    @inline tidal_forcing(x, y, z, t, p) = p.tidal_forcing_amplitude * cos(p.ω * t)
    
    # return this
    forcing = Forcing(tidal_forcing, parameters=(; tidal_forcing_amplitude, sp.ω))
end

@inline function σ₁(x)
    v = ifelse(abs(x) > 1, 1.0, 1.0 - (1.0 - abs(x))^2)
    return v
end


@inline function create_sponge_layers(Nᵢ²,Lx,Ly)
    @inline function mask(x, y, z)
        abs(1 - σ₁((x-Lx/2)/(Lx/6))*σ₁((x+Lx)/(Lx/6))*σ₁((y-Ly/2)/(Ly/6))*σ₁((y+Ly/2)/(Ly/6)))
    end
    
    damping_rate = sqrt(Nᵢ²)/(2pi) # Nᵢ is ~frequency of the internal tide, want the rate to be less
    @inline target_buoyancy(x,y,z,t) = Nᵢ²*z
    (;  uvw = Relaxation(; rate=damping_rate, mask=mask),
        b = Relaxation(; rate=damping_rate, mask=mask, target=target_buoyancy))
end


@inline function create_relaxation(sp::NamedTuple)
    "Damping function (this doesn't seem to work...)"
    mask = create_gaussian_mask(sp) # or any of the other mask options

    # return this
    damping = Relaxation(; rate = sqrt(sp.Nᵢ²)/(2pi), target = 0, mask = mask) # Nᵢ is ~frequency of the internal tide, want the rate to be less
end
