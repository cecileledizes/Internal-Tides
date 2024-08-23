# Create topography 

using Oceananigans
using Oceananigans.Units

@inline function create_topography_functions(sp::NamedTuple)
    
    # Gaussian topography
    @inline hill(x, y) = (sp.h₀)meters * exp((-x^2 - y^2)/ (2(((sp.width)meters)^2)))
    @inline gaussian_bottom(x, y) = - (sp.H)meters + hill(x, y)

    # Witch of Agnesi ridge
    @inline ridge(x, y) = (sp.h₀)meters * (1 + (x^2/sp.width^2))^(-1)
    @inline ridge_bottom(x, y) = - (sp.H)meters + ridge(x, y)

    # Return this
    (; gaussian = gaussian_bottom, ridge = ridge_bottom)
end
