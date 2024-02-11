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