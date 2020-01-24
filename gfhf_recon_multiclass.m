function [err,labels_hat] = gfhf_recon_multiclass(L,labeled,y)
% SSL using Zhu et al. 2003
% L = Laplacian (or any other HP function of L e.g. L^k)
% labeled = indices of labeled nodes
% y = ground truth labels (one vs rest 1-0 membership)
% (Assumes non-empty labeled set)

[~,labels] = max(y,[],2); % true labels
unlabeled = setdiff(1:1:size(y,1),labeled);
y_hat = y;
full_matrix = full(L(unlabeled,unlabeled));
nn = any(isnan(full_matrix(:)));
in = any(isinf(full_matrix(:)));
if (nn || in)
    disp('NaN or Inf detected')
end

y_hat(unlabeled,:) = -pseudo_inverse(L(unlabeled,unlabeled))*(L(unlabeled,labeled)*y(labeled,:));
labels_hat = labels;
[~,labels_hat(unlabeled)] = max(y_hat(unlabeled,:),[],2); % unknown predicted labels
err = compute_error(labels,labels_hat,labeled);
end
