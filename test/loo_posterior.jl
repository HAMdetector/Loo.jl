@testset "loo_posterior(::Stanfit, ::Int)" begin
    function quantile_interval(x::Vector; q::Real = 0.95)
        sorted = sort(x)
        lower_idx = round(Int, ((1 - q) / 2) * length(x))
        upper_idx = round(Int, (1 - ((1 - q) / 2)) * length(x))

        lower = sorted[lower_idx]
        upper = sorted[upper_idx]

        return (lower, upper)
    end

    function interval_width(interval::Tuple{Float64, Float64})
        return interval[2] - interval[1]
    end

    sf = @suppress stan(joinpath(@__DIR__, "data", "normal_model"), 
                        Dict("y" => Random.randn(1000)), chains = 1, iter = 5000)
    @test sf isa StanInterface.Stanfit

    posterior = extract(sf)
    posterior_interval = quantile_interval(posterior["mu"])

    loo_posterior = Loo.loo_posterior(sf, 1)
    loo_interval = quantile_interval(loo_posterior["mu"])

    @test interval_width(posterior_interval) < interval_width(loo_interval)
end