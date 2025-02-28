using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using LaTeXStrings
using DelimitedFiles
using HDF5
default(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=6Plots.mm, plot_titlefontsize=12)

function topology_plaquette_from_files(file; outdir = "./output/plots",  therm = 1)

    dir1 = joinpath(outdir,"topology_history")
    dir2 = joinpath(outdir,"topology_full")
    dir3 = joinpath(outdir,"plaquette_history")
    dir4 = joinpath(outdir,"plaquette_full")
    dir5 = joinpath(outdir,"energy_density_history")
    dir6 = joinpath(outdir,"energy_density_full")
    for dir in [dir1,dir2,dir3,dir4,dir5,dir6]
        ispath(dir) || mkpath(dir)
    end

    f = h5open(file)
    for ens in keys(f)

        cfgn, Q, plaq = read(f[ens],"trajectories"), read(f[ens],"Q"), read(f[ens],"plaquette")
        Esym, Eplaq = read(f[ens],"energy_density_w0_sym"), read(f[ens],"energy_density_w0_plaq")
                
        plt1,τmax,τexp = MadrasSokal.publication_plot(cfgn,Q,"Q",therm)
        plt2 = autocorrelation_overview(cfgn, Q,"Q",therm;with_exponential=true)
        
        plt3,τmax,τexp = MadrasSokal.publication_plot(cfgn,plaq,L"<\!p\!>",therm)
        plt4 = autocorrelation_overview(cfgn, plaq,L"<\!p\!>",therm;with_exponential=true)

        plt5,τmax,τexp = MadrasSokal.publication_plot(cfgn,Esym,L"\mathcal{E} (w_0)",therm)
        plt6 = autocorrelation_overview(cfgn,Esym,L"\mathcal{E} (w_0)",therm;with_exponential=true)

        T, L, β, mf,  mas = parse_filename(ens)
        title = latexstring(L"\beta\!=\!%$(β),~ T\!\times\!L^3\!=\!\!%$(T)\!\times\!%$(L)^3,-\!(am_0^{\rm f},am_0^{\rm as})\!=\!(%$(abs(mf)),%$(abs(mas)))")

        for (plt,dir) in zip([plt1,plt3,plt5],[dir1,dir3,dir5]) 
            plot!(plt,plot_title=title,size=(800,300))  
            savefig(plt,joinpath(dir,ens*".pdf"))
        end
        for (plt,dir) in zip([plt2,plt4,plt6],[dir2,dir4,dir6]) 
            plot!(plt,plot_title=title)  
            savefig(plt,joinpath(dir,ens*".pdf"))
        end
    end
end

file = "/home/fabian/Dokumente/Physics/Analysis/MadrasSokal/input/gradient_flow_data.hdf5" 
topology_plaquette_from_files(file; therm = 1)