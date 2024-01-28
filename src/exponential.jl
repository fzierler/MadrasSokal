# Autocorrelation (exponential autocrrelation time)
function autocorrelation(x, lag)
    # (wasteful in terms of allocations but clear)
    z = x .- mean(x)
    norm = sum(abs2,z)
    a = sum(z[1+lag:end].*z[1:end-lag]) / norm
    return a
end
function autocorrelation(x;minlags=0)
    lx   = length(x)
    # lower limit of lags
    nlags = min(lx-1, round(Int,10log10(lx)))
    # apply a minimal number of lags
    nlags  = max(minlags,nlags)
    # create array of all lags considered
    lags  = collect(0:nlags)
    a = zeros(eltype(x),length(lags))
    for i in eachindex(lags)
        a[i] = autocorrelation(x, lags[i])
    end
    return a
end
function exponential_autocorrelation_time(O;minlags=0)
    # discard autocorrelation(t=0)=1 in fitting
    a = autocorrelation(O;minlags)[2:end]
    @. modelτ(x,p) = exp(-x/p[1])
    # we have previosuly discarded the data point at t=0
    x = collect(1:length(a))
    c = curve_fit(modelτ, x, a, ones(1))
    τ = c.param[1]
    return τ
end

