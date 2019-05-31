@testset "fit(::GeneralizedPareto, x::Vector{<:Real})" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), header = 0)
    R_pareto_fit = CSV.read(joinpath("data", "example_pareto_fit.csv"))

    for i in 1:size(m, 2)
        fit = Loo.fit(Distributions.GeneralizedPareto, exp.(m[:, i]))
        @test fit.σ ≈ R_pareto_fit[:sigma][i]
        @test fit.ξ ≈ R_pareto_fit[:k][i]
    end
end