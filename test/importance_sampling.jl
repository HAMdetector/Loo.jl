@testset "log_importance_weights(x::AbstractVector{<: Real})" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), header = 0, 
                 allowmissing = :none)
    R_log_weights = CSV.read(joinpath("data", "example_log_weights.csv"), 
                             allowmissing = :none)

    for i in 1:size(m, 2)
        log_weights = Loo.log_importance_weights(m[:, i])
        @test log_weights ≈ R_log_weights[:, i]
    end
end

@testset "log_importance_weights(::AbstractVector{<: AbstractVector{<: Real}})" begin
    a = example_loglik_array()
    R_log_weights = CSV.read(joinpath("data", "example_log_weights_n_eff.csv"),
                             allowmissing = :none)
    
    for i in 1:size(a, 3)
        log_weights = Loo.log_importance_weights([a[:, 1, i], a[:, 2, i]])
        @test log_weights ≈ R_log_weights[:, i]
    end
end

@testset "elpd(::AbstractVector{<: Real}, ::AbstractVector{<: Real}" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), header = 0, 
                allowmissing = :none)
    R_loo = CSV.read(joinpath("data", "example_loo.csv"), allowmissing = :none)

    julia_elpd = [Loo.elpd(m[:, i]) for i in 1:size(m, 2)]

    @test julia_elpd ≈ R_loo[:, 1]
end


@testset "lpd(::AbstractVector{<: Real})" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), header = 0, 
                allowmissing = :none)
    R_loo = CSV.read(joinpath("data", "example_loo.csv"), allowmissing = :none)

    julia_lpd = [Loo.lpd(m[:, i]) for i in 1:size(m, 2)]
    R_lpd = R_loo[:, 3] .+ R_loo[:, 1]

    @test julia_lpd ≈ R_lpd
end

@testset "loo(::AbstractMatrix)" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), header = 0, 
            allowmissing = :none)
    R_elpd = -83.61405733876134
    R_p_loo = 3.353629213182125

    julia_loo = Loo.loo(Matrix(m))
    @test julia_loo.elpd ≈ R_elpd
    @test julia_loo.p_loo ≈ R_p_loo
end