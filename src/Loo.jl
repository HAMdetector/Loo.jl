module Loo

using Statistics, LinearAlgebra, Base.Threads
import Distributions, SortingAlgorithms, StatsFuns

include("fit_pareto.jl")
include("importance_sampling.jl")

end # module
