# closure functions

using Oceananigans
using Oceananigans.Units

# default values ν_z_scalar = 1e-3, ν_z_biharmonic = 1e-3
@inline function create_closures(ν_z_scalar::Number, ν_z_biharmonic::Number, grid::ImmersedBoundaryGrid, sp::NamedTuple)
    
    Δx = grid.Lx / sp.Nx 
    Δz = grid.Lz / sp.Nz
    
    scalar_ratio = (Δx / Δz)^2
    biharmonic_ratio = (Δx / Δz)^4
    
    # scalar closure
    horizontal_scalar_closure = HorizontalScalarDiffusivity(; ν=(scalar_ratio * ν_z_scalar), κ=(scalar_ratio * ν_z_scalar))
    vertical_scalar_closure = VerticalScalarDiffusivity(; ν=scalar_ratio, κ=scalar_ratio)
    
    # biharmonic closure
    horizontal_biharmonic_closure = HorizontalScalarBiharmonicDiffusivity(; 
        ν=(biharmonic_ratio * ν_z_biharmonic), κ=(biharmonic_ratio * ν_z_biharmonic))
    vertical_biharmonic_closure = VerticalScalarBiharmonicDiffusivity(; ν=ν_z_biharmonic, κ=ν_z_biharmonic)
    
    # add more closures here if needed
    
    # return this
    (; biharmonic = (horizontal_biharmonic_closure, vertical_biharmonic_closure), 
                scalar = (horizontal_scalar_closure, vertical_scalar_closure))
end
