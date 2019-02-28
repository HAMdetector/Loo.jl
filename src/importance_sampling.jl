
function log_importance_weights(log_lik::AbstractVector{T}) where T <: Real
    x = copy(log_lik)
    x .= -x .- maximum(-x)
    sort_indices = sortperm(x, alg = SortingAlgorithms.TimSort)

    M = ceil(Int, min(length(x) / 5, 3 * sqrt(length(x))))

    largest_weights = @view x[sort_indices[length(x) - M + 1:end]]
    cutoff = x[sort_indices[length(x) - M]]
    pareto_fit = fit(Distributions.GeneralizedPareto, exp.(largest_weights) .- exp(cutoff), 
                     sorted = true)

    largest_weights .= log.(quantile.(pareto_fit, (((1:M) .- 0.5) / M)) .+ exp(cutoff))
    #largest_weights[largest_weights .>= 0] .= 0
    return x
end

function elpd(log_lik::AbstractVector{T}) where T <: Real
    log_weights = log_importance_weights(log_lik)
    
    return elpd(log_lik, log_weights)
end

function elpd(log_lik::AbstractVector{T}, log_weights::AbstractVector{T}) where T <: Real
    normalized_lw = log_weights .- StatsFuns.logsumexp(log_weights)
    x = StatsFuns.logsumexp(log_lik .+ normalized_lw)
    # y = StatsFuns.logsumexp(log_weights)

    # return x - y
end