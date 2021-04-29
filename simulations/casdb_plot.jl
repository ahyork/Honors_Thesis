using PyPlot
using JLD2
using Printf

structure_names = ["KAXQIL_clean_P1.cif"]

grid(true, linestyle="--", zorder=0) # the grid will be present
#set_axisbelow(true)
for structure in structure_names
    print_name = split(structure, ".")[1]
    input_file = split(structure, ".")[1] * "_UFF_10Kcycles.jld2"
    @load input_file results density

    pressures = [results[i]["pressure (bar)"] for i = 1:length(results)]
    mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]

    if print_name == "KAXQIL_clean_P1"
        simulated_color = "orange"
        marker = "^"
    elseif print_name == "KAXQIL_clean_P1_min"
        simulated_color = "black"
        marker = "o"
    elseif print_name == "KAXQIL_clean_P1_md"
        simulated_color = "magenta"
        marker = "s"
    end
    
    plot(pressures, mmolg, label=print_name * " Simulation (298 K)", color=simulated_color, marker=marker, mfc="none", zorder=1000, clip_on=false) # simulated data
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

