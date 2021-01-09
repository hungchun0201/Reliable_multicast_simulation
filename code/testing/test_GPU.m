

tic
r1 = rand(10000,1);
for i=1:10000
    binornd(1,r1);
end
time=toc;
fprintf("Elpased time with binornd: %g\n",time);

tic
for i=1:10000
    bsxfun(@lt, rand(10000,1), r1);
end
time=toc;
fprintf("Elpased time with specified code: %g\n",time);

function [m, s, sk, k, p50, p95] = statistics(n, mux, sigmax, ...
    muy, sigmay, muz, sigmaz, muw, sigmaw)
mux1 = log((mux ^ 2) / sqrt(sigmax + mux ^ 2));
sigmax1 = sqrt(log(sigmax / (mux ^ 2) + 1));
x = lognrnd(mux1, sigmax1, n, 1);
muy1 = log((muy ^ 2) / sqrt(sigmay + muy ^ 2));
sigmay1 = sqrt(log(sigmay / (muy ^ 2) + 1));
y = lognrnd(muy1, sigmay1, n, 1);
muz1 = log((muz ^ 2) / sqrt(sigmaz + muz ^ 2));
sigmaz1 = sqrt(log(sigmaz / (muz ^ 2) + 1));
z = lognrnd(muz1, sigmaz1, n, 1);
muw1 = log((muw ^ 2) / sqrt(sigmaw + muw ^ 2));
sigmaw1 = sqrt(log(sigmaw / (muw ^ 2) + 1));
w = lognrnd(muw, sigmaw, n, 1);
r = 2 * x + y + z - w;
m = mean(r); % calculate mean
s = std(r); % calculate standard deviation
sk = skewness(r); % calculate skewness
k = kurtosis(r); % calculate kurtosis
p50 = prctile(r, 50); % calculate 50th percentile
p95 = prctile(r, 95);
end