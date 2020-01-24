function ssl_error_plot(num_samples, label_names, error_values,  fname)
figure; hold on; grid on;
x_range = 1:1:length(num_samples);
n_graphs = length(label_names);
colors = lines(n_graphs);
% colors(4,:) = [0, 0, 0];
% colors(3,:) = [];
plot_specs = {'x-', '<-',  '^-',  '>-', '+-','o-'};%,'*-', 'o--'
%% Modifying labels for journal and ICASSP submission 
% tmp = label_names{6};
% label_names{6} = label_names{5};
% label_names{5} = tmp;

% tmp = label_names{7};
% label_names{7} = label_names{6};
% label_names{6} = tmp;

% tmp = error_values{6};
% error_values{6} = error_values{5};
% error_values{5} = tmp;

% tmp = error_values{7};
% error_values{7} = error_values{6};
% error_values{6} = tmp;
%%
for ii=1:n_graphs
    error = mean(error_values{ii}, 2);
%     std_dev = std(error_values{ii}, [], 2);
%     errorbar(x_range,error*100, std_dev*100, plot_specs{ii},...
%         'linewidth',1,'DisplayName',label_names{ii})
    plot(x_range,error*100, plot_specs{ii},'Color', colors(ii,:),...
        'linewidth',1,'DisplayName',label_names{ii})
end

xlabel('Percentage of labeled nodes', 'FontSize', 14)
% xlim([num_samples(idx_from), num_samples(idx_to)]);
% xlim([min(x_range),max(x_range)]);
set(gca,'XTick',x_range,'FontSize', 14);
ylabel('Percentage Error', 'FontSize', 14)
% ylim([0,90]); 
% set(gca,'YTick',[0:10:90],'FontSize', 14);
set(gca, 'FontSize', 14)
legend('show'); legend('boxoff')
% saveas(gcf, [fname '_nnls_ssl_error_plot.pdf'])
if nargin > 3
    print('-bestfit', [fname '_nnls_ssl_error_plot.pdf'], '-dpdf')
end
end