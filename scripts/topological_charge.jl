using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using LaTeXStrings
using DelimitedFiles
using HDF5
default(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=6Plots.mm, plot_titlefontsize=12)

function full_observable_from_hdf5(file, outfile; label, name, plot_label, outdir = "./output/plots", index=nothing, ind_suffix="", therm = 1)
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
        
        ens_std = "Lt$(T)Ls$(L)beta$(round(β,sigdigits=2))mf$(mf)mas$(mas)"
        h5write(outfile,joinpath(ens_std,label*ind_suffix,"tau_exp"),τexp)
        h5write(outfile,joinpath(ens_std,label*ind_suffix,"tau_int"),τ)
        h5write(outfile,joinpath(ens_std,label*ind_suffix,"Delta_tau_int"),Δτ)

        plot!(plt1,plot_title=title,size=(800,300))  
        plot!(plt2,plot_title=title)  
        savefig(plt1,joinpath(dir1,ens_std*".pdf"))
        savefig(plt2,joinpath(dir2,ens_std*".pdf"))
    end
end

file = "../FlowAnalysis.jl/output/gradient_flow_data_for_baryons.hdf5"
fileCB = "./input/ChimeraBaryonCorrelators.hdf5" 
outfile = "output/autocor.hdf5"

isfile(outfile) && rm(outfile)
full_observable_from_hdf5(file,  outfile; label="topology",      name="Q",                     plot_label="Q",                 therm = 1)
full_observable_from_hdf5(file,  outfile; label="energy_density",name="energy_density_w0_sym", plot_label=L"\mathcal{E}(w_0)", therm = 1)
full_observable_from_hdf5(file,  outfile; label="plaquette",     name="plaquette",             plot_label=L"<\!p\!>",          therm = 1)
full_observable_from_hdf5(fileCB,outfile; label="PS_correlator", name="source_N0_sink_N80/anti TRIPLET g5", index=(:,10), plot_label=L"C_\pi(t=10)", therm = 1)
