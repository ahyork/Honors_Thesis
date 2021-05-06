using PyPlot
using JLD2
using Printf
using CSV
using DataFrames

#pyplot()

structure_names = ["IRMOF-1.cssr"]

grid(true, linestyle="--", zorder=0) # the grid will be present
#set_axisbelow(true)
for structure in structure_names
    print_name = split(structure, ".")[1]
    input_file = split(structure, ".")[1] * "_Dreiding_100Kcycles_log.jld2"
    @load input_file results density

    pressures = [results[i]["pressure (bar)"] for i = 1:length(results)]
    mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]
    errors = [results[i]["err ⟨N⟩ (mmol/g)"] for i = 1:length(results)]
    mmolg_min = mmolg .- errors
    mmolg_max = mmolg .+ errors
    ribbons = (mmolg_min, mmolg_max)

    if print_name == "IRMOF-1"
        # hex pastel red: xFF9C9F
        # hex pastel orange: xF0CFB9
        simulated_color = "#FEC8D8"
        marker = "o"
    end
    
    # plot the line lowest
    #plot(pressures, mmolg, color=simulated_color, linewidth=0.75, zorder=100, clip_on=false) # simulated data

    # plot the error bars above the line
    #errorbar(pressures, mmolg, yerr=errors, ecolor="black", capsize=1.5, elinewidth=0.5, capthick=0.5,
    #         marker="", linestyle="", zorder=200, clip_on=false) # simulated data

    # plot the points a tthe top so they are clear
    #scatter(pressures, mmolg, s=4, linewidth=0.5, label=print_name * " Simulation (298 K)",
    #     edgecolors=simulated_color, marker=marker, c="white", zorder=300,
    #     clip_on=false) # simulated data

    # just do a simple line plot
    plot(pressures, mmolg, color=simulated_color, label=print_name * " Simulation (298 K)", marker="o", markerfacecolor="white", zorder=100, clip_on=false) # simulated data
end

# plot experimental data from jarad mason paper
# hex pastel blue: xBED5E8
exp_data = CSV.File("experimental_ch4_adsorption.csv", header=false) |> DataFrame
#scatter(exp_data[:, 1], exp_data[:, 2] ./ 22.4, s=4, c="#957DAD", marker="^", label="IRMOF-1 Experimental (298 K)", zorder=300, clip_on=false)
scatter(exp_data[:, 1], exp_data[:, 2] ./ 22.4, c="#957DAD", marker="^", label="IRMOF-1 Experimental (298 K)", zorder=300, clip_on=false)

xlabel("Pressure (bar)")
ylabel("Methane Adsorbed (mmol/g)")
#xscale("log")
#ylim([0, 250])
#xlim([0, 70])
title("Adsorption Isotherm for Methane in IRMOF-1 (MOF5)") # plot is labelled based on structure name
legend(loc=4) # legend will display in the lower right

output_file_adsorption = joinpath(pwd(), "plots", "IRMOF_adsorption_isotherm.png")
@printf("Saving figure to: %s\n", output_file_adsorption)
savefig(output_file_adsorption, dpi=300)
clf()
