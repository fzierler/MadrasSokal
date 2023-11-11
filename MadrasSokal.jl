using Statistics
function madras_sokal_autocorr_fixedt(x, t)
    m = mean(x)
    Γ = zero(eltype(x))
    N = length(x)
    for i in 1:N-t
        Γ += (x[i]-m)*(x[i+t]-m)/(N-t)
    end
    return Γ 
end
# The maximal window size tmax is choosen using the 
# Madras-Sokal variance estimate, such that at tmax
# Δτ = τ, at which point τ seizes to give any usable 
# information.
function madras_sokal_autocorr_windows(x;tmax=length(x)÷10)
    Γ = zeros(eltype(x),tmax)
    for t in 1:tmax
        Γ[t] = madras_sokal_autocorr_fixedt(x, t)
    end
    return Γ 
end
