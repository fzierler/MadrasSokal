using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
gr(frame=:box,legendfontsize=10)

# output from DiaL
#files  = readdir("../flow_analysis/output",join=true) 
#therms = ones(Int,length(files))

# output from Tursa
files  = readdir("../flow_analysis/outputTursa",join=true) 
therms = ones(Int,length(files))

using DelimitedFiles

for i in eachindex(files)
    file = files[i]
    therm = therms[i] 

    data = readdlm(files[i],',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]

    obslabel = L"\langle P ~ \rangle"
    plt = autocorrelation_overview(Q,obslabel,therm;with_exponential=true)
    plot!(plt,plot_title=basename(file))
    display(plt)
    
    dir = "plots/"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))
end
