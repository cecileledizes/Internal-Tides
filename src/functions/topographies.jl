# Create topography: create_gaussian_topography, create_ridge_topography 

using Oceananigans
using Oceananigans.Units

@inline function create_gaussian_topography(sp::NamedTuple, hmax, width)
    "Gaussian hill" 
    @inline gaussian_bottom(x, y) = - (sp.H)meters + hmax * exp((-x^2 - y^2)/(2*width^2))

    # return this
    gaussian_bottom
end

@inline function create_ridge_topography(sp::NamedTuple, hmax, width)
    "Witch of Agnesi ridge" 
    @inline ridge_bottom(x, y) = - (sp.H)meters + (hmax)meters * (1 + (x^2/width^2))^(-1)

    # return this
    ridge_bottom
end
