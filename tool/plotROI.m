function [] = plotROI(roi)
% function [] = plotROI(roi)
%
% Function that plots the results of ranking ROI including: Histogram and Bar plot
%
% Input:
%       - roi: < 1 x 1 > structure array. See rankROI for documentation.
%
% Output:
%       - None
%
% TODO: Add error bars and other stats
% TODO: Make labels fit
%
% Macauley Breault
% Created: 07-11-2018


figure(sum(uint8(mfilename)))
set(gcf,'Name','ROI')
clf


%% Uniform formating

light_color = [0.8045    0.7550    0.8720];
dark_color = [0.3483    0.1559    0.5670];

createColorGradient = @(color1, color2, number) ([linspace(color2(1), color1(1), number); ...
                                              linspace(color2(2), color1(2), number); ...
                                              linspace(color2(3), color1(3), number)])';
                                          
%{                                          
%% Histogram

AX(1) = subplot(3,1,1);

% Plot
histogram(AX(1), roi.metric, 'BinWidth',0.01, 'FaceColor',light_color,'EdgeColor',dark_color)

% Format
axis(AX(1),'tight','square')
box(AX(1),'on')
AX(1).XTick = linspace(AX(1).XLim(1), AX(1).XLim(2), 3);
AX(1).YTick = linspace(AX(1).YLim(1), AX(1).YLim(2), 3);

% Label
xlabel(AX(1), func2str(roi.func))
ylabel(AX(1), 'Count')
title(AX(1), 'Distribution of metric used to rank ROI')


%% Bar plot

AX(2) = subplot(3,1,2:3);
%}
AX(2) = subplot(3,1,1:3);
                                              
% Initialize variables for plotting
color = createColorGradient(dark_color, light_color, numel(unique(roi.metric)));
metric_unique = unique(roi.metric);

if any(strcmp(fieldnames(roi),'labels'))
    x_tick_label = roi.labels;
else
    x_tick_label = arrayfun(@(ij) ['(',num2str(roi.index(ij,2)),', ',num2str(roi.index(ij,3)),')'], 1:size(roi.index,1), 'un',0);
end


% Plot
for ij = 1:numel(metric_unique)
    hold (AX(2),'on')
    
    x_ind = roi.metric == metric_unique(ij);
    
    bar(AX(2), roi.metric(x_ind),...
               'XData', find(x_ind),...
               'FaceColor', color(ij,:),...
               'EdgeColor', 'none');

    hold (AX(2),'off')
end

% Format
axis(AX(2),'tight')
box(AX(2),'on')
AX(2).YLim = [floor(AX(2).YLim(1)*100)/100, ceil(AX(2).YLim(2)*100)/100];
AX(2).XTick = 1:numel(roi.metric);
AX(2).YTick = linspace(AX(2).YLim(1), AX(2).YLim(2),3);
xtickangle(AX(2),90)

% Label
AX(2).XTickLabel = x_tick_label;
xlabel(AX(2), '(j,m)')
ylabel(AX(2), func2str(roi.func))


end % end plotROI