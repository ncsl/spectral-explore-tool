function [] = plotFOI(foi)
% function [] = plotFOI(foi)
%
% Function that plots the results of ranking FOI including: Bar graph for bins and bands
%
% Input:
%       - foi: < 1 x 1 > structure array. See rankFOI for documentation.
%
% Output:
%       - None
%
% TODO: Add error bars and other stats
%
% Macauley Breault
% Created: 07-11-2018


figure(sum(uint8(mfilename)))
set(gcf,'Name','FOI')
clf

j = 42;
m = 2;

ij = find(all(foi.index == [j,m],2));

%% Uniform formating

light_color = [0.8039    0.8745    0.9451];
dark_color = [0.0314    0.1882    0.4196];

createColorGradient = @(color1, color2, number) ([linspace(color2(1), color1(1), number); ...
                                              linspace(color2(2), color1(2), number); ...
                                              linspace(color2(3), color1(3), number)])';

                                          
%% Histogram (Bins)

AX(1) = subplot(1,2,1);

% Initialize variables for plotting
[resort,reorder] = sort(foi.order.bin(ij,:));
color_bin = createColorGradient(light_color, dark_color, numel(resort));

% Plot
for f = 1:numel(resort)
    hold(AX(1), 'on')
    
    barh(AX(1), foi.metric.bin(ij,reorder(f)),...
                'XData', f,...
                'FaceColor', color_bin(reorder(f),:),...
                'EdgeColor', 'none');
    
    hold(AX(1), 'off')
end

% Format
axis(AX(1),'tight')
box(AX(1),'on')
AX(1).YLim = [AX(1).YLim(1) - 0.5, AX(1).YLim(2) + 0.5];
AX(1).XTick = linspace(AX(1).XLim(1), AX(1).XLim(2), 3);

% Label
AX(1).XTickLabel = round(AX(1).XTick*100)/100;
xlabel(AX(1), func2str(foi.func))
ylabel(AX(1), 'Bin index')
title(AX(1), 'Bin bar plot')


%% Histogram (Bands)

AX(2) = subplot(1,2,2);

% Initialize variables for plotting
[resort,reorder] = sort(foi.order.band(ij,:));
color_band = createColorGradient(light_color, dark_color, numel(resort));

% Plot
for f = 1:numel(resort)
    hold(AX(2), 'on')
    
    barh(AX(2), foi.metric.band(ij,reorder(f)),...
                'XData', f,...
                'FaceColor', color_band(reorder(f),:),...
                'EdgeColor', 'none');
    
    hold(AX(2), 'off')
end

% Format
axis(AX(2),'tight')
box(AX(2),'on')

% Label
xlabel(AX(2), func2str(foi.func))
ylabel(AX(2), 'Band index')
title(AX(2), 'Band bar plot')


%% Add color bar
colormap(AX(1), color_bin)

c = colorbar(AX(1),'Location','eastoutside','AxisLocation','out');
c_position = get(c,'Position');
set(c,'Position',[AX(2).OuterPosition(1)+AX(2).OuterPosition(3)-0.02 AX(2).Position(2) c_position(3) AX(2).Position(4)]);% [Left Bottom Width Hight] 
set(get(c,'Label'), 'String', 'Rank')
set(c,{'Ticks','TickLength','TickLabels'},{[c.Ticks(1), c.Ticks(end)],[],{'Low','High'}})


end % end plotROI