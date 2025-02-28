using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using LaTeXStrings
using DelimitedFiles
default(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=6Plots.mm, plot_titlefontsize=12)

function topology_plaquette_from_files(files; outdir = "./output/plots",  therm = 1)

    dir1 = joinpath(outdir,"topology_publication")
    dir2 = joinpath(outdir,"dial_topological_charge")
    ispath(dir1) || mkpath(dir1)
    ispath(dir2) || mkpath(dir2)

    for file in files
        data = readdlm(file,',';skipstart=1)
        cfgn, Q = Int.(data[:,1]), data[:,2]
                
        plt1,τmax,τexp = MadrasSokal.publication_plot(Q,"Q",therm)
        plt2 = autocorrelation_overview(Q,"Q",therm;with_exponential=true)
        
        T, L, β, mf,  mas = parse_filename(file)
        title = latexstring(L"\beta\!=\!%$(β),~ T\!\times\!L^3\!=\!\!%$(T)\!\times\!%$(L)^3,-\!(am_0^{\rm f},am_0^{\rm as})\!=\!(%$(abs(mf)),%$(abs(mas)))")
        plot!(plt1,plot_title=title,size=(800,300))  
        plot!(plt2,plot_title=title)

        savefig(plt1,joinpath(dir1,basename(file)*".pdf"))
        savefig(plt2,joinpath(dir2,basename(file)*".pdf"))
    end
end

files = readdir("./input/DiaL3",join=true) 
topology_plaquette_from_files(files; therm = 1)