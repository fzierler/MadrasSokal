using DelimitedFiles
using MadrasSokal
using Plots
using MCMCDiagnosticTools
using MCMCDiagnostics

f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_flow"
f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_plaq_skip4"
f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_plaq_skip16"
files  = [f] 

for file in files
    # get data for plaquette and topological charge
    plaq = plaquettes_hirep(file)
    therm=396
    therm=99

    # effective sample size from MCMCDiagnostics
    N  = size(plaq[therm:end])[1]
    N0 = effective_sample_size(plaq[therm:end])
    @show N/N0 
    
    # effective sample size from MCMCDiagnosticTools
    N  = size(plaq[therm:end])[1]
    N0 = ess(plaq[therm:end])
    @show N/N0 


    plt2 = autocorrelation_overview(plaq,"<P>",therm;with_exponential=true)
    display(plt2)
end