# Create topography 

using Oceananigans
using Oceananigans.Units

@inline function create_topography_functions(sp::NamedTuple)
    
    # Gaussian topography
    @inline hill(x, y) = (sp.h₀)meters * exp((-x^2 - y^2)/ (2(((sp.width)meters)^2)))
    @inline gaussian_bottom(x, y) = - (sp.H)meters + hill(x, y)

    # Return this
    (; gaussian = gaussian_bottom)
end
