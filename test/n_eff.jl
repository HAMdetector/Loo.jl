@testset "B_variance(::AbstractVector{AbstractVector{<: Real}})" begin
    a = [1, 1, 1, 1, 0, 0, 0, 0, 1]
    b = [0, 1, 0, 1, 1, 1, 1, 1, 1]
    c = [0, 1, 1, 1, 1, 1, 1, 1, 1]
    d = [1, 0, 1, 0, 1, 0, 1, 0, 1]

    theta_m = mean([mean(a), mean(b), mean(c), mean(d)])
    B_expected = 9/3 * ((mean(a) - theta_m)^2 + (mean(b) - theta_m)^2 + 
                        (mean(c) - theta_m)^2 + (mean(d) - theta_m)^2)

    @test Loo.B_variance([a, b, c, d]) ≈ B_expected
end

@testset "W_variance(::AbstractVector{AbstractVector{<: Real}})" begin
    a = [1, 1, 1, 1, 0, 0, 0, 0, 1]
    b = [0, 1, 0, 1, 1, 1, 1, 1, 1]
    c = [0, 1, 1, 1, 1, 1, 1, 1, 1]
    d = [1, 0, 1, 0, 1, 0, 1, 0, 1]

    variances = [var(a), var(b), var(c), var(d)]
    W_expected = mean(variances)

    @test Loo.W_variance([a, b, c, d]) ≈ W_expected
end

@testset "N_eff(::AbstractVector{AbstractVector{<: Real}})" begin
    Random.seed!(1234)

    x = Vector{Vector{Float64}}()
    for c in 1:4
        push!(x, Float64[])
        for i in 1:100
            push!(x[c], rand(Distributions.Normal(0.01 * i, 1)))
        end
    end

    @test Loo.N_eff(x) ≈ 233.87364356034098
end

@testset "r_eff calculations" begin
    r_effs = DataFrame(
        CSV.File(joinpath(@__DIR__, "data", "example_r_effs.csv"))
    )[!, :r_effs]
    a = example_loglik_array()

    for i in 1:size(a, 3)
        r_eff = Loo.N_eff([exp.(a[:, 1, i]), exp.(a[:, 2, i])]) / 1000
        @test r_effs[i] ≈ r_eff
    end
end