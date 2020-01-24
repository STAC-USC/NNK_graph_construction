function samples = random_sample(cur_samples,num_add,n)
% Randomly select num_add numbers from 1:1:n excluding the ones from
% cur_samples. |samples| = |cur_samples| + num_add
nodes = 1:1:n;
candidates = setdiff(nodes,cur_samples);
new_samples = datasample(candidates,num_add,'Replace',false);
samples = [cur_samples, new_samples];
end

