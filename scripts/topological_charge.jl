using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
gr(frame=:box,legendfontsize=10)

function autocorrelation_overview(obs,obslabel,therm;thermstep=1,with_exponential=false,kws...)
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

    # compute exponential autocorrelation time
    if with_exponential
        τexp = zeros(length(therms))
        minlags = 1000
        for (i,t) in enumerate(therms)
            τexp[i] = MadrasSokal.exponential_autocorrelation_time(obs[t:end];minlags)
        end
        τexp_therm = MadrasSokal.exponential_autocorrelation_time(obs[therm:end];minlags)
        τlabelEXP = L"τ_{\rm exp}=%$(round(τexp_therm,digits=1))" # \pm %$(round(Δτmax,digits=1))"
    end

    thermlabel = L"n_{therm}=%$therm"
    τlabel = L"τ_{\rm MS}=%$(round(τmax,digits=1)) \pm %$(round(Δτmax,digits=1))"

    plt0 = plot(therms, τ_therm, ribbon = Δτ_therm, label="", xlabel=L"n_{\rm therm}", ylabel=L"\tau_{\rm MS}" )
    vline!(plt0,[therm],label=thermlabel,legend=:topright)
    scatter!(plt0,[therm],[τmax],label=τlabel)
    plt1 = serieshistogram(o,ylims=extrema(o),title="")
    plt2 = fit_histogram_plot(o,xlabel=obslabel,ylabel="count")
    plt3 = plot(τ, ribbon = Δτ,label="",xlabel=L"window size $W$", ylabel=L"\tau_{\rm MS}")
    scatter!(plt3,[W],[τmax],label=τlabel)
    
    l = @layout [a; b; c; d]
    s = (480, 4*200)
    plt = plot(plt0,plt1,plt2,plt3,layout=l,size=s;kws...)
    
    if with_exponential 
        plt4 = plot(therms,τexp;label=τlabelEXP, xlabel=L"n_{\rm therm}", ylabel=L"\tau_{\rm exp}")
        vline!(plt4,[therm],label=thermlabel,legend=:topright)

        l = @layout [a; b; c; d; e]
        s = (480, 5*200)
        plt = plot(plt0,plt1,plt2,plt3,plt4,layout=l,size=s;kws...)
    end
    return plt    
end

files  = readdir("../flow_analysis/output",join=true) 
therms = [1,1,1,1,1]

using DelimitedFiles

for i in eachindex(files)
    file = files[i]
    therm = therms[i] 

    data = readdlm(files[i],',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]

    obslabel = L"\langle P ~ \rangle"
    plt = autocorrelation_overview(Q,obslabel,therm;with_exponential=true)
    plot!(plt,plot_title=basename(file))
    display(plt)
    
    dir = "plots/"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))
end
