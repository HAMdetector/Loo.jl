@testset "fit(::GeneralizedPareto, x::Vector{<:Real})" begin
    pareto_samples = CSV.read(joinpath("data", "pareto_samples.csv"), header = 0,
                              allowmissing = :none)

    # generated by the R loo package
    expected_sigma = [0.199, 1.975, 4.67, 0.94, 1.477]
    expected_k = [0.079, 0.304, 0.546, 0.676, 1.977]

    for i in 1:5
        d = Loo.fit(Distributions.GeneralizedPareto, pareto_samples[i])
        @test round(d.ξ, digits = 3) ≈ expected_k[i]
        @test round(d.σ, digits = 3) ≈ expected_sigma[i]
    end
end