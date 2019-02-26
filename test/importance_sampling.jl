@testset "log_importance_weights!(x::AbstractVector{T}) where T <: Real" begin
    m = CSV.read(joinpath("data", "example_loglik_matrix.csv"), 
                 header = 0, allowmissing = :none)
    log_weight_results = CSV.read(joinpath("data", "log_weight_results.csv"),
                                  header = 0, allowmissing = :none)

    for i in 1:size(log_weight_results, 2)
        @test Loo.log_importance_weights!(m[i]) ≈ log_weight_results[i]
    end
end