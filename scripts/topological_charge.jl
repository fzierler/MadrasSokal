using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
using DelimitedFiles
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)
println("Topological charge autocorrelation...")

# output from DiaL
files = readdir("../output/flow_analysis",join=true) 
param = readdlm("../output/tables/table1_machine_readable.csv",',',skipstart=1)

T = Int.(param[:,2])
L = Int.(param[:,3])
β = param[:,1]

for i in eachindex(files)
    file  = files[i]
    therm = 1
    println(basename(file))

    data = readdlm(files[i],',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]
    
    obslabel = L"Q"
    title = latexstring(L"\beta = %$(β[i]), ~~ T \times L^3 = %$(T[i]) \times %$(L[i])^3")

    dir1 = "../output/plots/topological_charge_publication"
    dir2 = "../output/plots/topological_charge"
    isdir(dir1) || mkdir(dir1)
    isdir(dir2) || mkdir(dir2)

    plt1,τmax,τexp = MadrasSokal.publication_plot(Q,obslabel,therm)
    plt2 = autocorrelation_overview(Q,obslabel,therm;with_exponential=true)
    
    plot!(plt1,size=(800,300),plot_title=title)  
    plot!(plt2,plot_title=basename(file))

    savefig(plt1,joinpath(dir1,basename(file)*".pdf"))
    savefig(plt2,joinpath(dir2,basename(file)*".pdf"))
end
