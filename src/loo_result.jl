struct LooResult
    pointwise_loo::Vector{PointwiseLoo}
    size::Tuple{Int, Int}
end

elpd(loo::LooResult) = sum(x -> elpd(x), loo.pointwise_loo)
elpd_se(loo::LooResult) = sqrt(var(elpd.(loo.pointwise_loo)) * loo.size[2])

lpd(loo::LooResult) = sum(x -> lpd(x), loo.pointwise_loo)

looic(loo::LooResult) = -2 * elpd(loo)
looic_se(loo::LooResult) = sqrt(var(looic.(loo.pointwise_loo)) * loo.size[2])

p_loo(loo::LooResult) = lpd(loo) - elpd(loo)
p_loo_se(loo::LooResult) = sqrt(var(p_loo.(loo.pointwise_loo)) * loo.size[2])

mcse_elpd(loo::LooResult) = sum(x -> mcse_elpd(x) ^ 2, loo.pointwise_loo) |> sqrt
pareto_k(loo::LooResult) = map(x -> pareto_k(x), loo.pointwise_loo)

function Base.show(io::IO, loo::LooResult)
    if get(io, :compat, true)
        loo_print = string("LooResult(elpd=", round(elpd(loo), digits = 1),
                           ", elpd_se=", round(mcse_elpd(loo), digits = 1), ")")
        print(io, loo_print)
        return nothing
    end

    data =  ["elpd_loo" elpd(loo) elpd_se(loo);
             "p_loo" p_loo(loo) p_loo_se(loo);
             "looic" looic(loo) looic_se(loo);]

    print(io, "\r\n")
    println(io, "Computed from a $(loo.size[1]) by $(loo.size[2]) log-likelihood matrix")
    print(io, "\r\n")
    pretty_table(data, [" ", "Estimate", "SE"], borderless, header_crayon = crayon"reset",
                 formatter = ft_round(2, [2, 3]))
    print(io, "\r\n")
    print(io, "Monte Carlo SE of elpd_loo is $(round(mcse_elpd(loo), digits = 1)).")
    println(io, "\r\n")

    if all(pareto_k(loo) .<= 0.5)
        print(io, "All Pareto k estimates are good (k < 0.5).")
    else
        println(io, "Pareto k diagnostic values:")

        pretty_table(pareto_diagnostics(loo), ["", "", "Count", "Pct."], 
                     borderless, header_crayon = crayon"reset",
                     formatter = Dict(4 => (v, i) -> "$(round(v * 100, digits = 1))%"))
    end
end

function pareto_diagnostics(loo::LooResult)
    good_count = count(x -> x .<= 0.5, pareto_k(loo))
    ok_count = count(x -> 0.5 < x <= 0.7, pareto_k(loo))
    bad_count = count(x -> 0.7 < x <= 1, pareto_k(loo))
    very_bad_count = count(x -> x > 1, pareto_k(loo))
    N = length(pareto_k(loo))

    counts = ["(-Inf, 0.5]" "(good)" good_count good_count / N;
              "(0.5, 0.7]" "(ok)" ok_count ok_count / N;
              "(0.7, 1]" "(bad)" bad_count bad_count / N;
              "(1, Inf)" "(very bad)" very_bad_count very_bad_count / N;]

    return counts
end