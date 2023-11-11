module MadrasSokal

using Statistics
using Plots
using Distributions: fit, Normal, pdf

include("autocorrelation.jl")
export madras_sokal_time, madras_sokal_windows
include("plotting.jl")
export fit_histogram_plot, fit_histogram_plot!
include("serieshistogram.jl")
export serieshistogram

end # module MadrasSokal
