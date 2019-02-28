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

# @testset "RCall log_importance_weights(x::AbstractVector{<: Real}" begin
#     R"""
#     suppressPackageStartupMessages(library("loo"))

#     m <- loo:::example_loglik_matrix()
#     psis <- suppressMessages(loo:::do_psis(-m, r_eff = rep(1, ncol(m)), cores = 1))
#     R_weights <- psis$log_weights
#     """

#     @rget m R_weights

#     julia_weights = similar(m)
#     for i in 1:size(m, 2)
#         julia_weights[:, i] = Loo.log_importance_weights(m[:, i])
#         @test julia_weights[:, i] ≈ R_weights[:, i]
#     end
# end

@testset "elpd(::AbstractVector{<: Real}, ::AbstractVector{<: Real}" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), header = 0, 
                allowmissing = :none)
    R_loo = CSV.read(joinpath("data", "example_loo.csv"), allowmissing = :none)

    julia_elpd = [Loo.elpd(m[:, i]) for i in 1:size(m, 2)]

    @test julia_elpd ≈ R_loo[:, 1]
end

# @testset "RCall elpd(::AbstractVector{<: Real})" begin
#     R"""
#     suppressPackageStartupMessages(library("loo"))
#     library("matrixStats")

#     m <- loo:::example_loglik_matrix()
#     R_elpd <- suppressWarnings(loo(m)[["pointwise"]][, 1])
#     """

#     @rget m R_elpd

#     julia_elpd = [Loo.elpd(m[:, i]) for i in 1:size(m, 2)]
    
#     @test julia_elpd ≈ R_elpd
# end