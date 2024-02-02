using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

dir    = "/home/fabian/Documents/Lattice/PlaquettesTursa/plaquettes"
files  = readdir(dir,join=true) 
basename.(files)
therms = [500,1000,1000,1000,3000,3000,4000]
L      = [ 20,  20,  20,  28,  32,  20,  20]
T      = [ 48,  64,  64,  64,  64,  80,  90]

for i in eachindex(files)
    file = files[i]
    therm = therms[i] 
    configurations, plaq = plaquettes_grid(file)
    
    obslabel = L"\langle P ~ \rangle"
    title = latexstring(L"\beta = 6.5, ~~ N_t \times N_s^3 = %$(T[i]) \times %$(L[i])^3")

    plt,τmax,τexp = MadrasSokal.publication_plot(plaq,obslabel,therm;thermstep=100,minlags=1000)
    plot!(plt,size=(800,300),plot_title=title)  
    display(plt)

    dir = "plots/plaquette_publication"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))

    plt = autocorrelation_overview(plaq,obslabel,therm;thermstep=100,minlags=1000,with_exponential=true)
    plot!(plt,plot_title=title)  
    display(plt)

    dir = "plots/plaquette"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))
end
