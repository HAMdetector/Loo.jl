@testset "loo_posterior(::Stanfit)" begin
    sf = @suppress stan(binary_path, Dict("y" => Random.randn(10)), chains = 1, iter = 1000)
    
    @test sf isa StanInterface.Stanfit
end