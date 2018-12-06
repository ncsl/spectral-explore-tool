function foi = rankFOI(V, str, varargin)
% function foi = rankFOI(V, str, varargin)
%
% Function that find the FOI based on specified function to calculate the ranking metric
%
% Input:
%       - V: < I x J > cell matrix containing the right singular vector (aka 'frequency singular
%       vector') from SVD
%       - str: < 1 x 1 > string array used to construct function handle of ranking metric. Must
%       begin with '@(v)'. Option to also insert your own custom script.
%
%       - OPTIONAL:
%           - Other inputs to function
%
% Output:
%       - foi: < 1 x 1 > structure array with the following fields:
%               - func:    < 1 x 1 > Function handle used for ranking
%               - metric:  Structure array containing results of ranking function, sorted in
%                          descending order
%               - ranking: Structure array containing numerical ranking value, taking into tied ranking
%               - order:   Structure array indexing of bin/band number. Sorted in same order as
%                          metric.
%               - index:   < J*num x 2 > Double array indexing the [Region index, Mode number].
%                                        Matches rows of metric, ranking, and order.
%           
%
%       TODO: Add ability to use varargin to add to function
%       TODO: Add ability to apply to bands (options)
%
%
% Macauley Breault
% Created: 06-19-2018


%% Check arguments

% Check function
if ~contains(str,'@(v)')
    error('FUNCTION ERROR: Function to calculate FOI does not match format of beginning with @(v).')
end

% Construct function handle from character
func = str2func(str);


%% Initialize variables

I = size(V,1);
J = size(V,2);
num = size(V{1},2); % Number of modes
F_bin = size(V{1},1);
F_band = 7; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHANGE

%v = cell(I,J,num);
v = [];

% GOAL: v = < I x J x num x 55 >
for i = 1:I
    for j = 1:J
        for m = 1:num
                
            v{j,m}(i,:) = V{i,j}(:,m);
            
        end
    end
end


%% Calculate ranking metric

metric_index = fullfact(size(v)); % [ j, svd num ]

% Intialize variables
metric  = struct('bin', nan(length(metric_index), F_bin),'band', nan(length(metric_index), F_band));
sorted  = struct('bin', nan(length(metric_index), F_bin),'band', nan(length(metric_index), F_band));
order   = struct('bin', nan(length(metric_index), F_bin),'band', nan(length(metric_index), F_band));
ranking = struct('bin', nan(length(metric_index), F_bin),'band', nan(length(metric_index), F_band));

for jm = 1:numel(v)
    metric.bin(jm,:) = func(v{jm});
    
    [sorted.bin(jm,:),order.bin(jm,:)] = sort(metric.bin(jm,:), 'descend');
    ranking.bin(jm,:) = tiedrank(sorted.bin(jm,:));
end


%% Construct ranking array

foi = struct;

% Save function
foi.func = func;

% Save metric
foi.metric = sorted;
foi.ranking = ranking;

% Order (descending)
foi.order = order;

% Metric indexing
foi.index = metric_index;


end % end rankFOI