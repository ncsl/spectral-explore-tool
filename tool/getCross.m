function stat = getCross(y, U, plot_it)
% function stat = getCross(y, U)
%
% Function that calculates the cross-correlation between modulation metric (y) and u
% Also, returns norms
%
% Input:
%       - y: < t x 1 > double vector of modulation metric for one trial
%       - U: < t x m > double vector of temporal singular vector from SVD
%       - (optional) plot_if: boolean as to whether to plot cross correlation or not
%
% Output:
%       - R: < 2*t-1 x m > Double vector of cross-correlation values
%       - lags: < 2*t-1 x m > Double vector of lag indices
%       - corr_values: Structure array of cross-correlation metrics calculated using R and lags
%
% Macauley Breault
% Created: 06-08-2018


%% Check arguments

if ~(~isempty(whos('plot_it')) && ~isempty(plot_it))
    plot_it = 0;
end

validateattributes(y,{'double'},{'column','real','nonnan'})
validateattributes(U,{'double'},{'real','nonnan'})


%% Initialize variables

t   = size(U,1);   % Number of time steps
num = size(U,2);   % Number of singular values

% Normalize y and U
y_norm = y - mean(y);
U_norm = U - mean(U);

stat = struct('R',NaN(2*t-1,num),...
              'lags',NaN(2*t-1,num),...
              'r',NaN(1,num),...
              'p',NaN(1,num),...
              'lag',NaN(1,num),...
              'sign_r',NaN(1,num),...
              'norm1',NaN(1,num),...
              'norm2',NaN(1,num),...
              'normInf',NaN(1,num));
           

%% Validate that user wishes to use different size y and U

if length(y_norm) ~= t
    answer = questdlg(['The neural data and behavioral data have different sampling rates. ',...
        'This may effect the cross-correlation. Do you wish to conintue?'], ...
        'Warning',...
        'Yes','No','Yes');
    
    switch answer
        case 'No'
            return
    end
    
end


%% For every singular value of U... compute cross-correlation statistics

for m=1:num
    
    u = U_norm(:,m);
    
    % % ADD PADS to end of either Y or U (depending on which one is smaller) if they are not the same size
    if numel(y_norm) < numel(u)
        pad_y = numel(u) - numel(y_norm);
        y_norm = [y_norm; zeros(pad_y,1)];
        
    elseif numel(y_norm) > numel(u)
        pad_u = numel(y_norm) - numel(u);
        u = [u; zeros(pad_u,1)];
    end
    
    %% Compute normalized cross-correlation
    [R,lags] = xcorr(y_norm,u,'coeff');
    
    
    %% Plot
    
    if plot_it
        plotCrossCorr(y_norm,u,R)
    end
    
    %% Calculate correlation statistics
    
    % Get absolute maximum
    [r,ii] = max(abs(R));
    lag = lags(ii);
    sign_r = sign(R(ii));
    
    
    % Get P value for max(abs(R))
    place = (ii-1) - ((numel(R)-1) / 2);
    if place > 0 % If place is positive
        [~,p] = corrcoef( [y_norm;zeros(place,1)], [zeros(place,1);u] );
    else % If place is zero or negative
        [~,p] = corrcoef([zeros(abs(place),1);y_norm], [u;zeros(abs(place),1)]);
    end
    p = p(2,1);
    
    
    % Calculate norms
    norm1 = norm(R,1);
    norm2 = norm(R,2);
    normInf = norm(R,'inf');
    
    
    
    %% Save to stats
    
    for field=fieldnames(stat)'
        stat.(field{:})(:,m) = eval(field{:});
    end
    
end




% ==============================
%
%   end main funtion
%
% ==============================
%
%   begin nested functions
%
% ==============================
%%
    % Function that plots the cross correlation
    function [] = plotCrossCorr(y,u,r)
        
        clf
        
        subplot(311)
        plot(u)
        axis tight
        title('u')
        
        subplot(312)
        plot(y)
        axis tight
        title('y')
        
        subplot(313)
        stem(r)
        ylim([-1 1])
        title('Cross-correlation')
        
    end

end % end getCross