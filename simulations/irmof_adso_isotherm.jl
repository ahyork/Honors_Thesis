using Distributed
@everywhere using PorousMaterials
using CSV
using DataFrames
using JLD2
using Printf

forcefield_files = ["Dreiding"]
structure_files = ["IRMOF-1.cssr"]

for forcefield_name in forcefield_files
    for structure_name in structure_files

        structure = Crystal(structure_name)
        strip_numbers_from_atom_labels!(structure)
        ljforcefield = LJForceField(forcefield_name)
        molecule = Molecule("CH4")

        density = crystal_density(structure)

        output_file = split(structure_name, ".")[1] * "_" * forcefield_name * "_100Kcycles" * ".jld2"

        # fugacities will not be modified in these simulations because it runs the same range for all structures
        # the pressures will be fifteen pressures from 10^-2 to 10 using a log10 scale

        pressures = [0.1, 5.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0]

        results = adsorption_isotherm(structure, molecule, 298.0, pressures,
                ljforcefield, n_burn_cycles=10000, n_sample_cycles=100000,
                verbose=true, show_progress_bar=false, eos=:PengRobinson)

        @save output_file results density

    end
end
