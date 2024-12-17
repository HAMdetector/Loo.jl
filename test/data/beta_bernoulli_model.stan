data {
    int<lower=0> N;
    array[N] int<lower=0, upper=1> y;
}

parameters {
    real<lower=0, upper=1> theta;
}

model {
    theta ~ beta(1, 1);
    y ~ bernoulli(theta);
}

generated quantities {
    array[N] real log_lik;

    for (i in 1:N){
        log_lik[i] = bernoulli_lpmf(y[i] | theta);     
    }
}
