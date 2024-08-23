# forcing functions

using Oceananigans
using Oceananigans.Units

include("relaxation_mask.jl")

@inline function create_forcings(f, sp::NamedTuple) # f is the coriolis frequency
    ω₂ = sp.ω₂ # radians/sec
    T₂ = 2π / ω₂ # sec
    ϵ = 0.1 # excursion parameter

    # Tidal forcing function
    U_tidal = ϵ * sp.ω₂ * (sp.width)meters
    tidal_forcing_amplitude = U_tidal * (sp.ω₂^2 - f^2) / sp.ω₂
    @inline tidal_forcing(x, y, z, t, p) = p.tidal_forcing_amplitude * cos(p.ω₂ * t)
    forcing = Forcing(tidal_forcing, parameters=(; tidal_forcing_amplitude, sp.ω₂))

    # Damping function (this doesn't seem to work...)
    masks = create_masks(sp) # (; mask_1, mask_2, mask_3)
    damping = Relaxation(; rate = sqrt(sp.Nᵢ²)/(2pi), target = 0, mask = masks.mask_3)

    # Return this
    (; u_forcing = forcing, damping = damping)
end
