function log_importance_weights(log_lik::AbstractVector{<: AbstractVector})
    N_eff = Loo.N_eff([exp.(v) for v in log_lik])

    log_importance_weights!(vcat(log_lik...), N_eff = N_eff)
end

function log_importance_weights(log_lik::AbstractVector{T};
    N_eff::Union{Missing, <: Real} = missing) where T <: Real
    
    x = copy(log_lik)
    log_importance_weights!(x, N_eff = N_eff)
end

function log_importance_weights!(log_lik::AbstractVector{T};
    N_eff::Union{Missing, <: Real} = missing) where T <: Real
    log_lik .= -log_lik .- maximum(-log_lik)
    sort_indices = sortperm(log_lik, alg = SortingAlgorithms.TimSort)

    r_eff = ismissing(N_eff) ? 1.0 : N_eff / length(log_lik)
    M = ceil(Int, min(length(log_lik) / 5, 3 * sqrt(length(log_lik) / r_eff)))

    largest_weights = @view log_lik[sort_indices[length(log_lik) - M + 1:end]]
    cutoff = log_lik[sort_indices[length(log_lik) - M]]
    pareto_fit = fit(Distributions.GeneralizedPareto, exp.(largest_weights) .- exp(cutoff), 
                     sorted = true)

    largest_weights .= log.(quantile.(pareto_fit, (((1:M) .- 0.5) / M)) .+ exp(cutoff))

    return pareto_fit.ξ, log_lik
end

function elpd(log_lik::AbstractVector)
    k, log_weights = log_importance_weights(log_lik)

    return k, elpd(vcat(log_lik...), log_weights)
end

function elpd(log_lik::AbstractVector, log_weights::AbstractVector)
    normalized_lw = log_weights .- StatsFuns.logsumexp(log_weights)
    
    return StatsFuns.logsumexp(log_lik .+ normalized_lw)
end

function lpd(log_lik::AbstractVector{T}) where T <: Real
    return StatsFuns.logsumexp(log_lik) - log(length(log_lik))
end

function pointwise_loo(x::AbstractVector{<:Real}; rng::Random.AbstractRNG = Random.defualt_rng())
    return pointwise_loo(x, sum(length(v) for v in x); rng=rng)
end

function pointwise_loo(x::AbstractArray{<: AbstractVector}; rng::Random.AbstractRNG = Random.default_rng())
    N = N_eff([exp.(v) for v in x])

    return pointwise_loo(x, N; rng=rng)
end

function pointwise_loo(x::AbstractArray, N_eff::Real; rng::Random.AbstractRNG = Random.default_rng())
    N = sum(length(v) for v in x)
    ll = vcat(x...)
    k, lw = log_importance_weights(ll, N_eff = N_eff)

    elpd = Loo.elpd(ll, lw)
    lpd = Loo.lpd(ll)

    w = lw .- StatsFuns.logsumexp(lw)
    var_epd = sum((exp.(w) .^ 2) .* ((exp.(ll) .- exp.(elpd)) .^ 2))
    sd_epd = sqrt(var_epd)

    d = Distributions.Normal(exp(elpd), sd_epd)
    elpd_var = log.(filter(x -> x > 0, rand(rng, d, 10000))) |> var
    mcse_elpd = sqrt(elpd_var / (N_eff / N))

    return PointwiseLoo(elpd, mcse_elpd, lpd, k)
end

function loo(m::AbstractMatrix; rng::Random.AbstractRNG = Random.default_rng())
    pw = Vector{PointwiseLoo}(undef, size(m, 2))

    @threads for col in 1:size(m, 2)
        pw[col] = pointwise_loo(m[:, col]; rng=rng)
    end

    return LooResult(pw, size(m))
end
