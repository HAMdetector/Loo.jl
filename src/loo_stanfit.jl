function loo(
        sf::StanInterface.Stanfit; 
        log_lik_name = "log_lik", 
        rng::Random.AbstractRNG = Random.default_rng()
)
    parameters = keys(StanInterface.extract(sf))
    N = count(x -> startswith(x, log_lik_name * "."), parameters)
    pw = Vector{PointwiseLoo}(undef, N)

    f = x -> Dict((string(p[1]), collect(skipmissing(p[2]))) for p in pairs(x))
    results = [CSV.read(codeunits(x), comment = "#", f) for x in sf.results]

    @threads for i in 1:N
        pw[i] = pointwise_loo([res[string(log_lik_name, ".", i)] for res in results]; rng=rng)
    end
    
    chains = length(results)
    iter = length(results[1]["lp__"])

    return LooResult(pw, (chains * iter, N))
end
