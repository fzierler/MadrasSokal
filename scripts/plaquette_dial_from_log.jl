using DelimitedFiles
using MadrasSokal
using Plots
using MCMCDiagnosticTools

f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_flow"
f = "/home/fabian/Documents/Physics/Data/DataDiaL/measurements/Lt56Ls32beta6.45mf0.71mas1.04FUN/out/out_plaq_skip4"
files  = [f] 

plt1 = plot()
for file in files
    # get data for plaquette and topological charge
    plaq0 = plaquettes_hirep(file)
    therm = 2*109
    for skip in [1,2,4]
        plaq = plaq0[therm:skip:end]

        Γ = MadrasSokal.madras_sokal_estimator_windows(plaq)
        plot!(plt1,Γ)
        
        plt2 = autocorrelation_overview(plaq,"<P>",1;with_exponential=true)
        plot!(plt2,plot_title="skip=$skip")
        display(plt2)
        
    end
end
#display(plt1)