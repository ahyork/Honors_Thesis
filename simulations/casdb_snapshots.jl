using PorousMaterials
using CSV
using JLD2
using DataFrames
using Printf

forcefields = ["UFF"]
structures = ["casdb_clean_P1.cif"]

for forcefield_name in forcefields
    for structure_name in structures
        structure = Crystal(structure_name)
        strip_numbers_from_atom_labels!(structure)

        ljforcefield = LJForceField(forcefield_name)

        molecule = Molecule("Xe")

        density = crystal_density(structure)

        #output_filename = split(structure_name, '.')[1] * "_" * forcefield_name * "_0.5bar_10Kburn_100Ksample_snapshot.jld2"
        output_filename = split(structure_name, '.')[1] * "_" * forcefield_name * "_0.5bar_10Kburn_100Ksample_density_grid.jld2"

        #results = μVT_sim(structure, molecule, 298.0, 0.5, ljforcefield;
        #                  n_burn_cycles=10000, n_sample_cycles=100000,
        #                  write_adsorbate_snapshots=true,
        #                  snapshot_frequency=1000, eos=:PengRobinson,
        #                  results_filename_comment="snapshots", verbose=true)
        results = μVT_sim(structure, molecule, 298.0, 0.5, ljforcefield;
                          n_burn_cycles=10000, n_sample_cycles=100000,
                          snapshot_frequency=1, calculate_density_grid=true,
                          density_grid_dx=0.5, eos=:PengRobinson, verbose=true)

        @save output_filename results density

    end
end
