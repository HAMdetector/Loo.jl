using Loo, Test, StanInterface, Suppressor, HypothesisTests
import CSV, Distributions, Random
import Statistics: mean, var

function example_loglik_matrix()
    df = CSV.read(joinpath(@__DIR__, "data", "example_loglik_matrix.csv"), header = 0)

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

if !isfile(joinpath(@__DIR__, "data", "normal_model"))
    model_path = joinpath(@__DIR__, "data", "normal_model.stan")
    binary_path = joinpath(@__DIR__, "data", "normal_model")

    @suppress StanInterface.build_binary(model_path, binary_path)
end

# include("fit_pareto.jl")
# include("n_eff.jl")
# include("importance_sampling.jl")
# include("loo_result.jl")
include("loo_posterior.jl")