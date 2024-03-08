using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
using DelimitedFiles
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)
println("Plaquette autocorrelation...")

files  = readdir("../input/plaquettes",join=true) 
param = readdlm("../output/tables/table1_machine_readable.csv",',',skipstart=1)

therms = Int.(param[:,12])
T = Int.(param[:,2])
L = Int.(param[:,3])
β = param[:,1]

for i in eachindex(files)
    file = files[i]
    therm = therms[i]     
    println(basename(file))
    configurations, plaq = plaquettes_grid(file)
    
    obslabel = L"\langle P ~ \rangle"
    title = latexstring(L"\beta = %$(β[i],) ~~ N_t \times N_s^3 = %$(T[i]) \times %$(L[i])^3")

    dir1 = abspath("../output/plots/plaquette_publication")
    dir2 = abspath("../output/plots/plaquette")
    ispath(dir1) || mkpath(dir1)
    ispath(dir2) || mkpath(dir2)
    
    plt1,τmax,τexp = MadrasSokal.publication_plot(plaq,obslabel,therm;thermstep=100,minlags=1000)
    plt2 = autocorrelation_overview(plaq,obslabel,therm;thermstep=100,minlags=1000,with_exponential=true)
    plot!(plt1,size=(800,300),plot_title=title)  
    plot!(plt2,plot_title=title)  

    savefig(plt1,joinpath(dir1,basename(file)*".pdf"))
    savefig(plt2,joinpath(dir2,basename(file)*".pdf"))    
end
