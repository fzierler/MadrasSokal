using DelimitedFiles
using MadrasSokal

files  = readdir("../flow_analysis/outputDiaL",join=true) 
io = open("output/table.csv","w")
write(io,"beta,T,L,mf,mas,ω0,Δω0,p,Δp,Q,ΔQ,first,last,skip,Nconf\n")

for file in files

    T, L, beta, mf,  mas = parse_filename(file)
    header  = readline(file)
    ω0, Δω0 = parse_ω0(header)
    # get data for plaquette and topological charge
    data = readdlm(file,',',skipstart=1)
    traj = Int.(data[:,1])
    topo = data[:,2]
    plaq = data[:,3]
    # first and last configuration
    Nfirst, Nlast = extrema(traj)
    Nskip = traj[2] - traj[1]
    Nconf = length(traj)
    # get averages
    p, Δp = stdmean(plaq;bin=2)
    Q, ΔQ = stdmean(topo;bin=2)
    # calculate autocorrelation times
    τP, ΔτP = madras_sokal_time(plaq)
    τQ, ΔτQ = madras_sokal_time(topo)
    # write to csv file
    write(io,"$beta,$T,$L,$mf,$mas,$ω0,$Δω0,$p,$Δp,$Q,$ΔQ,$Nfirst,$Nlast,$Nskip,$Nconf\n")
end
close(io)

