using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

dir = "/home/fabian/Documents/Lattice/PlaquettesTursa/plaquettes"
dir = "/home/fabian/Dokumente/Physics/Lattice/PlaquettesTursa/plaquettes"

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

    dir1 = "plots/plaquette_publication"
    dir2 = "plots/plaquette"
    isdir(dir1) || mkdir(dir1)
    isdir(dir2) || mkdir(dir2)
    
    plt1,τmax,τexp = MadrasSokal.publication_plot(plaq,obslabel,therm;thermstep=100,minlags=1000)
    plt2 = autocorrelation_overview(plaq,obslabel,therm;thermstep=100,minlags=1000,with_exponential=true)
    plot!(plt1,size=(800,300),plot_title=title)  
    plot!(plt2,plot_title=title)  

    savefig(plt1,joinpath(dir1,basename(file)*".pdf"))
    savefig(plt2,joinpath(dir2,basename(file)*".pdf"))    
end
