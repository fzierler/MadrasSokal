using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
using DelimitedFiles
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

# output from DiaL
files  = readdir("../flow_analysis/outputDiaL",join=true) 
therms = ones(Int,length(files))
# more conservative thermalisation times wrt to topological charge
L = [20,24,28,32,32,36,36,20,20,32,20,20]
T = [48,48,48,56,56,56,56,64,64,64,80,90]
β = [6.5,6.45,6.45,6.45,6.45,6.45,6.45,6.5,6.5,6.5,6.5,6.5]
therms[10] = 85

for i in eachindex(files)

    # for now only study enembles with β=6.5
    β[i] ≈ 6.5 || continue

    file = files[i]
    therm = therms[i] 

    data = readdlm(files[i],',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]

    obslabel = L"Q"

    plt,τmax,τexp = MadrasSokal.publication_plot(Q,obslabel,therm)
    title = latexstring(L"\beta = %$(β[i]), ~~ N_t \times N_s^3 = %$(T[i]) \times %$(L[i])^3")

    plot!(plt,size=(800,300),plot_title=title)  
    display(plt)

    dir = "plots/topology_publication"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))

    plt = autocorrelation_overview(Q,obslabel,therm;with_exponential=true)
    plot!(plt,plot_title=title)
    display(plt)
    
    dir = "plots/topology"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))
end
