# Create topography: create_gaussian_topography, create_ridge_topography 

using Oceananigans
using Oceananigans.Units

@inline function create_gaussian_topography(sp::NamedTuple)
    "Gaussian hill" 
    
    @inline hill(x, y) = (sp.h₀)meters * exp((-x^2 - y^2)/ (2(((sp.width)meters)^2)))
    @inline gaussian_bottom(x, y) = - (sp.H)meters + hill(x, y)

    # return this
    gaussian_bottom
end

@inline function create_ridge_topography(sp::NamedTuple)
    "Witch of Agnesi ridge" 
    
    @inline ridge(x, y) = (sp.h₀)meters * (1 + (x^2/sp.width^2))^(-1)
    @inline ridge_bottom(x, y) = - (sp.H)meters + ridge(x, y)

    # return this
    ridge_bottom
end
