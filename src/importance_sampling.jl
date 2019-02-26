

function log_importance_weights!(x::AbstractVector{T}; sorted::Bool = false) where T <: Real
    x .= -x .- maximum(-x)
    x .= sorted ? x : sort(x, alg = SortingAlgorithms.RadixSort)

    M = ceil(Int, min(length(x) / 5, 3 * sqrt(5)))

    largest_weights = @view x[length(x) - M + 1:end]
    cutoff = x[length(x) - M]
    pareto_fit = fit(Distributions.GeneralizedPareto, exp.(largest_weights) .- exp(cutoff), 
                     sorted = true)

    largest_weights .= log.(quantile.(pareto_fit, (((1:M) .- 0.5) / M)) .+ exp(cutoff))

    return x
end