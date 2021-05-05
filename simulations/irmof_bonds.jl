using PorousMaterials
using LightGraphs

structure = Crystal("IRMOF-1.cssr")
strip_numbers_from_atom_labels!(structure)

repfactors = (2, 2, 2)

structure = replicate(structure, repfactors)

bonding_rules = [BondingRule(:H, :*, 0.4, 1.2),
                 BondingRule(:Zn, :O, 1.2, 2.5),
                 BondingRule(:*, :*, 0.4, 1.9)]

infer_bonds!(structure, false, bonding_rules)

# write the bond information .vtk
bond_file_name = @sprintf("irmof_%d_%d_%d_bonds.vtk", repfactors...)
write_bond_information(structure, bond_file_name)
# write the box vtk
write_vtk(structure)
# write the atom position .xyz
write_xyz(structure)
