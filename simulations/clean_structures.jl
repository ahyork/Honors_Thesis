using PorousMaterials
using LightGraphs
using Printf

# read in dirty structure
filename = "KAXQIL_dirty.cif"
structure = Crystal(filename)
strip_numbers_from_atom_labels!(structure)
wrap!(structure)
structure = replicate(structure, (2, 2, 2))

bonding_rules = [BondingRule(:H, :*, 0.4, 1.2),
                 BondingRule(:Ca, :O, 1.2, 2.5),
                 BondingRule(:*, :*, 0.4, 1.9)]

# find all bonds within the structure, including solvent
# go across boundaries to make the original structure one piece
infer_bonds!(structure, true, bonding_rules)

# find the separate structures within the file
structure_solvents = connected_components(structure.bonds)
@printf("The crysal %s has %d connected components\n", filename,
        length(structure_solvents))

# find the longest array of vertices, this is the array of indices used to make
#   the clean structure
clean_structure_id = argmax(length.(structure_solvents))
clean_structure_comps = structure_solvents[clean_structure_id]

clean_structure = structure[clean_structure_comps]

# rename the cleaned structure, don't include bonds or symmetry because
#   structure is in P1 and we are going to recreate the bonding information
#   for better visibility
clean_structure = Crystal("KAXQIL_removed_solvent", clean_structure.box,
                          clean_structure.atoms, clean_structure.charges)

# infer bonds within the box for clean vis
infer_bonds!(clean_structure, false, bonding_rules)
write_bond_information(clean_structure, "KAXQIL_removed_solvent.vtk")

# write atom positions for cleaned structure
write_xyz(clean_structure)

# write the box for visualization
write_vtk(structure)

# combine all the other graphs into a single other structure that represents
#   the solvents
solvents = +([structure[s] for s in deleteat!(structure_solvents,
             clean_structure_id)]...)

# rename the file so the xyz file is differentiable
solvents = Crystal("KAXQIL_solvents", solvents.box, solvents.atoms,
                   solvents.charges)

infer_bonds!(solvents, false, bonding_rules)

# write the bonding information
write_bond_information(solvents, "KAXQIL_solvents.vtk")

# write the atom positions
write_xyz(solvents)
