using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
using Statistics
using DelimitedFiles
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

# output from DiaL
files   = readdir("../flow_analysis/outputDiaLTests",join=true)
therms  = 100*ones(Int,length(files))
nskip   = 1

for i in eachindex(files)
    file  = files[i]
    therm = therms[i] 

    data = readdlm(files[i],',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]
    Q = Q[1:nskip:end]

    obslabel = L"Q"
    title = "" #latexstring(L"\beta = %$(β[i]), ~~ T \times L^3 = %$(T[i]) \times %$(L[i])^3")

    plt1,τmax,τexp = MadrasSokal.publication_plot(Q,obslabel,therm)
    plt2 = autocorrelation_overview(Q,obslabel,therm;with_exponential=true,integergbins=true)
    
    plot!(plt1,size=(800,300),plot_title=title)  
    plot!(plt2,plot_title=basename(file))
    display(plt2)
end
