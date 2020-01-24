% function[out] = nonnegative_qp_solver(A, b, inner_tol, x_init)
% 
% % initialization
% n = size(A, 1);
% AtA = A;%+1e-12*eye(n);
% Atb = b;
% 
% maxiter = 50*n;
% if nargin < 4
%     x_init = zeros(n, 1);
% end
% 
% x = x_init;    %Intial value for solution
% iter = 0;
% F = false(n, 1);        % F tracks elements pruned based on negativity  
% lambda = -Atb;  % gradient
% 
% check = 1; %intial value for first run
% 
% tol = eps;
% 
% while (check > tol) && (iter < maxiter)
%     fH1 = x < eps;
%     H1 = fH1 & F;
%     
%     fH2 = lambda < -eps;
%     H2 = fH2 & ~F;
% 
%     F(H1) = false;
%     F(H2) = true;
%     
%     R = chol(AtA(F,F));
% 
%     x = zeros(n, 1);
%     x(F) =  R \ (R' \ Atb(F));
%     lambda(~F) = AtA(~F, F) * x(F) - reshape(Atb(~F), sum(~F), 1);
%     lambda(F) = 0;
%     iter = iter + 1;
%     check = check_kkt_cond(lambda, x);
% end
% 
% x(x<inner_tol) = 0;
% out.xopt = x;
% out.check = check;
% end
% 
% 
% 
% function[kktopt] = check_kkt_cond(grad, x)
% 
% num = abs(grad) .* (grad > eps);
% Pc = num < eps; 
% 
% 
% if sum(Pc) > 0 % gradients equal to zero?
%     kktPc = max(abs(grad(Pc)));
% else
%     kktPc = 0;
% end
% 
% N = x < eps;
% 
% if sum(N) > 0   % sum of all negative values % positivity constraints check
%     kktN = max(abs(x(N)));
% else
%     kktN = 0;
% end
% 
% kktopt =  max([kktPc kktN]);
% 
% end

%%
function[out] = nonnegative_qp_solver(A, b, inner_tol, x_init)

% initialization
n = size(A, 1);
AtA = A;%+1e-12*eye(n);
Atb = b;

maxiter = 50*n;
if nargin < 4
    x_init = zeros(n, 1);
end

x = x_init;    %Intial value for solution
iter = 0;

F = true(n, 1);    % F tracks elements pruned based on negativity  

check = 1; %intial value for first run

tol = inner_tol;

while (check > tol) && (iter < maxiter)
    fH1 = x > eps;
    F = F & fH1;

    R = chol(AtA(F,F));

    x = zeros(n, 1);
    x(F) =  R \ (R' \ Atb(F));

    iter = iter + 1;
    
    N = x < eps;
    if sum(N) > 0   % sum of all negative values % positivity constraints check
        check = max(abs(x(N)));
    else
        check = 0;
    end
end

x(x<inner_tol) = 0;
out.xopt = x;
out.check = check;
end