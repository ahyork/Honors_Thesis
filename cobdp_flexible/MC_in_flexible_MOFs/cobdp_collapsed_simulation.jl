using Distributed
@everywhere push!(LOAD_PATH, "/nfs/stak/users/yorkar/git_files/PorousMaterials.jl/src")
@everywhere using PorousMaterials
using CSV
using DataFrames
using JLD2
using Printf

cobdp_collapsed = Framework("Cobdp_collapsed_P1.cif")
strip_numbers_from_atom_labels!(cobdp_collapsed)
ljforcefield = LJForceField("Dreiding.csv")
molecule = Molecule("CH4")

fugacities = [5.0 * i for i = 0:14]

results = adsorption_isotherm(cobdp_collapsed, molecule, 298.0, fugacities, ljforcefield,
    n_burn_cycles=10000, n_sample_cycles=10000, verbose=true, show_progress_bar=false,
    eos=:PengRobinson)

@save "ay_cobdp_collapsed_final.jld2" results
