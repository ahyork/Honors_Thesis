using PorousMaterials
using LightGraphs

structure = Crystal("casdb_clean_P1.cif")
strip_numbers_from_atom_labels!(structure)

structure = replicate(structure, (3, 6, 2))

bonding_rules = [BondingRule(:Ca, :O, 1.2, 2.5),
                 BondingRule(:H, :*, 0.4, 1.2),
                 BondingRule(:*, :*, 0.4, 1.9)]

infer_bonds!(structure, false, bonding_rules)

# write the bond information .vtk
write_bond_information(structure, "casdb_3_6_2_bonds.vtk")
# write the box vtk
write_vtk(structure)
# write the atom position .xyz
write_xyz(structure)
