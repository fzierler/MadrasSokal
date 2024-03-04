module MadrasSokal

using Statistics
using LaTeXStrings
using Plots
using Distributions: fit, Normal, pdf
# include fitting for exponential autocorrelation time
using LsqFit

include("autocorrelation.jl")
export madras_sokal_time, madras_sokal_windows
include("plotting.jl")
export fit_histogram_plot, fit_histogram_plot!, autocorrelation_overview
include("serieshistogram.jl")
export serieshistogram
include("exponential.jl")
export exponential_autocorrelation_time
include("utils.jl")
export stdmean, parse_filename, parse_ω0, plaquettes_tursa, errorstring

end # module MadrasSokal
