using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using LaTeXStrings
using DelimitedFiles
using HDF5
default(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=6Plots.mm, plot_titlefontsize=12)

function topology_plaquette_from_files(file; outdir = "./output/plots",  therm = 1)

    dir1 = joinpath(outdir,"topology_publication")
    dir2 = joinpath(outdir,"dial_topological_charge")
    ispath(dir1) || mkpath(dir1)
    ispath(dir2) || mkpath(dir2)

    f = h5open(file)
    for ens in keys(f)

        cfgn, Q = read(f[ens],"trajectories"), read(f[ens],"Q")
                
        plt1,τmax,τexp = MadrasSokal.publication_plot(Q,"Q",therm)
        plt2 = autocorrelation_overview(Q,"Q",therm;with_exponential=true)
        
        T, L, β, mf,  mas = parse_filename(ens)
        title = latexstring(L"\beta\!=\!%$(β),~ T\!\times\!L^3\!=\!\!%$(T)\!\times\!%$(L)^3,-\!(am_0^{\rm f},am_0^{\rm as})\!=\!(%$(abs(mf)),%$(abs(mas)))")
        plot!(plt1,plot_title=title,size=(800,300))  
        plot!(plt2,plot_title=title)

        savefig(plt1,joinpath(dir1,ens*".pdf"))
        savefig(plt2,joinpath(dir2,ens*".pdf"))
    end
end

file = "/home/fabian/Dokumente/Physics/Analysis/MadrasSokal/input/gradient_flow_data.hdf5" 
topology_plaquette_from_files(file; therm = 1)