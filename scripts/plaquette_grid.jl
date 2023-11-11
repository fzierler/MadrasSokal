using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions

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

dir = "/home/fabian/Documents/Lattice/PlaquettesTursa/plaquettes"
files = readdir(dir,join=true) 
file  = files[1]
configurations, plaq = plaquettes_grid(file)

# Determine a suitable n_therm by looking at τ as a function 
# of the thermalisation cut, as well as a histogram of the plaquette
therms = collect(1:50:length(plaq)÷2)
τ_therm, Δτ_therm = madras_sokal_time(plaq,therms)
therm = 500
p = plaq[therm:end]
τ, Δτ = madras_sokal_windows(p)

plt0 = plot(therms, τ_therm, ribbon = Δτ_therm, label=basename(file))
plt1 = serieshistogram(p,ylims=extrema(p),title=basename(file))
plt2 = fit_histogram_plot(p)
plt3 = plot(τ, ribbon = Δτ,label=basename(file))

