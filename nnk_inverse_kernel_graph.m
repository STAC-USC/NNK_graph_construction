function W = nnk_inverse_kernel_graph(G, mask, knn_param, reg)
% Constructs NNK graph
% G = similairty or kernel matrix
% mask - Neighbors to consider at each node (each row corresponds to neighbors)
% k_choice - Not used. For adaptive kernels
% reg - for removing weights smaller than reg value

if nargin < 4
    reg=1e-6;
end
n = length(G);
neighbor_indices = zeros(n, knn_param);
weight_values = zeros(n, knn_param);
error_values = zeros(n,knn_param);

for i = 1:n
    nodes_i = find(mask(i,:)); % only consider similar enough neighbors
    nodes_i(nodes_i==i) = []; 
    G_i = full(G(nodes_i, nodes_i));% removing i-th row and column from G
    g_i = full(G(nodes_i,i)); % removing the i-th elem from 

    qp_output = nonnegative_qp_solver(G_i, g_i, reg, g_i);
    qpsol = qp_output.xopt;
    
    neighbor_indices(i,:) = nodes_i;
    weight_values(i,:) = qpsol;
    error_values(i,:) = (G(i,i) - 2*qpsol'*g_i + qpsol'*G_i*qpsol);
end

%%
row_indices = repmat(1:n, knn_param,1)';
W = sparse(row_indices(:), neighbor_indices(:), weight_values(:), n, n);
error = sparse(row_indices(:), neighbor_indices(:), error_values(:), n, n);
W(error > error') = 0;
W = max(W, W');



