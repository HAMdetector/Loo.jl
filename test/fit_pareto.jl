@testset "fit(::GeneralizedPareto, x::Vector{<:Real})" begin
    m = CSV.read(joinpath(@__DIR__, "data", "example_loglik_matrix.csv"), header = 0)
    R_pareto_fit = CSV.read(joinpath(@__DIR__, "data", "example_pareto_fit.csv"))

    for i in 1:size(m, 2)
        fit = Loo.fit(Distributions.GeneralizedPareto, exp.(m[:, i]))
        @test fit.σ ≈ R_pareto_fit[i, :sigma]
        @test fit.ξ ≈ R_pareto_fit[i, :k]
    end
    
    rloo_gpdfit_x = CSV.read(joinpath(@__DIR__, "data", "rloo_gpdfit_x.csv"))[!, :x]
    fit = Loo.fit(Distributions.GeneralizedPareto, rloo_gpdfit_x)

    @test round(fit.ξ, digits = 8) ≈ 0.07036688
    @test round(fit.σ, digits = 6) ≈ 1.018298
end