clc;
clear;
close all;
%% read data
knn_param=10; k_choice=10; reg=1e-6;
data = 'two_moons_1k';
load([data,'.mat']); % data: X (dim x num) and labels: y

N = size(X,2);
results_folder = ['results/']; 
dir_result = mkdir(results_folder);
%% compute graphs
tic
D = DistEuclideanPiotrDollar(X',X'); % pairwise squared Euclidean distances
directed_knn_mask = sparse(GD_BuildDirectedKnnGraph(D,knn_param,'dist'));
distance_mask_time = toc;
kD = sort(sqrt(D), 'ascend');
sigma = full(mean(kD(k_choice, :)))/3;
G = exp(-D./(2*sigma*sigma));
similarity_time = toc;
knn_mask = max(directed_knn_mask, directed_knn_mask');
symmetrization_time = toc;
%%
fprintf('Computing the adj and L of %d-NN graph with sigma %0.4f...\n', knn_param, sigma)
W_knn = G .* knn_mask;
W_knn(W_knn<reg) = 0;
knn_time = toc;

%%
fprintf('Computing the adj and L NNK...\n')
tic
W_nnk = nnk_inverse_kernel_graph(G, directed_knn_mask, knn_param, reg); % choose the min k-NN sim
nnk_time = toc + similarity_time;

%%
time_values = {knn_time, nnk_time};
sparsity_values = {length(find(W_knn))/2, length(find(W_nnk))/2};
%%
fname = [results_folder, data,'_k_',num2str(knn_param),'_sig_', num2str(round(sigma))]; %
save([fname, '.mat'], 'knn_param', 'sigma', 'W_knn', ...%
    'W_nnk', 'time_values', 'sparsity_values'); 
%% Adjacency plots
figure();
subplot(1,2,1); axis off
spy(W_knn);
title(['KNN (t=' num2str(time_values{1}) ', edges=' num2str(sparsity_values{1}) ')'])

subplot(1,2,2); axis off
spy(W_nnk);
title(['NNK (t=' num2str(time_values{2}) ', edges=' num2str(sparsity_values{2}) ')'])