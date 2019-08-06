function loo_posterior(sf::StanInterface.Stanfit, i::Int; log_lik_name::String = "log_lik")
    posterior = StanInterface.extract(sf)
    ll = copy(posterior[log_lik_name * ".$i"])
    k, lw = log_importance_weights!(ll)
    w = exp.(lw)

    indices = sample(1:length(ll), Weights(w), length(ll))

    for (k, v) in posterior
        posterior[k] .= posterior[k][indices]
    end

    return posterior
end