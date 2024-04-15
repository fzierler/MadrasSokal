using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

dir = "/home/fabian/Documents/DataDiaL/PlaquettesNew/plaqs"
obslabel = L"\langle P ~ \rangle"

for file in readdir(dir,join=true) 
    therm = 100
    configurations, plaq = plaquettes_grid(file)
    
    #title = latexstring(L"\beta = 6.5, ~~ N_t \times N_s^3 = %$(T[i]) \times %$(L[i])^3")
    title = "title"

    plt2 = autocorrelation_overview(plaq,obslabel,therm;thermstep=50,minlags=1000,with_exponential=true)
    plot!(plt2,plot_title=title)  
    display(plt2)    
end
