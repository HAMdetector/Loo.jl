struct PointwiseLoo
    elpd::Float64
    mcse_elpd::Float64
    lpd::Float64
    pareto_k::Float64
end

elpd(pw::PointwiseLoo) = pw.elpd
mcse_elpd(pw::PointwiseLoo) = pw.mcse_elpd
lpd(pw::PointwiseLoo) = pw.lpd
pareto_k(pw::PointwiseLoo) = pw.pareto_k
looic(pw::PointwiseLoo) = -2 * elpd(pw)
p_loo(pw::PointwiseLoo) = lpd(pw) - elpd(pw)
