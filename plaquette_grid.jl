using Plots
using Distributions: fit
include("MadrasSokal.jl")
include("serieshistogram.jl")
plotlyjs()

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
    return configurations, plaquettes
end
function madras_sokal_windows(x)
    Γ  = madras_sokal_autocorr_windows(x)
    τ  = 1/2 .+ cumsum(Γ/Γ[1])
    Δτ = similar(τ)
    N  = length(x)
    for i in eachindex(τ)
        Δτ[i] = sqrt(τ[i]^2 * (4i+2)/N)
    end
    return τ, Δτ
end
function tau_int_thermalisation(x,therms)
    τ  = zeros(Float64,size(therms))
    Δτ = zeros(Float64,size(therms))
    for j in eachindex(therms)
        xc = x[therms[j]:end]
        τ_windows, Δτ_windows = madras_sokal_windows(xc)
        τ[j], W = findmax(τ_windows)
        Δτ[j]   = Δτ_windows[W]
    end
    return τ, Δτ
end
fit_histogram_plot(data) = fit_histogram_plot!(plot(),data) 
function fit_histogram_plot!(plt,data)
    # Fit plaquette to a Normal Distributions
    d = fit(Normal, data)
    # set up plot range for dsitribution
    lo, hi = quantile.(d, [0.001, 0.999])
    x = range(lo, hi; length = 100)

    # plot histogram and overlay fit
    histogram!(plt,p,normalize=true,label="")
    plot!(plt, x,pdf.(Ref(dist),x), lw=5, color=:black,label="")
    return plt
end

dir = "/home/fabian/Documents/Lattice/PlaquettesTursa/plaquettes"
files = readdir(plaquettes_dir,join=true) 
file  = files[1]

configurations, plaq = plaquettes_grid(file)

# Determine a suitable n_therm by looking at τ as a function 
# of the thermalisation cut, as well as a histogram of the plaquette
therm = collect(1:50:length(plaq)÷2)
τ, Δτ = tau_int_thermalisation(p,therm)
plot(therm, τ, ribbon = Δτ,label=basename(file))

therm = 500
p = plaq[therm:end]
plt  = serieshistogram(p,ylims=extrema(p),title=basename(file))
plt2 = fit_histogram_plot(p)

# Inspect the windowing dependence for a specific thermalisation cuttherm = 500
p = plaq[therm:end]
τ, Δτ = madras_sokal_windows(p)
plot(τ, ribbon = Δτ,label=basename(file))

