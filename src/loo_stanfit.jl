global StanInterface_loaded = true

function loo(sf::StanInterface.Stanfit; log_lik_name = "log_lik")
    N = count(x -> startswith(x.first, log_lik_name * "."), sf.result[1])
    pw = Vector{PointwiseLoo}(undef, N)

    for i in 1:N
        pw[i] = pointwise_loo([x[string(log_lik_name, ".", i)] for x in sf.result])
    end

    return LooResult(pw, (sf.chains * sf.iter, N))
end