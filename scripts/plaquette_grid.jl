using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

function plaquettes_grid(file)
    plaquettes = Float64[]
    configurations = Int64[]
    for line in eachline(file)
        p = findfirst("Plaquette",line)
        line = line[p[end]+2:end]
        line = replace(line,"[" =>" ")
        line = replace(line,"]" =>" ")
        data =  split(line)
        append!(configurations,parse(Int64,data[1]))
        append!(plaquettes,parse(Float64,data[2]))
    end
    perm = sortperm(configurations)
    permute!(plaquettes,perm)
    permute!(configurations,perm)
    # only keep one value for every configurations
    # unique indices
    _unique_indices(x) = unique(i -> x[i],1:length(x))
    inds = _unique_indices(configurations)
    configurations = getindex(configurations,inds)
    plaquettes = getindex(plaquettes,inds)
    return configurations, plaquettes
end

dir = "/home/fabian/Documents/Lattice/PlaquettesTursa/plaquettes"
dir = "/home/fabian/Dokumente/Physics/Lattice/PlaquettesTursa/plaquettes"

files  = readdir(dir,join=true) 
basename.(files)
therms = [500,1000,1000,1000,1300,3000,4000]
L = [20,20,20,28,32,20,20]
T = [48,64,64,64,64,80,90]

for i in eachindex(files)
    file = files[i]
    therm = therms[i] 
    configurations, plaq = plaquettes_grid(file)
    
    obslabel = L"\langle P ~ \rangle"
    title = latexstring(L"\beta = 6.5, ~~ T \times L^3 = %$(T[i]) \times %$(L[i])^3")

    #=
    plt,τmax,τexp = MadrasSokal.publication_plot(plaq,obslabel,therm;thermstep=100,minlags=1000)

    plot!(plt,size=(800,300),plot_title=title)  
    display(plt)

    dir = "plots/plaquette_publication"
    isdir(dir) || mkdir(dir)
    #savefig(joinpath(dir,basename(file)*".pdf"))
    =#

    plt = autocorrelation_overview(plaq,obslabel,therm;thermstep=100,minlags=1000,with_exponential=true,publication_plot=true)
    plot!(plt,plot_title=title)  
    display(plt)

    dir = "plots/plaquette"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))
end
