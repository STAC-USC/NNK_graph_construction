function x = normc(x)
normalize = @(a) a/norm(a);
for i=1:size(x,2)
    x(:, i) = normalize(x(:,i));
end
end