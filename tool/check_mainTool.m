% check_mainTool.m
%
% Script that checks the arguments of the function called mainTool
%
% Macauley Breault
% Created: 07-11-2018

cd(erase(mfilename('fullpath'),mfilename))

%% FORMAT DATA JUST FOR MY PURPOSE
if isempty(whos('X')) || isempty(whos('y')) || isempty(whos('labels')) || isempty(whos('modulate')) || isempty(whos('stats_real'))
    [X,y,labels,modulate,stats_real] = load_tool_data;
end

tic
%% Run mainTool
[roi, foi] = mainTool(X,y,{'labels',labels});
toc

% Make plots
plotROI(roi)