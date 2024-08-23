# variable x, y, z spacing

using Oceananigans
using Oceananigans.Units

@inline function create_spacings(sp::NamedTuple)

    "Vertical spacing functions, creates smaller spacing at z = -H, roughly constant spacing near z = 0.
    Adjust if domain height (H) or grid size (Nz) is changed"
    
    # z_spacing function for 128 horizontal grid points, 1km extent
    function z_spacing_128(y)
        8.8586 * (-exp(-8(y + 1.01)) + 1)
    end

    y_array_128 = LinRange(-1, 0, sp.Nz) # start, stop, num_elements

    # z-spacing array
    B_128 = [z_spacing_128(y) for y in y_array_128]

    # Generating function 
    function z_faces_128(k)
        if k == Nz + 1
            0 
        else
            -(sp.H)meters + sum(B_128[1:k-1])
        end
    end
    
    # z_spacing function for 256 vertical grid points, 3km extent
    function z_spacing_256(y)
        12.1889 * (-exp(-12(y + 1.01)) + 1)
    end

    y_array_256 = LinRange(-1, 1, sp.Nz) # start, stop, num_elements

    # z-spacing array
    B_256 = [z_spacing_256(y) for y in y_array_256]

    # Generating function 
    function z_faces_256(k)
        if k == Nz + 1
            0 
        else
            -(sp.H)meters + sum(B_256[1:k-1])
        end
    end
    
    "horizontal spacing, creates smaller spacing close to the seamount"
    
    spacing = (; z_faces_128 = z_faces_128, z_faces_256 = z_faces_256) 
end
