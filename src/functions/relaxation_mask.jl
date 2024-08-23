# masking function for relaxation function, used in "forcings", not "base_sim" 

using Oceananigans
using Oceananigans.Units

@inline function create_masks(sp::NamedTuple)

    # Gaussian mask
    bottom_mask = GaussianMask{:z}(center=(-(sp.H)meters + (sp.h₀)meters), width=(sp.h₀)meters)

    # Mask following the edge of the seamount
    @inline function bottom_mask_2(x, y, z)
        if z <= (bottom(x, y) + 10meters)
            1
        else 
            0
        end
    end

    # Exponential mask
    @inline bottom_mask_3(x, y, z) = exp(-(z - (-(sp.H)meters + (sp.h₀)meters)) / (2 * (sp.h₀)meters))

    # return this
    (; mask_1 = bottom_mask, mask_2 = bottom_mask_2, mask_3 = bottom_mask_3)
end
