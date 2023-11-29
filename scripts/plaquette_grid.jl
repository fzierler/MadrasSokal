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
function autocorrelation_overview(obs,obslabel,therm;thermstep=50,kws...)
    # Assume scalar variable
    # Determine a suitable n_therm by looking at τ as a function 
    # of the thermalisation cut, as well as a histogram of the plaquette
    therms = collect(1:thermstep:length(obs)÷2)
    τ_therm, Δτ_therm = madras_sokal_time(obs,therms)
    
    # If therm is too large use the maximal value of thermstep
    therm = min(maximum(therms),therm)
    o = obs[therm:end]
    
    τ, Δτ = madras_sokal_windows(o)
    τmax, W = findmax(τ)
    Δτmax = Δτ[W]

    thermlabel = L"n_{therm}=%$therm"
    τlabel = L"τ=%$(round(τmax,digits=1)) \pm %$(round(Δτmax,digits=1))"

    plt0 = plot(therms, τ_therm, ribbon = Δτ_therm, label="", xlabel=L"n_{\rm therm}", ylabel=L"\tau_{\rm MS}" )
    vline!(plt0,[therm],label=thermlabel,legend=:topright)
    scatter!(plt0,[therm],[τmax],label=τlabel)
    plt1 = serieshistogram(o,ylims=extrema(o),title="")
    plt2 = fit_histogram_plot(o,xlabel=obslabel,ylabel="count")
    plt3 = plot(τ, ribbon = Δτ,label="",xlabel=L"window size $W$", ylabel=L"\tau_{\rm MS}")
    scatter!(plt3,[W],[τmax],label=τlabel)

    l = @layout [a; b; c; d]
    s = (480, 4*200)
    plot(plt0,plt1,plt2,plt3,layout=l,size=s;kws...)
end

dir    = "/home/fabian/Documents/Lattice/PlaquettesTursa/plaquettes"
files  = readdir(dir,join=true) 
therms = [1000,1000,1000,1000,1000,3000,4000]

for i in eachindex(files)
    #i != 4 && continue
    file = files[i]
    therm = therms[i] 

    configurations, plaq = plaquettes_grid(file)
    
    obslabel = L"\langle P ~ \rangle"
    plt = autocorrelation_overview(plaq,obslabel,therm)
    plot!(plt,plot_title=basename(file))
    
    dir = "plots/"
    isdir(dir) || mkdir(dir)
    #savefig(joinpath(dir,basename(file)*".pdf"))
    display(plt)
end