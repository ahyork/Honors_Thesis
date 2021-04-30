using PyPlot
using JLD2
using Printf

#pyplot()

structure_names = ["KAXQIL_clean_P1.cif"]

grid(true, linestyle="--", zorder=0) # the grid will be present
#set_axisbelow(true)
for structure in structure_names
    print_name = split(structure, ".")[1]
    input_file = split(structure, ".")[1] * "_UFF_10Kcycles.jld2"
    #input_file = split(structure, ".")[1] * "_UFF_100Kcycles.jld2"
    @load input_file results density

    pressures = [results[i]["pressure (bar)"] for i = 1:length(results)]
    mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]
    errors = [results[i]["err ⟨N⟩ (mmol/g)"] for i = 1:length(results)]
    mmolg_min = mmolg .- errors
    mmolg_max = mmolg .+ errors
    ribbons = (mmolg_min, mmolg_max)

    if print_name == "KAXQIL_clean_P1"
        simulated_color = "orange"
        marker = "o"
    end
    
    # plot the line lowest
    plot(pressures, mmolg, color=simulated_color, linewidth=0.75, zorder=100, clip_on=false) # simulated data

    # plot the error bars above the line
    errorbar(pressures, mmolg, yerr=errors, ecolor="black", capsize=1.5, elinewidth=0.5, capthick=0.5,
             marker="", linestyle="", zorder=200, clip_on=false) # simulated data

    # plot the points a tthe top so they are clear
    scatter(pressures, mmolg, s=4, linewidth=0.5, label=print_name * " Simulation (298 K)",
         edgecolors=simulated_color, marker=marker, c="white", zorder=300,
         clip_on=false) # simulated data
end
xlabel("Pressure (bar)")
ylabel("Methane Adsorbed (mmol/g)")
#xscale("log")
#ylim([0, 250])
#xlim([0, 70])
title("Adsorption Isotherm for Xe in CaSDB") # plot is labelled based on structure name
legend(loc=4) # legend will display in the lower right

output_file_adsorption = joinpath(pwd(), "plots", "CaSDB_adsorption_isotherm.png")
@printf("Saving figure to: %s\n", output_file_adsorption)
savefig(output_file_adsorption, dpi=300)
clf()

