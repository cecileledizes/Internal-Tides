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
        if k == sp.Nz + 1
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
        if k == sp.Nz + 1
            0 
        else
            -(sp.H)meters + sum(B_256[1:k-1])
        end
    end
    
    "horizontal spacing, creates smaller spacing close to the seamount"

    function xy_spacing(x)
        -100*exp(-(x^2)/(2(20000))) + 3900
    end

    half = div(sp.Nx, 2)

    xy_array = LinRange(0, half, half) # start, stop, num_elements

    # xy-spacing array
    B_x = [xy_spacing(x) for xy in xy_array]

    # Generating function 
    function xy_faces(k::Int)
        if k == half
            0 
        elseif k < half
            0 - sum(B[1:trunc(Int, half - (k))])
        elseif half < k <= sp.Nx
            sum(B[1:trunc(Int, k-half)])
        else 
            sum(B[1:trunc(Int, k-(half + 1))]) + B[end]
        end
    end

    # Return this
    (; z_faces_128 = z_faces_128, z_faces_256 = z_faces_256, xy_faces = xy_faces) 
end
