using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
using DelimitedFiles
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm)
gr(tickfontsize=10,labelfontsize=12,titlefontsize=14)

function _parameters_from_filename(file)
    info = split(replace(file,r"[A-Za-z,_,//]+" => " "))[2:end]
    T, L = parse.(Int,info[1:2])
    β, amf0, amas0 = parse.(Float64,info[3:end]) 
    amf0  *= -1
    amas0 *= -1
    return T, L, β, amf0, amas0
end
function _wilson_flow_scale_from_file(file)
    header    = readline(file)
    ω0_string = replace(header,"=" => " ", "+/-" => " ", r"[(,)]"=>" ")
    ω0, Δω0   = parse.(Float64,split(ω0_string)[end-1:end])
    return ω0, Δω0
end
function _binned_mean_std(O;bin=1)
    mO = mean(O)
    sO = std(O)/sqrt( length(O) / bin )
    return mO, sO
end 

# output from DiaL
files   = readdir("../flow_analysis/outputDiaL",join=true) 
outfile = joinpath("output","topology.csv")
io      = open(outfile,"w")
write(io,"beta,am0f,am0as,Nt,Ns,Nconf,w0,Delta_w0,Q,ΔQ\n")

for file in files

    T, L, β, amf0, amas0 = _parameters_from_filename(file)
    
    therm = 1 
    T == 48 && L == 20 && (therm = 108) # special case thermalisation for T=48 L=20
    T == 64 && L == 32 && (therm = 85)  # special case thermalisation for L=32
    
    β ≈ 6.5 || continue # for now only study enembles with β=6.5
        
    data = readdlm(file,',';skipstart=1)
    cfgn, Q = Int.(data[:,1]), data[:,2]
    
    obslabel = L"Q"
    plt,τmax,τexp = MadrasSokal.publication_plot(Q,obslabel,therm)
    title = latexstring(L"\beta = %$β, ~~ N_t \times N_s^3 = %$T \times %$(L)^3")
    
    # calculate average topological charge (with binning)
    ω0, Δω0 = _wilson_flow_scale_from_file(file)
    mQ, sQ  = _binned_mean_std(Q[therm:end],bin=2)
    Ncfg    = length(Q)-therm+1
    
    write(io,"$β,$amf0,$amas0,$T,$L,$Ncfg,$ω0,$Δω0,$mQ,$sQ\n")

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