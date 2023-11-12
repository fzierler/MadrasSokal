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