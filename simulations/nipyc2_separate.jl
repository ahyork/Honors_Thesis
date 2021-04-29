using PorousMaterials
using LightGraphs
using Printf

# read in NiPyC2 and replicate to be 4, 4, 4
filename = "NiPyC2.cif"
structure = Crystal(filename)
strip_numbers_from_atom_labels!(structure)
structure = replicate(structure, (4, 4, 4))

# make bonding rules
bonding_rules = [BondingRule(:H, :*, 0.4, 1.2),
                 BondingRule(:N, :Ni, 0.4, 2.5),
                 BondingRule(:O, :Ni, 0.4, 2.5),
                 BondingRule(:*, :*, 0.4, 1.9)]

# create bonds on NiPyC2
infer_bonds!(structure, true, bonding_rules)

# find the separate components - there should be 2
interpenetrated_components = connected_components(structure.bonds)
@printf("The crystal %s has %d connected components", filename,
        length(interpenetrated_components))

comp_1 = structure[interpenetrated_components[1]]
comp_2 = structure[interpenetrated_components[2]]

# rename the crystals to reflect that they are not the full structure
comp_1 = Crystal(comp_1.name * "_comp_1", comp_1.box, comp_1.atoms, comp_1.charges, comp_1.bonds, comp_1.symmetry)
comp_2 = Crystal(comp_2.name * "_comp_2", comp_2.box, comp_2.atoms, comp_2.charges, comp_2.bonds, comp_2.symmetry)

# remove bonds so we can infer without wrapping
remove_bonds!(comp_1)
remove_bonds!(comp_2)

# infer bonds without wrapping around the box
infer_bonds!(comp_1, false, bonding_rules)
infer_bonds!(comp_2, false, bonding_rules)

# write the box
write_vtk(structure)

# comp_1
# write bond information
write_bond_information(comp_1, "nipyc2_comp1_bonds.vtk")
# write atom positions
write_xyz(comp_1)

# comp_2
# write bond information
write_bond_information(comp_2, "nipyc2_comp2_bonds.vtk")
# write atom positions
write_xyz(comp_2)
