data {
    int N;
    array[N] real y;
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
    array[N] real log_lik;

    for (i in 1:N)
        log_lik[i] = normal_lpdf(y[i] | mu, sigma);
}
