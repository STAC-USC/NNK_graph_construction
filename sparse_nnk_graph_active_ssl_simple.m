function sparse_nnk_graph_active_ssl_simple(data, knn_param, k_choice, reg)
%%% Example usage: sparse_nnk_graph_active_ssl_simple('usps1', 20, 20, 1e-8)
% knn_param = 'K' nearest neighbors to choose
% k_choice = 'sigma' calculation parameter - usually set equal to knn_param
% reg = thresold for weights (values below this threshold are made zero)

if nargin <4
    reg = 1e-8;
end

%% read data
% knn_param=30; k_choice=30; reg=1e-8;
% data = 'usps1';
load([data,'.mat']); % data: X (dim x num) and labels: y
X=double(X);
% y = y_m;
N = size(X,2);
results_folder = ['results/' 'SSL_results/' data '/']; 
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
fname = [results_folder, data,'_k_',num2str(knn_param),'_sig_', num2str(round(sigma))]; %
%%
tic
fprintf('Computing the adj and L of %d-NN graph with sigma %0.4f...\n', knn_param, sigma)
W_knn = G .* knn_mask;
W_knn(W_knn<reg) = 0;
knn_time = symmetrization_time + toc;

%%
% fprintf('Computing the adj and L Kalofolias graph...\n')
% tic
% params.fix_zeros = true; params.edge_mask = knn_mask;
% theta = gsp_compute_graph_learning_theta(D, knn_param);
% [W_kalofolias, info] = gsp_learn_graph_log_degrees(theta.*D, 1, 1, params);
% W_kalofolias(W_kalofolias < reg) = 0;
% 
% kalofolias_graph_time = toc + distance_mask_time + symmetrization_time - similarity_time;
%%
fprintf('Computing the adj and L NNK...\n')
tic
W_nnk = nnk_inverse_kernel_graph(G, directed_knn_mask, knn_param, reg); % choose the min k-NN sim
nnk_time = toc + similarity_time;

%%
knn_sparsity = length(find(W_knn))/2;
nnk_sparsity = length(find(W_nnk))/2;

%%
time_values = {knn_time, nnk_time}; 
sparsity_values = {knn_sparsity, nnk_sparsity};
%%
save([fname, '.mat'],'knn_param', 'sigma', 'W_knn',...%  'W_lle',  'W_aew',
    'W_nnk', 'time_values', 'sparsity_values'); 
%%
[L_knn,Ln_knn,~] = compute_laplacians(W_knn);
[L_nnk,Ln_nnk, ~] = compute_laplacians(W_nnk);

%% semi-supervised learning with random sampling to compare two graphs
max_num_samples = floor(0.1*N);% 100;%
num_add = floor(0.01*N);%10;%
num_samples = num_add:num_add:max_num_samples;

fprintf('Comparing graphs in SSL with random sampling...\n')
num_trials = 5;
err_knn_t = zeros(length(num_samples),num_trials);
err_knn_Ln_t = zeros(length(num_samples),num_trials);

err_nnk_t = zeros(length(num_samples),num_trials);
err_nnk_Ln_t = zeros(length(num_samples),num_trials);

%%
for t = 1:num_trials
    fprintf('trial number %d ...\n', t);
    samples = random_sample([],num_samples(1),N); % initialize sampling set
    for i = 1:length(num_samples)
        err_knn_t(i,t)=gfhf_recon_multiclass(L_knn,samples,y);
        err_knn_Ln_t(i,t)=gfhf_recon_multiclass(Ln_knn,samples,y);

        err_nnk_t(i,t)=gfhf_recon_multiclass(L_nnk,samples,y);
        err_nnk_Ln_t(i,t)=gfhf_recon_multiclass(Ln_nnk,samples,y);
        
        samples = random_sample(samples,num_add,N);
    end
end
%% save
label_names = {sprintf('%s (t=%0.2f s, %d edges)', 'KNN', time_values{1}, sparsity_values{1}),...
                sprintf('%s (t=%0.2f s, %d edges)', 'NNK', time_values{2}, sparsity_values{2})};
%                    
%%
error_values_L={err_knn_t, err_nnk_t};
error_values_Ln={err_knn_Ln_t,err_nnk_Ln_t};
%%
save([fname, '.mat'],'knn_param', 'sigma', 'W_knn','W_nnk', 'error_values_L', 'error_values_Ln', 'label_names', 'num_samples', 'time_values', 'sparsity_values'); 
%%
ssl_error_plot(num_samples, label_names, error_values_L, fname)
ssl_error_plot(num_samples, label_names, error_values_Ln, [fname '_n'])
