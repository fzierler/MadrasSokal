function parse_filename(file)
    str = replace(file,r"[a-z,A-Z,/,_]"=>" ",".."=>" ")
    val = parse.(Float64,split(str))
    T, L, beta, mf,  mas = Int(val[1]), Int(val[2]), val[3], -val[4], -val[5]
    return T, L, beta, mf,  mas
end
function parse_ω0(line)
    str = replace(line,r"[a-z,A-Z,,,=,+,--,/,(,)]"=>" ")
    ω0, Δω0 = parse.(Float64,split(str))[2:3]
    return ω0, Δω0
end
function stdmean(X,dims;bin=1)
    N = size(X)[dims]
    m = dropdims(mean(X;dims);dims)
    s = dropdims(std(X;dims);dims)/sqrt(N/bin)
    return m, s
end
function stdmean(X;bin=1)
    N = length(X)
    m = mean(X)
    s = std(X)/sqrt(N/bin)
    return m, s
end
function plaquettes_tursa(file)
    plaquettes = Float64[]
    configurations = Int64[]
    for line in eachline(file)
        p = findfirst("Plaquette",line)
        line = line[p[end]+2:end]
        line = replace(line,"[" =>" ")
        line = replace(line,"]" =>" ")
        data =  split(line)
        append!(configurations,parse(Int64,data[1]))
        append!(plaquettes,parse(Float64,data[2]))
    end
    perm = sortperm(configurations)
    permute!(plaquettes,perm)
    permute!(configurations,perm)
    # only keep one value for every configurations
    # unique indices
    _unique_indices(x) = unique(i -> x[i],1:length(x))
    inds = _unique_indices(configurations)
    configurations = getindex(configurations,inds)
    plaquettes = getindex(plaquettes,inds)
    return configurations, plaquettes
end
