@testset "fit(::GeneralizedPareto, x::Vector{<:Real})" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), header = 0, 
                 allowmissing = :none)
    R_pareto_fit = CSV.read(joinpath("data", "example_pareto_fit.csv"), 
                            allowmissing = :none)

    for i in 1:size(m, 2)
        fit = Loo.fit(Distributions.GeneralizedPareto, exp.(m[:, i]))
        @test fit.σ ≈ R_pareto_fit[:sigma][i]
        @test fit.ξ ≈ R_pareto_fit[:k][i]
    end
end

# @testset "RCall fit(::GeneralizedPareto, x::AbstractVector{<:Real})" begin
#     R"""
#     suppressPackageStartupMessages(library("loo"))
#     m = loo:::example_loglik_matrix()

#     R_sigma <- c()
#     R_k <- c()

#     for (i in 1:ncol(m)) {
#         fit <- loo:::gpdfit(exp(m[, i]))
#         R_sigma <- append(R_sigma, fit$sigma)
#         R_k <- append(R_k, fit$k)
#     }
#     """

#     @rget m R_sigma R_k

#     julia_sigma = Float64[]
#     julia_k = Float64[]

#     for i in 1:size(m, 2)
#         fit = Loo.fit(Distributions.GeneralizedPareto, exp.(m[:, i]))
#         push!(julia_sigma, fit.σ)
#         push!(julia_k, fit.ξ)
#     end

#     @test R_sigma ≈ julia_sigma
#     @test R_k ≈ julia_k
# end