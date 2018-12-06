function [roi, foi] = mainTool(X, y, varargin)
% function [roi, foi] = mainTool(X, y, varargin)
%
% Main function for exploratory tool that uses _______________________________________.
% This tool takes in the spectral neural data (X) and behavioral data (y) to __________________.
%
% Topic for paper in Journal for Computational Neuroscience
%
%
%
% Input:
%       - X = < 1 x 1 > none
%       - y = < 1 x 1 > none
%   (Optional)
%       - {'labels',labels} = < 1 x J > cell array of string of brain region labels.
%                                       (Default = {})
%       - {'criterion',criterion} = < 1 x 1 > double scalar of a percent between [0,100] used to find the number
%                                             of SVD modes to use based on the cumulative percent of variance.
%                                            (Default = 50)
%       - {'threshold',threshold} = < 1 x 1 > double scalar between [0,1] used to limit the number
%                                             of ROIs to a smaller subset of regions.
%                                            (Default = 0)
%       - {'roi function',str_roi} = < 1 x 1 > Character vector used as function handle to rank ROI. Must
%                                              start with '@(r,p)'. Argument string must contain 'roi' and 'fun'.
%                                              (Default = '@(r,p) mean(r)')'
%       - {'foi function',str_foi} = < 1 x 1 > Character vector used as function handle to rank FOI. Must
%                                              start with '@(v)'. Argument string must contain 'foi' and 'fun'.
%                                              (Default = '@(v) mean(abs(v))')
%
% Output:
%       - none = < 1 x 1 > none
%
%
% TODO: If labels are present, then add them to roi and foi
% TODO: ********** Add ability to use a threshold on full ranked list **********
%
%
% Macauley Breault
% Created: 06-07-2018


%% Check arguments

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Check X and y ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
validateattributes(X,{'cell'},{'2d'})
validateattributes(y,{'cell'},{'vector','numel',size(X,1)})


% Check that all brain regions are the same size per trial
X_size_1 = cellfun(@(x) size(x,1), X);
if any(any(diff(X_size_1,[],2)))
    error('DIMENSION ERROR: Trial dimensions do not agree with all brain regions in ''X''.')
end

% Check that all trials and brain regions have the same number of frequencies
X_size_2 = cellfun(@(x) size(x,2), X);
if numel(unique(X_size_2)) > 1
    error('DIMENSION ERROR: Column size of all elements do not agree in ''X''.')
end

% Check that size of elements of X and y match
if any(cellfun(@length, y) ~= X_size_1(:,1))
    error('DIMENSION ERROR: Trial dimensions do not agree between ''X'' and ''y''.')
end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Check varargin ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
labels = {};
criterion = 50; % Used to find number of singular values to use
threshold = 0;  % Used to limit the number of ROIs
str_roi = '@(r,p) mean(r)';
str_foi = '@(v) mean(abs(v))';


if numel(varargin) > 0
    
    for arg = 1:length(varargin)
        
        
        % Brain region labels
        if  strcmp(varargin{arg}(1),'labels')
            labels = reshape(varargin{arg}{2},numel(varargin{arg}{2}),1);
            
            % Check that labels has the same dimensions as X. Otherwise, ignore labels.
            validateattributes(labels,{'cell'},{'vector'})
            
            if numel(labels) ~= size(X,2)
               labels = {};
               warning('ARGUMENT WARNING: the argument ''labels'' was ignored because it did not match the dimensions of ''X''.')
            end
            
        end
        
        
        % SVD criterion
        if  strcmp(varargin{arg}(1),'criterion')
            criterion = varargin{arg}{2};
            
            % Check that thresold is a scalar percent
            validateattributes(criterion,{'double'},{'scalar','>=',0,'<=',100})
            
            if criterion < 1
                error('ARGUMENT ERROR: ''criterion'' should be converted to a percent between [0,100].')
            end
            
        end
        
        
        % ROI threshold
        if  strcmp(varargin{arg}(1),'threshold')
            threshold = varargin{arg}{2};
            
            % Check that thresold is a scalar percent
            validateattributes(threshold,{'double'},{'scalar','>=',0,'<=',1})
            
            if criterion > 1
                error('ARGUMENT ERROR: ''threshold'' should be a double between [0,1].')
            end
            
        end
        
        
        
        % Function for ROI
        if  contains(varargin{arg}(1),'roi') && contains(varargin{arg}(1),'fun')
            str_roi = varargin{arg}{2};
            
            % Check that argument is a string and contains '@(r,p)'
            if ~ischar(str_roi) || ~contains(str_roi,'@(r,p)')
                error('ARGUMENT ERROR: ''str_roi'' should be a string of a function handle with inputs ''@(r,p)''.')
            end
        end
        
        
        % Function for FOI
        if  contains(varargin{arg}(1),'foi') && contains(varargin{arg}(1),'fun')
            str_foi = varargin{arg}{2};
            
            % Check that argument is a string and contains '@(v)'
            if ~ischar(str_foi) || ~contains(str_foi,'@(v)')
                error('ARGUMENT ERROR: ''str_foi'' should be a string of a function handle with inputs ''@(v)''.')
            end
        end
            
        
    end
    
end


%% Initialize parameters

I = size(X,1); % Number of trials
J = size(X,2); % Number of brain regions


%% +++++++++++++++++++++++++++++++++++ Find # of SV +++++++++++++++++++++++++++++++++++

num = findSvdNum(X, criterion);


%% +++++++++++++++++++++++++++++++++++ SVD +++++++++++++++++++++++++++++++++++

U = cell(size(X));
S = cell(size(X));
V = cell(size(X));

for ij=1:numel(X)
    [U{ij}, S{ij}, V{ij}] = svds(X{ij},num);
end


%% +++++++++++++++++++++++++++++++++++ Cross-correlate +++++++++++++++++++++++++++++++++++

clearvars stats

for i=1:I
    for j=1:J
        stats(i,j) = getCross(y{i},U{i,j});
    end
end


%% +++++++++++++++++++++++++++++++++++ Rank ROI +++++++++++++++++++++++++++++++++++

roi = rankROI(stats, threshold, str_roi, labels);


%% +++++++++++++++++++++++++++++++++++ Rank FOI +++++++++++++++++++++++++++++++++++

foi = rankFOI(V, str_foi, labels);









end % end mainTool