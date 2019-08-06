data {
    real y[1000];
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
    real log_lik[1000];

    for (i in 1:1000)
        log_lik[i] = normal_lpdf(y[i] | mu, sigma);
}