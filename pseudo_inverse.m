function X = pseudo_inverse(A,tol)
n=size(A,1);
[U,S] = eigs(A, n, 'largestreal');
% [U,S,V] = svds(A,n,'smallestnz');
s = diag(S);
if nargin < 2 
    tol = 1e-10;%n * eps(norm(s,inf));
end
r1 = sum(s > tol)+1;
U(:,r1:end) = [];
s(r1:end) = [];
s = 1./s(:);
X = (U.*s.')*U';
