using Loo, Test, StableRNGs, StanInterface, Suppressor, HypothesisTests
import CSV, Distributions, Random
import DataFrames: DataFrame
import Statistics: mean, var

function example_loglik_matrix()
    df = CSV.File(joinpath(@__DIR__, "data", "example_loglik_matrix.csv"), header = 0) |>  
        DataFrame

    return Matrix(df)
end

function example_loglik_array()
    m = example_loglik_matrix()
    a = Array{Float64}(undef, 500, 2, 32)
    
    for i in 1:size(m, 2)
        chain_1 = m[1:500, i]
        chain_2 = m[501:1000, i]

        a[:, 1, i] .= chain_1
        a[:, 2, i] .= chain_2
    end

    return a
end


include("fit_pareto.jl")
include("n_eff.jl")
include("importance_sampling.jl")
include("loo_result.jl")
include("loo_posterior.jl")
