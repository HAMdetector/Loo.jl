data {
    real y[10];
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
    real log_lik[10];

    for (i in 1:10)
        log_lik[i] = normal_lpdf(y[i] | mu, sigma);
}