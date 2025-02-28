using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using LaTeXStrings
using DelimitedFiles
using HDF5
default(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=6Plots.mm, plot_titlefontsize=12)

function full_observable_from_hdf5(file; label, name, plot_label, outdir = "./output/plots", index=nothing, therm = 1)
    dir1 = joinpath(outdir,"$(label)_history")
    dir2 = joinpath(outdir,"$(label)_full")
    for dir in [dir1,dir2]
        ispath(dir) || mkpath(dir)
    end

    f = h5open(file)
    for ens in keys(f)
        obs  = read(f[ens],name)
        if !isnothing(index)
            obs = obs[index...]
        end
        cfgn = 1:length(obs)
        
        plt1,τ, Δτ,τexp = MadrasSokal.publication_plot(cfgn,obs,plot_label,therm)
        plt2 = autocorrelation_overview(cfgn,obs,plot_label,therm;with_exponential=true)
 
        T, L, β, mf, mas = try 
            parse_filename(ens)
        catch 
            parse_configname(ens) 
        end
        title = latexstring(L"\beta\!=\!%$(β),~ T\!\times\!L^3\!=\!\!%$(T)\!\times\!%$(L)^3,-\!(am_0^{\rm f},am_0^{\rm as})\!=\!(%$(abs(mf)),%$(abs(mas)))")

        plot!(plt1,plot_title=title,size=(800,300))  
        plot!(plt2,plot_title=title)  
        savefig(plt1,joinpath(dir1,ens*".pdf"))
        savefig(plt2,joinpath(dir2,ens*".pdf"))
    end
end

file = "./input/gradient_flow_data.hdf5"
fileCB = "./input/ChimeraBaryon.hdf5" 
full_observable_from_hdf5(file; label="topology", name="Q", plot_label="Q", therm = 1)
full_observable_from_hdf5(file; label="energy_density", name="energy_density_w0_sym", plot_label=L"\mathcal{E}(w_0)", therm = 1)
full_observable_from_hdf5(file; label="plaquette", name="plaquette", plot_label=L"<\!p\!>", therm = 1)
full_observable_from_hdf5(fileCB; label="PS_correlator", name="source_N0_sink_N80/anti TRIPLET g0g1", index=(:,10), plot_label=L"C_\pi(t=10)", therm = 1)