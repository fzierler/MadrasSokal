using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
gr(frame=:box,legendfontsize=10)

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

dir    = "/home/fabian/Documents/Lattice/PlaquettesTursa/plaquettes"
files  = readdir(dir,join=true) 
therms = [1000,1000,1000,1000,1000,3000,4000]

for i in eachindex(files)
    file = files[i]
    therm = therms[i] 

    configurations, plaq = plaquettes_grid(file)
    
    obslabel = L"\langle P ~ \rangle"
    plt = autocorrelation_overview(plaq,obslabel,therm;thermstep=100,minlags=1000,with_exponential=true)
    plot!(plt,plot_title=basename(file))
    
    dir = "plots/"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))
    #display(plt)
end