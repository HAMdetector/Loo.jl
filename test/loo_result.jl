@testset "LooResult" begin
    rng = StableRNG(1234)
    m = example_loglik_matrix()
    result = Loo.loo(m; rng=rng)

    @test elpd(result) ≈ -83.61405733876
    @test elpd_se(result) ≈ 4.2899426068
    @test p_loo(result) ≈ 3.3536292132
    @test p_loo_se(result) ≈ 1.1599075083
    @test looic(result) ≈ 167.2281146775
    @test looic_se(result) ≈ 8.5798852136

    model_file = joinpath(@__DIR__, "data", "normal_model.stan")
    y = randn(20)
    y[1] = 10 # this datapoint leads to high pareto k values
    sf = @suppress stan(model_file, Dict("y" => y, "N" => length(y)))
    loo_result = Loo.loo(sf, rng=rng)

    @test loo_result isa Loo.LooResult
    @test pareto_k(loo_result)[1] > 1
end

@testset "loo_compare(::LooResult, ::LooResult)" begin
    rng = StableRNG(1234)

    m = example_loglik_matrix()
    loo_1 = Loo.loo(m)
    loo_2 = Loo.loo(m .+ rand(rng, 1000, 32))

    diff = Loo.compare(loo_1, loo_2)
    @test diff.elpd_diff ≈ -14.630083639373716
    @test diff.se_diff ≈ 0.05675334280063688

end
