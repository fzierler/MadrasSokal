using DelimitedFiles
using MadrasSokal
using Plots

files  = readdir("../flow_analysis/outputDiaLTests",join=true) 

for file in files

    T, L, beta, mf,  mas = parse_filename(file)
    header  = readline(file)
    ω0, Δω0 = parse_ω0(header)

    # get data for plaquette and topological charge
    data = readdlm(file,',',skipstart=1)
    traj = Int.(data[:,1])
    topo = data[:,2]
    plaq = data[:,3]

    therm=1
    plt1,τmax,τexp = MadrasSokal.publication_plot(plaq,"<P>",therm)
    plt2 = autocorrelation_overview(plaq,"<P>",therm;with_exponential=true)
    #display(plt1)
    display(plt2)

end

