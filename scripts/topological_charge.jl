using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
using DelimitedFiles
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

# output from DiaL
files   = readdir("../flow_analysis/outputDiaL",join=true) 
outfile = joinpath("output","topology.csv")
io      = open(outfile,"w")
write(io,"beta,am0f,am0as,Nt,Ns,Nconf,w0,Delta_w0,Q,Delta_Q,τint_Q,Delta_τint_Q\n")

for file in files

    T, L, β, amf0, amas0 = _parameters_from_filename(file)
    
    therm = 1 
    T == 48 && L == 20 && (therm = 150) # special case thermalisation for T=48 L=20
    T == 64 && L == 32 && (therm = 85)  # special case thermalisation for L=32
    
    β ≈ 6.5 || continue # for now only study enembles with β=6.5
        
    data = readdlm(file,',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]
    
    obslabel = L"Q"
    plt,τmax,Δτmax,τexp = MadrasSokal.publication_plot(Q,obslabel,therm)
    title = latexstring(L"\beta = %$β, ~~ N_t \times N_s^3 = %$T \times %$(L)^3")
    
    # calculate average topological charge (with binning)
    ω0, Δω0 = _wilson_flow_scale_from_file(file)
    mQ, sQ  = _binned_mean_std(Q[therm:end],bin=2)
    Ncfg    = length(Q)-therm+1
    
    write(io,"$β,$amf0,$amas0,$T,$L,$Ncfg,$ω0,$Δω0,$mQ,$sQ,$τmax,$Δτmax\n")

    dir = "plots/topology_publication"
    plot!(plt,size=(800,300),plot_title=title)  
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))

    dir = "plots/topology"
    plt = autocorrelation_overview(Q,obslabel,therm;with_exponential=true)
    plot!(plt,plot_title=title)   
    isdir(dir) || mkdir(dir)
    savefig(joinpath(dir,basename(file)*".pdf"))
    display(plt)
end

close(io)