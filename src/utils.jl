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
function errorstring(x,Δx;nsig=2)
    @assert Δx > 0
    sgn = x < 0 ? "-" : ""
    x = abs(x)  
    # round error part to desired number of signficant digits
    # convert to integer if no fractional part exists
    Δx_rounded = round(Δx,sigdigits=nsig) 
    # get number of decimal digits for x  
    floor_log_10 = floor(Int,log10(Δx))
    dec_digits   = (nsig - 1) - floor_log_10
    # round x, to desired number of decimal digits 
    # (standard julia function deals with negative dec_digits) 
    x_rounded = round(x,digits=dec_digits)
    # get decimal and integer part if there is a decimal part
    if dec_digits > 0
        digits_val = Int(round(x_rounded*10.0^(dec_digits)))
        digits_unc = Int(round(Δx_rounded*10.0^(dec_digits)))
        str_val = _insert_decimal(digits_val,dec_digits) 
        str_unc = _insert_decimal(digits_unc,dec_digits)
        str_unc = nsig > dec_digits ? str_unc : string(digits_unc)
        return sgn*"$str_val($str_unc)"
    else
        return sgn*"$(Int(x_rounded))($(Int(Δx_rounded)))"
    end
end
function _insert_decimal(val::Int,digits)
    str = lpad(string(val),digits,"0")
    pos = length(str) - digits
    int = rpad(str[1:pos],1,"0")
    dec = str[pos+1:end]
    inserted = int*"."*dec
    return inserted
end
