@testset "log_importance_weights(x::AbstractVector{<: Real})" begin
    m = CSV.File(joinpath(@__DIR__, "data", "example_loglik_matrix.csv"), header = 0) |>    
        DataFrame

    R_log_weights = CSV.File(joinpath(@__DIR__, "data", "example_log_weights.csv")) |>
        DataFrame

    for i in 1:size(m, 2)
        k, log_weights = Loo.log_importance_weights(m[:, i])
        @test log_weights ≈ R_log_weights[:, i]
    end
end

@testset "log_importance_weights(::AbstractVector{<: AbstractVector{<: Real}})" begin
    a = example_loglik_array()
    R_log_weights = CSV.File(joinpath(@__DIR__, "data", "example_log_weights_n_eff.csv")) |>
        DataFrame
    
    for i in 1:size(a, 3)
        k, log_weights = Loo.log_importance_weights([a[:, 1, i], a[:, 2, i]])
        @test log_weights ≈ R_log_weights[:, i]
    end
end

@testset "elpd(::AbstractVector{<: Real}, ::AbstractVector{<: Real}" begin
    m = CSV.File(joinpath(@__DIR__, "data", "example_loglik_matrix.csv"), header = 0) |>
        DataFrame
    R_loo = CSV.File(joinpath(@__DIR__, "data", "example_loo.csv")) |>
        DataFrame

    julia_elpd = [Loo.elpd(m[:, i])[2] for i in 1:size(m, 2)]

    @test julia_elpd ≈ R_loo[:, 1]
end

@testset "elpd(::AbstractVector{<: AbstractVector})" begin
    a = example_loglik_array()
    R_loo = CSV.File(joinpath(@__DIR__, "data", "example_loo_n_eff.csv")) |>
        DataFrame

    for i in 1:size(a, 3)
        k, julia_elpd = Loo.elpd([a[:, 1, i], a[:, 2, i]])
        @test julia_elpd ≈ R_loo[i, 1] 
    end
end

@testset "lpd(::AbstractVector{<: Real})" begin
    m = CSV.File(joinpath(@__DIR__, "data", "example_loglik_matrix.csv"), header = 0) |>
        DataFrame
    R_loo = CSV.File(joinpath(@__DIR__, "data", "example_loo.csv")) |> DataFrame

    julia_lpd = [Loo.lpd(m[:, i]) for i in 1:size(m, 2)]
    R_lpd = R_loo[:, 3] .+ R_loo[:, 1]

    @test julia_lpd ≈ R_lpd
end

@testset "pointwise_loo(::AbstractVector{<: AbstractVector})" begin
    rng = StableRNG(123)
    R_loo = CSV.File(joinpath(@__DIR__, "data", "example_loo_n_eff.csv")) |> DataFrame

    a = example_loglik_array()
    pw = []
    for i in 1:size(a, 3)
        pointwise = Loo.pointwise_loo([a[:, 1, i], a[:, 2, i]]; rng=rng)
        push!(pw, pointwise)
    end

    @test [elpd(x) for x in pw] ≈ R_loo[!, :elpd_loo]
    @test [p_loo(x) for x in pw] ≈ R_loo[!, :p_loo]
    @test [looic(x) for x in pw] ≈ R_loo[!, :looic]
    
    df = DataFrame(mcse_elpd=[x.mcse_elpd for x in pw])
    CSV.write(joinpath(@__DIR__, "data", "mcse_elpd_seed_123.csv"), df)

    mcse_elpd = CSV.File(joinpath(@__DIR__, "data", "mcse_elpd_seed_123.csv")) |>
        DataFrame
    @test [x.mcse_elpd for x in pw] ≈ mcse_elpd[!, :mcse_elpd]
end

@testset "loo(::AbstractMatrix)" begin
    m = CSV.File(joinpath(@__DIR__, "data", "example_loglik_matrix.csv"), header = 0) |>
        DataFrame
    R_elpd = -83.61405733876134
    R_p_loo = 3.353629213182125

    julia_loo = Loo.loo(Matrix(m))
    @test elpd(julia_loo) ≈ R_elpd
    @test p_loo(julia_loo) ≈ R_p_loo
end
