function fit(::Type{Distributions.GeneralizedPareto}, x::AbstractVector{T}; 
             sorted::Bool = false) where T <: Real

    x = sorted ? x : sort(x)
    x_star = x[div(length(x) + 2, 4)]
    n = length(x)
    m = 30 + floor(Int, sqrt(n))

    θ = Vector{Float64}(undef, m)
    l_θ = Vector{Float64}(undef, m)
    w_θ = Vector{Float64}(undef, m)
    aux1 = Vector{Float64}(undef, n)
    aux2 = Vector{Float64}(undef, m)

    @inbounds for j in 1:m
        θ[j] = 1 / x[n] + (1 - sqrt(m / (j - 0.5))) / (3 * x_star)
    end

    @inbounds for i in 1:m
        b = θ[i]
        @. aux1 = log1p(-b * x)
		k = mean(aux1)
		l_θ[i] = n * (log(-b / k) - k - 1)
    end

    @inbounds for j in 1:m
        @. aux2 = exp.(l_θ - l_θ[j])
        w_θ[j] = 1 / sum(aux2)
    end

    θ_hat = dot(θ, w_θ)
    @. aux1 = log1p(-θ_hat * x)

    ξ = mean(aux1)
    σ = -ξ / θ_hat
    ξ = (ξ * n + 5 ) / (n + 10)

    return Distributions.GeneralizedPareto(σ, ξ)
end