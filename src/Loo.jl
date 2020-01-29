module Loo

export elpd, lpd, looic, p_loo, elpd_se, looic_se, p_loo_se, mcse_elpd, pareto_k, loo

using Statistics, LinearAlgebra, Base.Threads, StatsBase, Requires, PrettyTables,
    StanInterface, Base.Threads
import Distributions, SortingAlgorithms, StatsFuns
import Base.show

global StanInterface_loaded = false

# function __init__()
#   @require StanInterface = "e89815f6-a2f7-11e8-0a3f-6d3140f294c6" include("loo_stanfit.jl")
#   @require StanInterface = "e89815f6-a2f7-11e8-0a3f-6d3140f294c6" include("loo_posterior.jl") 
# end

include("pointwise_loo.jl")
include("loo_result.jl")
include("fit_pareto.jl")
include("n_eff.jl")
include("importance_sampling.jl")
include("loo_stanfit.jl")
include("loo_posterior.jl")

end # module
