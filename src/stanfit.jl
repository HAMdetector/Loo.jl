function loo(sf::StanInterface.Stanfit; log_lik_name = "log_lik")
    N = count(x -> startswith(x.first, log_lik_name * "."), sf.result[1])

    elpd = Vector{Float64}(undef, N)
    lpd = Vector{Float64}(undef, N)

    @threads for i in 1:N
        loo = pointwise_loo([x[string(log_lik_name, ".", i)] for x in sf.result])
        elpd[i] = loo[:elpd]
        lpd[i] = loo[:lpd]
    end

    elpd = sum(elpd)
    lpd = sum(lpd)

    return (elpd = elpd, looic = -2 * elpd, p_loo = lpd - elpd)
end