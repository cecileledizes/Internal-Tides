# forcing functions

using Oceananigans
using Oceananigans.Units

include("relaxation_mask.jl")
include("topographies.jl") # Needed for bottom function if mask_2 is used for the Relaxation

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
    mask = create_gaussian_mask(sp)
    damping = Relaxation(; rate = sqrt(sp.Nᵢ²)/(2pi), target = 0, mask = mask)

    # Return this
    (; u_forcing = forcing, damping = damping)
end
