@testset "LooResult" begin
    m = example_loglik_matrix()
    result = Loo.loo(m)

    @test elpd(result) ≈ -83.61405733876
    @test elpd_se(result) ≈ 4.2899426068
    @test p_loo(result) ≈ 3.3536292132
    @test p_loo_se(result) ≈ 1.1599075083
    @test looic(result) ≈ 167.2281146775
    @test looic_se(result) ≈ 8.5798852136

    model_file = joinpath(@__DIR__, "data", "normal_model")
    Random.seed!(123)
    y = randn(20)
    y[1] = 10 # this datapoint leads to high pareto k values
    sf = @suppress stan(model_file, Dict("y" => y, "N" => length(y)))

    loo_result = Loo.loo(sf)
    @test loo_result isa Loo.LooResult
    @test pareto_k(loo_result)[1] > 1
end

@testset "loo_compare(::LooResult, ::LooResult)" begin
    m = example_loglik_matrix()
    loo_1 = Loo.loo(m)
    loo_2 = Loo.loo(m .+ rand(Random.seed!(123), 1000, 32))

    diff = Loo.compare(loo_1, loo_2)
    @test diff.elpd_diff ≈ -14.65635576411212
    @test diff.se_diff ≈ 0.06088157543557993

end