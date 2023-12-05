fit_histogram_plot(data;kws...) = fit_histogram_plot!(plot(),data;kws...) 
function fit_histogram_plot!(plt,data;kws...)
    # Fit plaquette to a Normal Distributions
    d = fit(Normal, data)
    # set up plot range for dsitribution
    lo, hi = quantile.(d, [0.001, 0.999])
    x = range(lo, hi; length = 100)

    # plot histogram and overlay fit
    histogram!(plt,data,normalize=true,label="")
    plot!(plt, x, pdf.(d,x), lw=5, color=:black,label="";kws...)
    return plt
end
function autocorrelation_overview(obs,obslabel,therm;thermstep=1,minlags=100,with_exponential=false,kws...)
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
        for (i,t) in enumerate(therms)
            τexp[i] = exponential_autocorrelation_time(obs[t:end];minlags)
        end
        τexp_therm = exponential_autocorrelation_time(obs[therm:end];minlags)
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