function N_eff(x::AbstractVector{T}) where T <: AbstractVector{<: Real}
    N = length(x[1])
    M = length(x)
    W = W_variance(x)
    B = B_variance(x)
    combined_variance = ((N - 1) / N) * W + (B / N)

    rho_hat(t) = 1 - (W - mean(autocov(m, [t - 1])[1] for m in x)) / combined_variance

    rho_sum = 0
    for t in 2:N
        rho = rho_hat(t)

        if rho < 0
            break
        end

        rho_sum = rho_sum + rho
    end

    N_eff = (N * M) / (1 + 2 * rho_sum)

    return N_eff
end

# between-chain variance 
function B_variance(x::AbstractVector{T}) where T <: AbstractVector{<: Real}
    chain_means = [mean(chain) for chain in x]
    mean_chain_means = mean(chain_means)

    N = length(x[1])
    M = length(x)

    return (N / (M - 1)) * sum((m - mean_chain_means)^2 for m in chain_means)
end

# within-chain variance
function W_variance(x::AbstractVector{T}) where T <: AbstractVector{<: Real}
    return mean(var(chain) for chain in x)
end