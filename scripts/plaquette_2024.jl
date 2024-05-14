using Pkg; Pkg.activate(".")
using MadrasSokal
using Plots
using Distributions
using LaTeXStrings
include("tools.jl")
gr(fontfamily="Computer Modern", frame=:box, top_margin=4Plots.mm, left_margin=4Plots.mm,tickfontsize=10,labelfontsize=12)

function _parse_filename(filename)
    fn = replace(filename,"p"=>".")
    fn = replace(fn,r"[a-z]"=>"")
    val = parse.(Float64,split(fn,"_"))
    β, mf, mas, T, L = val[1], -val[2], -val[3], Int(val[4]), Int(val[5])
    return β, mf, mas, T, L
end

dir = "/home/fabian/Documents/DataDiaL/PlaquettesNew/plaqs"
obslabel = L"\langle P ~ \rangle"

files  = readdir(dir,join=true)
filter!(x->!contains(x,"nl16"),files)
filter!(x->!contains(x,"nl20"),files)

therms = 10*ones(Int,length(files))


for (i,file) in enumerate(files)
    therm = therms[i]
    configurations, plaq = plaquettes_grid(file)
    
    β, mf, mas, T, L = _parse_filename(basename(file))
    title = latexstring(L"\beta\!=\!%$(β),-(m_{0}^{\rm f},m_{0}^{\rm as})\!=\!(%$(-mf),%$(-mas)), N_t \!\! \times \!\! N_s^3 \!=\! %$(T) \!\! \times \!\! %$(L)^3")
    
    plt2 = autocorrelation_overview(plaq,obslabel,therm;thermstep=50,minlags=1000,with_exponential=true)
    plot!(plt2,plot_title=title,titlefontsize=12)  
    display(plt2)    
end
