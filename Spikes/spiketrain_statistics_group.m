%% vertical rain cloud
% Load the data from the text files
%for beads data Treatment 1 is teal and treatment 2 is pink
group1_data = readtable('I:\PM2024-Q7289\MNDephys\Dongsheng\sorted\Spike analysis\PN late controls.txt', 'Delimiter', '\t');
group2_data = readtable('I:\PM2024-Q7289\MNDephys\Dongsheng\sorted\Spike analysis\PN late MND.txt', 'Delimiter', '\t');


% Extract CVs and Number of Bursts
group1_CVs = group1_data.CV_ISI;
group1_bursts = group1_data.NumBursts;
group1_burstiness = group1_data.ISI_Burstiness;
group2_CVs = group2_data.CV_ISI;
group2_bursts = group2_data.NumBursts;
group2_burstiness = group2_data.ISI_Burstiness;

% Add path to the raincloud plot function
addpath('I:\MBLAB1-Q3474\Phoebe\Microbeads_Experiment\Electrophsyiology\CVs and Bursts\RainCloudPlots-master\tutorial_matlab');

% Create a figure for rain cloud plots
figure;

% Plotting the rain cloud plots for CVs
subplot(1, 3, 1);
raincloud_plot(group1_CVs, 'color', [0.5, 0.5, 0.5], 'box_on', 1, 'box_col', [0.5, 0.5, 0.5], 'alpha', 0.5, 'cloud_edge_col', [0.5, 0.5, 0.5], 'dot_edge_col', [0 0 0], 'orientation', 'right', 'box_dodge', 1, 'box_dodge_amount', 0.4, 'dot_dodge_amount', 0.4, 'box_col_match', 1,'band_width', 0.8);
hold on;
raincloud_plot(group2_CVs, 'color', [1.0 0.55 0.55], 'box_on', 1, 'box_col', [1.0 0.55 0.55], 'alpha', 0.5, 'cloud_edge_col', [1.0 0.55 0.55], 'dot_edge_col', [0 0 0], 'orientation', 'right', 'box_dodge', 1, 'box_dodge_amount', 0.2, 'dot_dodge_amount', 0.2, 'box_col_match', 1, 'band_width', 0.8);
hold off;

% Set the y-axis
%ylim([-0.4 1.5]);
% Set the x-axis ticks to 0, 0.5, and 1
%yticks([-0.4 -0.2 0 0.2 0.4 0.6 0.8 1]);
xlim([0 10]);
yticks([]); 
xlabel('CVs');
%title('Comparison of CVs between ChABC and Saline Groups');
set(gca, 'FontSize', 12, 'LineWidth', 1);
grid on;

% Plotting the rain cloud plots for Number of Bursts
subplot(1, 3, 2);
raincloud_plot(group1_bursts, 'color', [0.5, 0.5, 0.5], 'box_on', 1, 'box_col', [0.5, 0.5, 0.5], 'alpha', 0.5, 'cloud_edge_col', [0.5, 0.5, 0.5], 'dot_edge_col', [0 0 0], 'orientation', 'right', 'box_dodge', 1, 'box_dodge_amount', 0.4, 'dot_dodge_amount', 0.4, 'box_col_match', 0.2);
hold on;
raincloud_plot(group2_bursts, 'color', [1.0 0.55 0.55], 'box_on', 1, 'box_col', [1.0 0.55 0.55], 'alpha', 0.5, 'cloud_edge_col', [1.0 0.55 0.55], 'dot_edge_col', [0 0 0], 'orientation', 'right', 'box_dodge', 1, 'box_dodge_amount', 0.2, 'dot_dodge_amount', 0.2, 'box_col_match', 0.2);
hold off;

% Set the y-axis
%ylim([-0.005 0.05]);
% Set the x-axis ticks to 0, 0.5, and 1
%yticks([-0.005 0 0.01 0.02 0.03 0.04 0.05]);
xlim([-500 5000]);
yticks([]); 
xlabel('Number of Bursts');
%title('Comparison of Number of Bursts between ChABC and Saline Groups');
set(gca, 'FontSize', 12, 'LineWidth', 1);
grid on;

% Save the figure
saveas(gcf, pwd);
saveas(gcf, pwd);

% Plotting the rain cloud plots for Burstiness
subplot(1, 3, 3);
raincloud_plot(group1_burstiness, 'color', [0.5, 0.5, 0.5], 'box_on', 1, 'box_col', [0.5, 0.5, 0.5], 'alpha', 0.5, 'cloud_edge_col', [0.5, 0.5, 0.5], 'dot_edge_col', [0 0 0], 'orientation', 'right', 'box_dodge', 1, 'box_dodge_amount', 0.4, 'dot_dodge_amount', 0.4, 'box_col_match', 1,'band_width', 0.4);
hold on;
raincloud_plot(group2_burstiness, 'color', [1.0 0.55 0.55], 'box_on', 1, 'box_col', [1.0 0.55 0.55], 'alpha', 0.5, 'cloud_edge_col', [1.0 0.55 0.55], 'dot_edge_col', [0 0 0], 'orientation', 'right', 'box_dodge', 1, 'box_dodge_amount', 0.2, 'dot_dodge_amount', 0.2, 'box_col_match', 1,'band_width', 0.4);
hold off;

% Set the y-axis
%ylim([-0.005 0.05]);
% Set the x-axis ticks to 0, 0.5, and 1
%yticks([-0.005 0 0.01 0.02 0.03 0.04 0.05]);
xlim([-0.500 2.000]);
yticks([]); 
xlabel('ISI Burstiness');
%title('Comparison of Number of Bursts between ChABC and Saline Groups');
set(gca, 'FontSize', 12, 'LineWidth', 1);
grid on;

% Save the figure
saveas(gcf, pwd);
saveas(gcf, pwd);

% Perform statistical tests
% Normality test (Lilliefors test)
[h_group1_CV, p_group1_CV] = lillietest(group1_CVs);
[h_group2_CV, p_group2_CV] = lillietest(group2_CVs);
[h_group1_bursts, p_group1_bursts] = lillietest(group1_bursts);
[h_group2_bursts, p_group2_bursts] = lillietest(group2_bursts);
[h_group1_burstiness, p_group1_burstiness] = lillietest(group1_burstiness);
[h_group2_burstiness, p_group2_burstiness] = lillietest(group2_burstiness);

% If data is normally distributed, use t-test; otherwise, use Mann-Whitney U test
if h_group1_CV == 0 && h_group2_CV == 0
    [h_CV, p_CV] = ttest2(group1_CVs, group2_CVs);
else
    [p_CV, h_CV] = ranksum(group1_CVs, group2_CVs);
end


if h_group1_bursts == 0 && h_group2_bursts == 0
    [h_bursts, p_bursts] = ttest2(group1_bursts, group2_bursts);
else
    [p_bursts, h_bursts] = ranksum(group1_bursts, group2_bursts);
end

if h_group1_burstiness == 0 && h_group2_burstiness == 0
    [h_burstiness, p_burstiness] = ttest2(group1_burstiness, group2_burstiness);
else
    [p_burstiness, h_burstiness] = ranksum(group1_burstiness, group2_burstiness);
end

% Display the results of the statistical tests
disp('Statistical Test Results:');
fprintf('CV Comparison: p-value = %.4f (significant: %d)\n', p_CV, h_CV);
fprintf('Number of Bursts Comparison: p-value = %.4f (significant: %d)\n', p_bursts, h_bursts);
fprintf('Burstiness Comparison: p-value = %.4f (significant: %d)\n', p_burstiness, h_burstiness);