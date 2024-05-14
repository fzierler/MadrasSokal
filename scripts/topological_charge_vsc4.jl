using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
using DelimitedFiles
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

# output from DiaL
files   = readdir("../flow_analysis/outputVSC4",join=true) 
outfile = joinpath("output","topologyVSC4.csv")
io      = open(outfile,"w")
write(io,"beta,am0f,am0as,Nt,Ns,Nconf,w0,Delta_w0,Q,Delta_Q,τint_Q,Delta_τint_Q\n")

using DelimitedFiles

for i in eachindex(files)
    file = files[i]
    @show file
    therm = 1 #therms[i] 

    data = readdlm(files[i],',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]
    
    obslabel = L"Q"
    title = "" #latexstring(L"\beta = %$(β[i]), ~~ T \times L^3 = %$(T[i]) \times %$(L[i])^3")

    dir1 = "plotsVSC/topology_publication"
    dir2 = "plotsVSC/dial_topological_charge"
    ispath(dir1) || mkpath(dir1)
    ispath(dir2) || mkpath(dir2)

    plt1,τmax,τexp = MadrasSokal.publication_plot(Q,obslabel,therm)
    plt2 = autocorrelation_overview(Q,obslabel,therm;with_exponential=true)
    
    display(plt2)

    plot!(plt1,size=(800,300),plot_title=title)  
    plot!(plt2,plot_title=basename(file))

    savefig(joinpath(dir1,basename(file)*".pdf"))
    savefig(joinpath(dir2,basename(file)*".pdf"))
end
