using PorousMaterials
using CSV
using JLD2
using DataFrames
using Printf

forcefields = ["Dreiding"]
structures = ["IRMOF-1.cssr"]

for forcefield_name in forcefields
    for structure_name in structures
        structure = Crystal(structure_name)
        strip_numbers_from_atom_labels!(structure)

        ljforcefield = LJForceField(forcefield_name)

        molecule = Molecule("CH4")

        density = crystal_density(structure)

        output_filename = split(structure_name, '.')[1] * "_" * forcefield_name * "_50.0bar_10Kburn_10Ksample_snapshots_grid.jld2"

        #results = μVT_sim(structure, molecule, 298.0, 0.5, ljforcefield;
        #                  n_burn_cycles=10000, n_sample_cycles=100000,
        #                  write_adsorbate_snapshots=true,
        #                  snapshot_frequency=1000, eos=:PengRobinson,
        #                  results_filename_comment="snapshots", verbose=true)
        results, molecules = μVT_sim(structure, molecule, 298.0, 50.0,
                                     ljforcefield; n_burn_cycles=10000,
                                     n_sample_cycles=10000,
                                     snapshot_frequency=1,
                                     calculate_density_grid=true,
                                     density_grid_dx=0.5,
                                     eos=:PengRobinson,
                                     #write_adsorbate_snapshots=true,
                                     #results_filename_comment="snapshots",
                                     verbose=true
                                    )

        density_grid = results["density grid"]

        write_cube(density_grid, "ch4_irmof_density_grid.cube")

        @save output_filename results density

    end
end
