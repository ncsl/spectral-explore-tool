function roi = rankROI(stats, threshold, str, labels)
% function roi = rankROI(stats, threshold, str, labels)
%
% Function that find the ROI based on specified function to calculate the ranking metric
%
% Input:
%       - stats = < I x J > structure array with results from of SVD and cross-correlation
%       - threshold = < 1 x 1 > double scalar between [0,1] used to limit the number of ROIs to a
%                               smaller subset of regions.
%       - str =   < 1 x 1 > string array used to construct function handle of ranking metric. Must
%                           begin with '@(r,p)'. Option to also insert your own custom script.
%       - labels = < 1 x J > cell array of string of brain region labels.
%
%
% Output:
%       - roi: < 1 x 1 > structure array with the following fields:
%               - func:    < 1 x 1 > Function handle used for ranking
%               - metric:  < J*num x 1 > Double vector containing result of ranking function, sorted
%                                        in descending order.
%               - ranking: < J*num x 1 > Double vector containing numerical ranking value, taking into tied ranking
%               - index:   < J*num x 3 > Double array indexing of [trial number (should be 1), Region index, Mode number]. Sorted in same order as metric.
%           
%
%       TODO: Add ability to use varargin to add to function
%
%
% Macauley Breault
% Created: 06-19-2018


%% Check arguments

% Check function
if ~contains(str,'@(r,p)')
    error('FUNCTION ERROR: Function to calculate ROI does not match format of beginning with @(r,p).')
end

% Construct function handle from character
func = str2func(str);


%% Initialize variables

I = size(stats,1);
J = size(stats,2);
num = numel(stats(1).r); % Number of modes


% Initialize variables used for the remainder of this functionGOAL: r = < I x J x num >
r = reshape( vertcat(stats.r), I,J,num); % < I x J x num >
p = reshape( vertcat(stats.p), I,J,num); % < I x J x num >


%% Calculate ranking metric

metric = func(r,p);

metric_index = fullfact(size(metric)); % [ i,  j, svd num ]

% SORT
[sorted,order] = sort(metric(:), 'descend');
ranking = tiedrank(sorted);


%% Construct ranking array

roi = struct;

% Save function
roi.func = func;

% Save metric
roi.metric = sorted;
roi.ranking = ranking;

% Sorted indexing
roi.index = metric_index(order,:);

% Brain region labels (if not empty) with mode number
% EXAMPLE: 'amygdala L (m=2)'
if ~isempty(labels)
   roi.labels = arrayfun(@(j, m) [labels{j},' (m=',num2str(m),')'], roi.index(:,2), roi.index(:,3),'un',0);
end

disp('TODO: Add thresholding to rankROI')


end % end rankROI