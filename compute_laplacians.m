function [L, Ln, Lr] = compute_laplacians(A)
% Computes L, symm. norm. L and RW L

N = length(A);
% Remove self edges if any
A = A - diag(diag(A));
deg = sum(A,2);
L = spdiags(deg,0,N,N) - A;

d = deg;
d = d.^(-1/2);
d(deg==0) = 0;
Dinv = spdiags(d,0,N,N);
Ln = speye(N)-Dinv*A*Dinv;
Ln = 0.5*(Ln+Ln');

d = deg;
d = d.^(-1);
d(deg==0) = 0;
Lr = speye(N)-spdiags(d,0,N,N)* A;


% % normalization by number of links
% % remove self loops
% A =  A - diag(diag(A));
% d_link = sum(A~=0, 2);
% Dinv_link = spdiags(d_link.^(-1/2), 0, N, N);
% Ln_link = Dinv_link*Lun*Dinv_link;
% Ln_link = 0.5*(Ln_link+Ln_link');


