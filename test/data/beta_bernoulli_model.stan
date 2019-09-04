data {
    int<lower=0> N;
    int<lower=0, upper=1> y[N];
}

parameters {
    real<lower=0, upper=1> theta;
}

model {
    theta ~ beta(1, 1);
    y ~ bernoulli(theta);
}

generated quantities {
    real log_lik[N];

    for (i in 1:N){
        log_lik[i] = bernoulli_lpmf(y[i] | theta);     
    }
}