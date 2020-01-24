data {
    int N;
    real y[N];
}

parameters {
    real mu;
    real<lower=0> sigma;
}

model {
    mu ~ normal(0, 1);
    sigma ~ normal(0, 1);

    y ~ normal(mu, sigma);
}

generated quantities {
    real log_lik[N];

    for (i in 1:N)
        log_lik[i] = normal_lpdf(y[i] | mu, sigma);
}