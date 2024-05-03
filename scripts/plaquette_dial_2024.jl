using DelimitedFiles
using MadrasSokal
using Plots

files  = readdir("../flow_analysis/outputDiaLTests",join=true) 
therms  = [200,100,100,100,500]
nskip   = 1


for (i,file) in enumerate(files)

    T, L, beta, mf,  mas = parse_filename(file)
    header  = readline(file)
    ω0, Δω0 = parse_ω0(header)

    # get data for plaquette and topological charge
    data = readdlm(file,',',skipstart=1)
    traj = Int.(data[:,1])
    topo = data[:,2]
    plaq = data[:,3]
    plaq = plaq[1:nskip:end]

    therm=therms[i]
    plt1,τmax,τexp = MadrasSokal.publication_plot(plaq,"<P>",therm)
    plt2 = autocorrelation_overview(plaq,"<P>",therm;with_exponential=true)
    #display(plt1)
    display(plt2)

end

