struct LooResult
    elpd::Float64
    lpd::Float64
    k::Vector{Float64}
end

elpd(loo::LooResult) = loo.elpd
lpd(loo::LooResult) = loo.lpd
looic(loo::LooResult) = -2 * elpd(loo)
p_loo(loo::LooResult) = lpd(loo) - elpd(loo)