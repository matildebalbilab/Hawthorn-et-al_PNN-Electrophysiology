% Close all figures and clear workspace
close all; clear;

% Load your correlation matrices
load('RSC_Hip_Ch.mat');   % ChABC group
corr_Ch = corr;

load('RSC_Hip_S.mat');   % Saline group
corr_S = corr;

% Define lag axis for full range (-500 ms to +500 ms)
lags_ms = linspace(-500, 500, size(corr_Ch, 2));

% === Compute group means ===
mean_corr_Ch = mean(corr_Ch, 1);
mean_corr_S = mean(corr_S, 1);

% === Find true peaks across full range ===
[true_peak_Ch, true_idx_Ch] = max(mean_corr_Ch);
[true_peak_S, true_idx_S] = max(mean_corr_S);
true_lag_Ch = lags_ms(true_idx_Ch);
true_lag_S = lags_ms(true_idx_S);

% === Plot full lag range ===
figure('Name', 'Full Lag Range and Zoomed View', 'Color', 'w', 'Position', [100 100 800 400]);

subplot(1,2,1); % Left panel
hold on;
% Plot shaded error regions
stdshade(corr_S, 0.3, [0.9 0.9 0.9], lags_ms); % Saline
plot(lags_ms, mean_corr_S, 'Color', [0.5 0.5 0.5], 'LineWidth', 1);

stdshade(corr_Ch, 0.3, [0.96 0.5 0.77], lags_ms); % ChABC
plot(lags_ms, mean_corr_Ch, 'Color', [0.93 0 0.54], 'LineWidth', 1.2);

