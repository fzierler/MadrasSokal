using DelimitedFiles
using MadrasSokal
using Plots

f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_flow"
f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_plaq_skip4"
files  = [f] 

for file in files
    # get data for plaquette and topological charge
    plaq = plaquettes_hirep(file)
    @show size(plaq)

    therm=396
    plt2 = autocorrelation_overview(plaq,"<P>",therm;with_exponential=true)
    display(plt2)
end