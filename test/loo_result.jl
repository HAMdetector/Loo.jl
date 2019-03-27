@testset "Loo struct" begin
    loo = Loo.LooResult(1.0, 2.0, [1.0, 2.0])

    @test loo isa Loo.LooResult
    @test elpd(loo) == 1.0
    @test lpd(loo) == 2.0
    @test p_loo(loo) == 1.0
    @test looic(loo) == -2
end