% Mark peaks
plot(true_lag_Ch, true_peak_Ch, 'o', 'MarkerEdgeColor', [0.93 0 0.54], 'MarkerFaceColor', [0.93 0 0.54], 'MarkerSize', 6);
plot(true_lag_S, true_peak_S, 'o', 'MarkerEdgeColor', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerSize', 6);

title('Full Lag Range (-500 to +500 ms)');
xlabel('Lag (ms)');
ylabel('Correlation coefficient');
ylim([-1 1]);
xlim([-500 500]);
legend({'Saline', 'ChABC'}, 'Location', 'northeast');
set(gca, 'FontSize', 10, 'Box', 'off');

% === Zoomed view (±25 ms) ===
subplot(1,2,2); % Right panel
hold on;
% Re-define zoomed axis
zoom_idx = lags_ms >= -25 & lags_ms <= 25;
lags_zoom = lags_ms(zoom_idx);

% Plot zoomed shaded regions and means
stdshade(corr_S(:,zoom_idx), 0.3, [0.9 0.9 0.9], lags_zoom);
plot(lags_zoom, mean_corr_S(zoom_idx), 'Color', [0.5 0.5 0.5], 'LineWidth', 1);

stdshade(corr_Ch(:,zoom_idx), 0.3, [0.96 0.5 0.77], lags_zoom);
plot(lags_zoom, mean_corr_Ch(zoom_idx), 'Color', [0.93 0 0.54], 'LineWidth', 1.2);

% Mark peaks (only if within zoomed range)
if true_lag_Ch >= -25 && true_lag_Ch <= 25
    plot(true_lag_Ch, true_peak_Ch, 'o', 'MarkerEdgeColor', [0.93 0 0.54], 'MarkerFaceColor', [0.93 0 0.54], 'MarkerSize', 6);
end
if true_lag_S >= -25 && true_lag_S <= 25
    plot(true_lag_S, true_peak_S, 'o', 'MarkerEdgeColor', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerSize', 6);
end

title('Zoomed View (±25 ms)');
xlabel('Lag (ms)');
ylim([-1 1]);
xlim([-25 25]);
set(gca, 'FontSize', 10, 'Box', 'off');

% === Print true peak information ===
fprintf('ChABC peak at %.2f ms (r = %.2f)\n', true_lag_Ch, true_peak_Ch);
fprintf('Saline peak at %.2f ms (r = %.2f)\n', true_lag_S, true_peak_S);

% Save figure
saveas(gcf, 'Corr_Full_and_Zoomed.pdf');



% % Close figures and clear workspace
% close all; clear;
% 
% % Load correlation matrices for both treatment groups
% load('RSC_Hip_Ch.mat');   % ChABC group correlation matrix
% corr_Ch = corr;
% 
% load('RSC_Hip_S.mat');    % Saline group correlation matrix
% corr_S = corr;
% 
% % Define lag axis in milliseconds (1001 samples from -25 ms to 25 ms)
% lags_ms = linspace(-25, 25, size(corr_Ch, 2));
% 
% %% === Plot 1: Full range ±25 ms ===
% figure;
% stdshade(corr_S, 0.3, [0.9 0.9 0.9], lags_ms); hold on;
% plot(lags_ms, mean(corr_S), 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);
% 
% stdshade(corr_Ch, 0.3, [0.9628 0.5 0.7745], lags_ms);
% plot(lags_ms, mean(corr_Ch), 'Color', [0.9255 0 0.5490], 'LineWidth', 1.2);
% 
% xlim([-25 25]);
% ylim([-1 1]);
% xticks([-25 0 25]);
% xlabel('Lag (ms)');
% ylabel('Correlation coefficient');
% title('RSC–CA1 Gamma-Band Correlation (±25 ms)');
% legend({'Saline', 'ChABC'}, 'Location', 'northeast');
% 
% [peak_Ch, idx_Ch] = max(mean(corr_Ch, 1));
% [peak_S, idx_S] = max(mean(corr_S, 1));
% 
% % Plot peaks
% plot(lags_ms(idx_Ch), peak_Ch, 'o', ...
%      'MarkerEdgeColor', [0.93 0 0.55], ...
%      'MarkerFaceColor', [0.93 0 0.55], ...
%      'MarkerSize', 5);
% plot(lags_ms(idx_S), peak_S, 'o', ...
%      'MarkerEdgeColor', [0.5 0.5 0.5], ...
%      'MarkerFaceColor', [0.5 0.5 0.5], ...
%      'MarkerSize', 5);
% 
% set(gca, 'FontSize', 9, 'FontName', 'Arial', 'LineWidth', 0.75, ...
%          'Box', 'off', 'XColor', 'k', 'YColor', 'k');
% set(gcf, 'Color', 'w', 'Position', [100, 100, 360, 320]);
% 
% saveas(gcf, 'ThetaCorr_RSC_CA1_25ms.pdf');
% saveas(gcf, 'ThetaCorr_RSC_CA1_25ms.fig');
% saveas(gcf, 'ThetaCorr_RSC_CA1_25ms.tif');
% 
% %% === Plot 2: Zoomed-in ±5 ms ===
% figure;
% stdshade(corr_S, 0.3, [0.9 0.9 0.9], lags_ms); hold on;
% plot(lags_ms, mean(corr_S), 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);
% 
% stdshade(corr_Ch, 0.3, [0.9628 0.5 0.7745], lags_ms);
% plot(lags_ms, mean(corr_Ch), 'Color', [0.9255 0 0.5490], 'LineWidth', 1.2);
% 
% xlim([-5 5]);
% ylim([-1 1]);
% xticks([-5 0 5]);
% xlabel('Lag (ms)');
% ylabel('Correlation coefficient');
% title('RSC–CA1 Gamma-Band Correlation (±5 ms)');
% legend({'Saline', 'ChABC'}, 'Location', 'northeast');
% 
% % Identify and mark peak values within ±5 ms window
% idx_zoom = lags_ms >= -5 & lags_ms <= 5;
% 
% % ChABC peak
% [peak_Ch, idx_Ch_rel] = max(mean(corr_Ch(:, idx_zoom), 1));
% idx_Ch = find(idx_zoom, 1, 'first') + idx_Ch_rel - 1;
% plot(lags_ms(idx_Ch), peak_Ch, 'o', ...
%      'MarkerEdgeColor', [0.9255 0 0.5490], ...
%      'MarkerFaceColor', [0.9255 0 0.5490], ...
%      'MarkerSize', 4);
% 
% % Saline peak
% [peak_S, idx_S_rel] = max(mean(corr_S(:, idx_zoom), 1));
% idx_S = find(idx_zoom, 1, 'first') + idx_S_rel - 1;
% plot(lags_ms(idx_S), peak_S, 'o', ...
%      'MarkerEdgeColor', [0.5 0.5 0.5], ...
%      'MarkerFaceColor', [0.5 0.5 0.5], ...
%      'MarkerSize', 4);
% 
% set(gca, 'FontSize', 9, 'FontName', 'Arial', 'LineWidth', 0.75, ...
%          'Box', 'off', 'XColor', 'k', 'YColor', 'k');
% set(gcf, 'Color', 'w', 'Position', [500, 100, 360, 320]);
% 
% saveas(gcf, 'ThetaCorr_RSC_CA1_5ms.pdf');
% saveas(gcf, 'ThetaCorr_RSC_CA1_5ms.fig');
% saveas(gcf, 'ThetaCorr_RSC_CA1_5ms.tif');
% 
% %%
% lags_ms = linspace(-500, 500, size(corr_Ch, 2));
% [true_peak_Ch, true_idx_Ch] = max(mean(corr_Ch, 1));
% [true_peak_S, true_idx_S] = max(mean(corr_S, 1));
% 
% true_lag_Ch = lags_ms(true_idx_Ch);
% true_lag_S = lags_ms(true_idx_S);
% 
% fprintf('ChABC peak at %.2f ms (r = %.2f)\n', true_lag_Ch, true_peak_Ch);
% fprintf('Saline peak at %.2f ms (r = %.2f)\n', true_lag_S, true_peak_S);
% close all
% load('RSC_Hip_Ch.mat')
% stdshade(corr,0.2,'m',0:0.5:500);hold on
% load('RSC_Hip_S.mat')
% stdshade(corr,0.2,'k',0:0.5:500);
% xlim([0 1000]);ylim([-1 1]);xlabel('Time (ms)');ylabel('Correlation coefficient')
% xticks([0:100:1000])
% xticklabels({'-500','100','500'})
% set(gca,'fontsize',10,'fontname','arial','linewidth',1,'box','off','XColor','k', 'YColor','k')
% set(gcf,'color','w')
% set(gcf,'position',[10 100 200 200])
% saveas(gcf,['Motor_Motor.pdf'])
% saveas(gcf,['Motor_Motor.fig'])
% saveas(gcf,['Motor_Motor.tif'])

% close all
% load('RSC_Hip_Ch.mat')
% stdshade(corr,0.2,'m',0:0.5:500);hold on
% load('RSC_Hip_S.mat')
% stdshade(corr,0.2,'k',0:0.5:500);
% xlim([245 255]);ylim([-1 1]);xlabel('Time (ms)');ylabel('Correlation coefficient')
% xticks([245:5:255])
% xticklabels({'-5','0','5'})
% set(gca,'fontsize',10,'fontname','arial','linewidth',1,'box','off','XColor','k', 'YColor','k')
% set(gcf,'color','w')
% set(gcf,'position',[10 100 200 200])
% saveas(gcf,['Motor_Motor.pdf'])
% saveas(gcf,['Motor_Motor.fig'])
% saveas(gcf,['Motor_Motor.tif'])



% % Close figures and clear workspace
% close all; clear;
% 
% % Load correlation matrices for both treatment groups
% load('RSC_Hip_Ch.mat');   % Contains variable 'corr' for ChABC group
% corr_Ch = corr;
% 
% load('RSC_Hip_S.mat');    % Contains variable 'corr' for Saline group
% corr_S = corr;
% 
% % Define lag axis in milliseconds (assumes 1001 samples from -25 to 25 ms)
% lags_ms = linspace(-25, 25, size(corr_Ch, 2));
% 
% % Saline group - light grey shaded area, medium grey line
% stdshade(corr_S, 0.3, [0.9 0.9 0.9], lags_ms);  % Shaded area
% plot(lags_ms, mean(corr_S), 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);  % Line
% 
% % ChABC group - light pink shaded area, bright pink line
% stdshade(corr_Ch, 0.3, [0.9628 0.5 0.7745], lags_ms);    
% plot(lags_ms, mean(corr_Ch), 'Color', [0.9255 0 0.5490], 'LineWidth', 1.2);
% 
% 
% % Zoom in to ±5 ms
% xlim([-25 25]);
% xticks([-25 0 25]);
% xticklabels({'-25', '0', '25'});
% ylim([-1 1]);
% yticks([-1 -0.5 0 0.5 1]);
% 
% % Add labels
% xlabel('Lag (ms)');
% ylabel('Correlation coefficient');
% title('RSC–CA1 Gamma-Band Correlation (±10 ms)');
% 
% % Find peak correlation in the ±5 ms window
% idx_zoom = lags_ms >= -5 & lags_ms <= 5;
% 
% % ChABC peak
% [peak_Ch, idx_Ch_rel] = max(mean(corr_Ch(:, idx_zoom), 1));
% idx_Ch = find(idx_zoom, 1, 'first') + idx_Ch_rel - 1;
% 
% plot(lags_ms(idx_Ch), peak_Ch, 'o', ...
%      'MarkerEdgeColor', [0.9255 0 0.5490], ...
%      'MarkerFaceColor', [0.9255 0 0.5490], ...
%      'MarkerSize', 3);
% % Saline peak
% [peak_S, idx_S_rel] = max(mean(corr_S(:, idx_zoom), 1));
% idx_S = find(idx_zoom, 1, 'first') + idx_S_rel - 1;
% 
% plot(lags_ms(idx_S), peak_S, 'o', ...
%      'MarkerEdgeColor', [0.9 0.9 0.9], ...
%      'MarkerFaceColor', [0.9 0.9 0.9], ...
%      'MarkerSize', 3);
% 
% 
% % Add legend
% legend({'ChABC', 'Saline'}, 'Location', 'northeast');
% 
% % Figure and axis aesthetics
% set(gca, 'FontSize', 9, ...
%          'FontName', 'Arial', ...
%          'LineWidth', 0.75, ...
%          'Box', 'off', ...
%          'XColor', 'k', ...
%          'YColor', 'k');
% 
% set(gcf, 'Color', 'w');
% set(gcf, 'Position', [100, 100, 360, 320]);  % Narrow and tall figure
% 
% % Save figure in multiple formats
% saveas(gcf, 'GammaCorr_RSC_CA1_25ms_narrow.pdf');
% saveas(gcf, 'GammaCorr_RSC_CA1_25ms_narrow.fig');
% saveas(gcf, 'GammaCorr_RSC_CA1_25ms_narrow.tif');
