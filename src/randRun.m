% Run
N = 1000;
ks = zeros(N,1);
pass = zeros(N,1);
xs = [1.9191 2.1953];
tol = 0.01;

for k = 1:N
    [P,x0] = prob('rand');
    R = activeSetMethod(P,x0,kmax);
    ks(k) = R.k;
    pass(k) = abs(sum(R.x(end,:) - xs)) <= tol;
end

kavg = mean(ks);
rate = 100*length(pass(pass ~= 0))/N;
fprintf('kavg = %d, success = %d per\n',kavg,rate);