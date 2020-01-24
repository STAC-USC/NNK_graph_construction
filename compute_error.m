function err = compute_error(labels,labels_hat,samples)
% Error ratio on unlabeled nodes
n = length(labels);
unlabeled = true(n,1);
unlabeled(samples) = false; % true => node is unlabeled
err = sum(labels(unlabeled) ~= labels_hat(unlabeled))/sum(unlabeled);

