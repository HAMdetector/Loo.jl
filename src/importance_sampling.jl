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

function pointwise_loo(x::AbstractVector{<: AbstractVector})
    ll = vcat(x...)
    N_eff = Loo.N_eff([exp.(v) for v in x])
    k, lw = log_importance_weights(ll, N_eff = N_eff)

    elpd = Loo.elpd(ll, lw)
    lpd = Loo.lpd(ll)
    # var_epd_i = sum((exp.(lw) .^ 2) .* (exp.(ll) .- exp.(elpd)) .^ 2)
    # sd_epd_i = sqrt(var_epd_i)

    # println(var_epd_i)
    # println(sd_epd_i)
    return (elpd = elpd, lpd = lpd, looic = -2 * elpd, p_loo = lpd - elpd, k = k)
end

function pointwise_loo(x::AbstractVector)
    ll = x
    k, lw = log_importance_weights(ll)

    elpd = Loo.elpd(ll, lw)
    lpd = Loo.lpd(ll)
    var_epd_i = sum((exp.(lw) .^ 2) .* (exp.(ll) .- exp.(elpd)) .^ 2)
    println("elpd: $elpd")
    println("lpd: $lpd")
    println("var_epd_i: $var_epd_i")
    println("w: $(exp.(lw[1:5]))")
    println("ll: $(ll[1:5])")
end

function loo(m::AbstractMatrix)
    elpd = Vector{Float64}(undef, size(m, 2))
    lpd = Vector{Float64}(undef, size(m, 2))

    @threads for col in 1:size(m, 2)
        _, elpd[col] = Loo.elpd(m[:, col])
        lpd[col] = Loo.lpd(m[:, col])
    end

    elpd = sum(elpd)
    lpd = sum(lpd)

    return (elpd = elpd, looic = -2 * elpd, p_loo = lpd - elpd)
end