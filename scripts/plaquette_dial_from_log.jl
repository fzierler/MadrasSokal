using DelimitedFiles
using MadrasSokal
using Plots
using MCMCDiagnosticTools
using MCMCDiagnostics

f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_flow"
f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_plaq_skip4"
f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_plaq_skip16"
f = "/home/fabian/Dokumente/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_plaq_skip4"
files  = [f] 

for file in files
    # get data for plaquette and topological charge
    plaq = plaquettes_hirep(file)
    therm = 109
    skip = 1
    plaq = plaq[therm:skip:end]

    Γ = MadrasSokal.madras_sokal_estimator_windows(plaq,max_window=length(plaq))
    Γ = MadrasSokal.madras_sokal_estimator_windows(plaq,max_window=250)
    plt1 = plot(Γ ./ Γ[1])
    display(plt1)

    # effective sample size from MCMCDiagnostics
    N  = size(plaq)[1]
    N0 = effective_sample_size(plaq)
    @show N/N0 
    
    # effective sample size from MCMCDiagnosticTools
    N  = size(plaq)[1]
    N0 = ess(plaq)
    @show N/N0 

    plt2 = autocorrelation_overview(plaq,"<P>",1;with_exponential=true)
    display(plt2)
end