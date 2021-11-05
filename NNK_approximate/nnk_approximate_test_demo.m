clc;
clear;
close all;
%% read data
knn_param=20; k_choice=10; reg=1e-6;
data = 'two_moons_1k';
load([data,'.mat']); % data: X (dim x num) and labels: y

X = normc(X); % normalize each feature vector to 1.
[d, N] = size(X);
results_folder = ['results/']; 
dir_result = mkdir(results_folder);
%% compute range normalized cosine similarities
% tic
% [neighbor_indices, neighbor_dist] = knnsearch(X', X', 'k', knn_param+1, 'dist', 'cosine');
% neighbor_indices = neighbor_indices(:, 2:end)'; % removing pointer to self
% neighbor_dist = neighbor_dist(:, 2:end)';
% neighbor_similarities = reshape(1 - 0.5*neighbor_dist, 1, knn_param, N);
% neighbor_support = reshape(X(:, neighbor_indices), d, knn_param, N);
% support_similarities = 0.5 + 0.5*pagemtimes(neighbor_support, 'transpose', neighbor_support, 'none');

%% compute euclidean Gaussian kernel similarites
gamma = 1;
tic
[neighbor_indices, neighbor_dist] = knnsearch(X', X', 'k', knn_param+1, 'dist', 'euclidean'); 
neighbor_indices = neighbor_indices(:, 2:end)'; % removing pointer to self
neighbor_dist = neighbor_dist(:, 2:end)';
neighbor_similarities = reshape(exp(-(neighbor_dist.^2)./(2*gamma)), 1, knn_param, N);
neighbor_support = reshape(X(:, neighbor_indices), d, knn_param, N);
support_dists = 2 - 2*pagemtimes(neighbor_support, 'transpose', neighbor_support, 'none'); % normalized feature vectors
support_similarities = exp(-(support_dists.^2)./(2*gamma));

%% computer NNK approximate graph
[weight_values, error] = nnk_approximate(support_similarities, neighbor_similarities, neighbor_similarities, 1e-6, 100, 0.1);
nnk_time = toc;
%% create adjacency matrix
row_indices = repmat(1:N, knn_param,1);
W = sparse(row_indices(:), neighbor_indices(:), weight_values(:), N, N);
W = max(W, W'); % Simple symmetrization
%% Adjacency plot
figure();
axis off
spy(W);
title(['NNK (t=' num2str(nnk_time) 's, edges=' num2str(nnz(W)) ')'])