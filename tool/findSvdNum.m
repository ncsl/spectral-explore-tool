function num = findSvdNum(X, criterion)
% function num = findSvdNum(X, criterion)
%
% Function that finds the best number of singular values to examine in analysis.
%
% Topic for paper in Journal for Computational Neuroscience
%
%
%
% Input:
%       - none = < 1 x 1> none
%
% Output:
%       - none = < 1 x 1> none
% 
%
% Macauley Breault
% Created: 06-07-2018


%% Check arguments



%% Calculate SVD and % of variance explained by mode number

s = NaN(max(max(cellfun(@(Xij) size(Xij,1), X))),1);
S = repmat({s},size(X));

% Calculate the cumulative sum of the percent of the variance
for ij = 1:numel(X)
    S{ij}(1:min(size(X{ij}))) = cumsum(100 * svd(X{ij}).^2 / sum(svd(X{ij}).^2));
end

% Reshape S for plotting
S_var = cell2mat(reshape(S,1,numel(S)))';
S_var_mean = mean(S_var,'omitnan');
S_var_std = std(S_var,'omitnan');


%% Find minimum number of singular values needed to AT LEAST satisfy the threshold

num = find(S_var_mean > criterion,1,'first');

disp(['Using the first ',num2str(num),' singular values to capture AT LEAST ', num2str(criterion),'% of the original data'])



%% Plot

figure(sum(uint8(mfilename)))
set(gcf,'Name','SVD threshold')
clf

% Plot
bar(S_var_mean,'FaceColor','r','EdgeColor','r','FaceAlpha',0.2)

% Format
axis tight
ylim([0 100])

% Label
xlabel('$m$','Interpreter','LaTex')
ylabel({'Cumulative percent of variance explained'})

% Add error bar
hold on
errorbar(S_var_mean, S_var_std, '.k','MarkerSize',1);
hold off

% Add thershold
hold on
plot(xlim,[1,1]*criterion,'--','Color',[0.5 0.5 0.5])
hold off

%{
% Add threshold
hold on
plot(xlim,threshold*[1 1],'k--')
hold off

% Add legend
%leg = legend({'$\overbar{s}$','$\pm 1 \text{std}$');
l = legend('$\overline{s}$','$\pm 1 std$');
set(l,'Interpreter','latex');
%}



end % end findSvdNum