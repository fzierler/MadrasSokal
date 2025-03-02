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
        @show ens
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
        
        ens_std = "Lt$(T)Ls$(L)beta$(round(β,sigdigits=3))mf$(mf)mas$(mas)"
        h5write(outfile,joinpath(ens_std,label*ind_suffix,"tau_exp"),τexp)
        h5write(outfile,joinpath(ens_std,label*ind_suffix,"tau_int"),τ)
        h5write(outfile,joinpath(ens_std,label*ind_suffix,"Delta_tau_int"),Δτ)

        plot!(plt1,plot_title=title,size=(800,300))  
        plot!(plt2,plot_title=title)  
        savefig(plt1,joinpath(dir1,ens_std*".pdf"))
        savefig(plt2,joinpath(dir2,ens_std*".pdf"))
    end
end
# Write results into csv file
fmt(x,Δx,n) = rpad(errorstring(x,Δx)*",",n)
fmt(x,n)    = rpad(string(round(x,sigdigits=2))*",",n)
function write_tau_csv(h5file,csv_io)
    pad1, pad2 = 10, 8
    f    = h5open(h5file)
    ens  = keys(f)
    pad0 = maximum(length.(ens))+2
    println(csv_io,"$(rpad("name",pad0)) $(rpad("τ_P,",pad1)) $(rpad("τ_exp_P,",pad2)) $(rpad("τ_Q,",pad1)) $(rpad("τ_exp_Q,",pad2)) $(rpad("τ_E,",pad1)) $(rpad("τ_exp_E,",pad2)) $(rpad("τ_Cπ,",pad1)) $(rpad("τ_exp_Cπ,",pad2))")
    for e in ens    
        τQ, ΔτQ, τexpQ = read(f[e]["topology"],"tau_int"),       read(f[e]["topology"],"Delta_tau_int"),      read(f[e]["topology"],"tau_exp")
        τE, ΔτE, τexpE = read(f[e]["energy_density"],"tau_int"), read(f[e]["energy_density"],"Delta_tau_int"),read(f[e]["energy_density"],"tau_exp")
        τP, ΔτP, τexpP = read(f[e]["plaquette"],"tau_int"),      read(f[e]["plaquette"],"Delta_tau_int"),     read(f[e]["plaquette"],"tau_exp")
        τπ, Δτπ, τexpπ = read(f[e]["PS_correlator"],"tau_int"),  read(f[e]["PS_correlator"],"Delta_tau_int"), read(f[e]["PS_correlator"],"tau_exp")
        println(csv_io,"$(rpad(e,pad0)) $(fmt(τP,ΔτP,pad1)) $(fmt(τexpP,pad2)) $(fmt(τQ,ΔτQ,pad1)) $(fmt(τexpQ,pad2)) $(fmt(τE,ΔτE,pad1)) $(fmt(τexpE,pad2)) $(fmt(τπ,Δτπ,pad1)) $(fmt(τexpπ,pad2))")
    end
end
function write_tau_csv_no_correlators(h5file,csv_io)
    pad1, pad2 = 10, 8
    f    = h5open(h5file)
    ens  = keys(f)
    pad0 = maximum(length.(ens))+2
    println(csv_io,"$(rpad("name",pad0)) $(rpad("τ_P,",pad1)) $(rpad("τ_exp_P,",pad2)) $(rpad("τ_Q,",pad1)) $(rpad("τ_exp_Q,",pad2)) $(rpad("τ_E,",pad1)) $(rpad("τ_exp_E,",pad2))")
    for e in ens    
        τQ, ΔτQ, τexpQ = read(f[e]["topology"],"tau_int"),       read(f[e]["topology"],"Delta_tau_int"),      read(f[e]["topology"],"tau_exp")
        τE, ΔτE, τexpE = read(f[e]["energy_density"],"tau_int"), read(f[e]["energy_density"],"Delta_tau_int"),read(f[e]["energy_density"],"tau_exp")
        τP, ΔτP, τexpP = read(f[e]["plaquette"],"tau_int"),      read(f[e]["plaquette"],"Delta_tau_int"),     read(f[e]["plaquette"],"tau_exp")
        println(csv_io,"$(rpad(e,pad0)) $(fmt(τP,ΔτP,pad1)) $(fmt(τexpP,pad2)) $(fmt(τQ,ΔτQ,pad1)) $(fmt(τexpQ,pad2)) $(fmt(τE,ΔτE,pad1)) $(fmt(τexpE,pad2))")
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

out_csv = "output/tau.csv"
io = open(out_csv,"w")
write_tau_csv(outfile,io)
close(io)

file = "../FlowAnalysis.jl/output/gradient_flow_data_for_scattering.hdf5"
outfile = "output/autocor_nf2.hdf5"
outdir  = "./output/plots_nf2"
isfile(outfile) && rm(outfile)
full_observable_from_hdf5(file,  outfile; label="topology",      name="Q",                     plot_label="Q",                 outdir, therm = 1)
full_observable_from_hdf5(file,  outfile; label="energy_density",name="energy_density_w0_sym", plot_label=L"\mathcal{E}(w_0)", outdir, therm = 1)
full_observable_from_hdf5(file,  outfile; label="plaquette",     name="plaquette",             plot_label=L"<\!p\!>",          outdir, therm = 1)

out_csv = "output/tau_nf2.csv"
io = open(out_csv,"w")
write_tau_csv_no_correlators(outfile,io)
close(io)