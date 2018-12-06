function [X,y,labels,modulate,stats] = load_tool_data()
% function [X,y,labels,modulate,stats] = load_tool_data()
%
% Function that loads and returns the neural data for testing the tool
%
%   Input:
%       - None
%
%   Output:
%       - X = <
%       - y = <
%       - labels = <
%       - modulate (temporary for comparison)
%       - stats (temporary for comparison)
%
%
% Macauley Breault
% Created: 06-15-2018

%% Parameters

% Subject number
N = 2;

% Metric
metric_name = 'ang';

% SVD number
svd_num = 1:2;

% Folder name
foldername = 'unperturbed';

% Raw
raw = 0;


%% Load neural data

if isempty(whos('neural_all'))
    
    disp(' ')
    disp('Loading neural data')
    load('/Users/Mac/Desktop/all neural subjects.mat')
    
    %% Remove broken electrodes from neural_all (for N = 1,2,10,11)
    
    for N_temp = [1,2,10,11]
        % Find electrode index
        if N_temp < 3
            elec_ind = [57, 3];
            broken = find(any(neural_all{N_temp}.elec_ind == elec_ind,2));
        elseif N_temp > 9
            broken = find(cellfun(@(name) any(regexp(name,'F\d')), neural_all{N_temp}.elec_name));
        else
            error('Request to remove fields, but could not find any broken.')
        end
        
        if isempty(broken)
            break
        end
        
        % Name fields to edit
        remove_field = {'session','elec_area','elec_ind','elec_name','data','t','f'};
        
        % Remove broken electrodes
        for f = 1:numel(remove_field)
            neural_all{N_temp}.(remove_field{f})(broken) = [];
        end
    end
    
    disp('Neural data loaded')
else
    disp('Neural data already loaded')
end



%% Load modulate/stats data

% Load modulation data
if isempty(whos('modulate'))
    disp('  ')
    disp('Loading modulation data')
    tic
    
    modulate = getMod(neural_all{N},{'folder',foldername},{'raw',0});
    
    toc
    disp('Modulation data loaded')
else
    disp('Modulation data already loaded')
end


% Load stats data
if isempty(whos('stats'))
    disp('  ')
    disp('Loading stats data')
    
    stats = getAllSVD(modulate, metric_name, svd_num);
    
    disp('Stats data loaded')
else
    disp('Stats data already loaded')
end



%% Format data for tool

x = modulate.data; % Specify shape and stuff
y = modulate.metric.(metric_name);

X = cell(size(x));
T = modulate.time_ind;

for j = 1:size(x,1)
    for i = 1:size(x{j},1)
        X{i,j} = squeeze(x{j}(i,:,T{i},:));
    end
end

labels = modulate.elec_area;
