# used in "forcings", not "base_sim": create_gaussian_mask, create_mask_2, create_exponential_mask
# these don't actually seem to work 

using Oceananigans
using Oceananigans.Units

@inline function create_gaussian_mask(sp::NamedTuple)
    "Gaussian mask for relaxation function" 
    # return
    bottom_mask = GaussianMask{:z}(center=(-(sp.H)meters + (sp.h₀)meters), width=(sp.h₀)meters)
end

@inline function create_mask_2(bottom::Function)
    "Mask following the edge of the seamount"
    @inline function bottom_mask_2(x, y, z) 
        if z <= (bottom(x, y) + 10meters)
            1
        else 
            0
        end
    end

    # return 
    bottom_mask_2
end

@inline function create_exponential_mask(sp::NamedTuple)
    "Exponential mask" 
    bottom_mask_3(x, y, z) = exp(-(z - (-(sp.H)meters + (sp.h₀)meters)) / (2 * (sp.h₀)meters))

    # return
    bottom_mask_3
end
