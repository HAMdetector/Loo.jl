@testset "LooResult" begin
    m = example_loglik_matrix()
    result = Loo.loo(m)

    @test elpd(result) ≈ -83.61405733876
    @test elpd_se(result) ≈ 4.2899426068
    @test p_loo(result) ≈ 3.3536292132
    @test p_loo_se(result) ≈ 1.1599075083
    @test looic(result) ≈ 167.2281146775
    @test looic_se(result) ≈ 8.5798852136
end