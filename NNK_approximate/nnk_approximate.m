function [x_opt, error] = nnk_approximate(AtA, b, x_init, x_tol, max_iter, eta)
% AtA = shape [S, S, bsz], b, x_init = shape [1, S, bsz]
switch nargin
    case 3
        x_tol = 1e-10;
        max_iter = 100;
        eta = 0.05;
    case 4
        max_iter = 100;
        eta = 0.05;
    case 5
        eta = 0.05;
end

x_opt = x_init;
iter = 1;
while iter < max_iter
    x_opt = x_opt + eta*(b - pagemtimes(x_opt, AtA));
    x_opt(x_opt < 0) = 0;
    iter = iter + 1;
end
x_opt(x_opt<x_tol) = 0;
error = 1 - 2 * pagemtimes(x_opt, 'none', b, 'transpose') + pagemtimes(pagemtimes(x_opt, AtA), 'none', x_opt, 'transpose');
error = squeeze(error); % shape [bsz]
x_opt = squeeze(x_opt); % shape [S, bsz]
end