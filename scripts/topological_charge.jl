using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)

# output from DiaL
files  = readdir("../flow_analysis/outputDiaL",join=true) 
therms = ones(Int,length(files))
# more conservative thermalisation times wrt to topological charge
L = [20,24,28,32,32,36,36,20,20,32,20,20]
T = [48,48,48,56,56,56,56,64,64,64,80,90]
β = [6.5,6.45,6.45,6.45,6.45,6.45,6.45,6.5,6.5,6.5,6.5,6.5]

# output from Tursa
#files  = readdir("../flow_analysis/outputTursa",join=true) 
#therms = ones(Int,length(files))

using DelimitedFiles

for i in eachindex(files)
    file = files[i]
    therm = therms[i] 

    data = readdlm(files[i],',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]

    obslabel = L"Q"

    plt,τmax,τexp = MadrasSokal.publication_plot(Q,obslabel,therm)
    title = latexstring(L"\beta = %$(β[i]), ~~ T \times L^3 = %$(T[i]) \times %$(L[i])^3")

    plot!(plt,size=(800,300),plot_title=title)  
    display(plt)

    dir = "plots/topology_publication"
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))

    #plt = autocorrelation_overview(Q,obslabel,therm;with_exponential=true)
    #plot!(plt,plot_title=basename(file))
    #display(plt)
    
    #dir = "plots/dial_topological_charge"
    #isdir(dir) || mkdir(dir)
    #savefig(joinpath(dir,basename(file)*".pdf"))
end
