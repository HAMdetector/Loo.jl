@testset "loo_posterior_indices(::AbstractVector{T}) where T <: Real" begin
    # loo posteriors are checked with a beta bernoulli model.
    # If the likelihood function is y ~ bernoulli(theta), and the prior on theta is
    # theta ~ beta(1, 1); (uniform), then with y = [0, 0, 1, 1], the full posterior on theta
    # should be theta ~ beta(3, 3). If the first or data point is left out, the loo posterior
    # should be theta ~ beta(3, 2), if the third or foruth data point is left out, the loo posterior
    # should be theta ~ beta(2, 3).

    stan_input = Dict("N" => 4, "y" => [0, 0, 1, 1])
    sf = @suppress stan(joinpath(@__DIR__, "data", "beta_bernoulli_model"), stan_input,
        iter = 40000, chains = 1)
    posterior = extract(sf)

    # full posterior
    ht = @suppress ApproximateTwoSampleKSTest(posterior["theta"], 
        rand(Distributions.Beta(3, 3), 40000))
        
    @test pvalue(ht) > 0.00001

    expected_distribution = [Distributions.Beta(3, 2), Distributions.Beta(3, 2),
        Distributions.Beta(2, 3), Distributions.Beta(2, 3)]

    for i in 1:4
        ll = posterior["log_lik.$i"]
        indices = Loo.loo_posterior_indices(ll)
        loo_posterior = posterior["theta"][indices]
        ht = @suppress ApproximateTwoSampleKSTest(loo_posterior, 
            rand(expected_distribution[i], 40000))

        @test pvalue(ht) > 0.000001
    end
end