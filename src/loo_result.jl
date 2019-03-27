struct LooResult
    elpd::Float64
    lpd::Float64
    k::Vector{Float64}
    size::Tuple{Int, Int}
end

elpd(loo::LooResult) = loo.elpd
lpd(loo::LooResult) = loo.lpd
looic(loo::LooResult) = -2 * elpd(loo)
p_loo(loo::LooResult) = lpd(loo) - elpd(loo)

# function Base.show(io::IO, loo::LooResult)
#     print(io, "LooResult($(elpd(loo)), $(lpd(loo)), $(maximum(loo.k)))")
# end

function Base.show(io::IO, loo::LooResult)
    data =  ["elpd_loo" elpd(loo) "X";
             "p_loo" p_loo(loo) "X";
             "looic" looic(loo) "X";]

    print(io, "\r\n")
    println(io, "Computed from a $(loo.size[1]) by $(loo.size[2]) log-likelihood matrix")
    print(io, "\r\n")
    pretty_table(data, [" ", "Estimate", "SE"], borderless, header_crayon = crayon"reset")
    print(io, "\r\n")
    print(io, "Monte Carlo SE of elpd_loo is X.")
    println(io, "\r\n")

    if all(loo.k .<= 0.5)
        print(io, "All Pareto k estimates are good (k < 0.5).")
    else
        println(io, "Pareto k diagnostic values:")

        pretty_table(pareto_diagnostics(loo), ["", "", "Count", "Pct."], 
                     borderless, header_crayon = crayon"reset",
                     formatter = Dict(4 => (v, i) -> "$(round(v * 100, digits = 1))%"))
    end
end

function pareto_diagnostics(loo::LooResult)
    good_count = count(x -> x .<= 0.5, loo.k)
    ok_count = count(x -> 0.5 < x <= 0.7, loo.k)
    bad_count = count(x -> 0.7 < x <= 1, loo.k)
    very_bad_count = count(x -> x > 1, loo.k)
    N = length(loo.k)

    data = ["(-Inf, 0.5]" "(good)" good_count good_count / N;
            "(0.5, 0.7]" "(ok)" ok_count ok_count / N;
            "(0.7, 1]" "(bad)" bad_count bad_count / N;
            "(1, Inf)" "(very bad)" very_bad_count very_bad_count / N;]
end