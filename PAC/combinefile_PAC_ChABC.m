%%
%First way to do this. This way combines the files that house the pac0 that
%is an output of getlast60s_PM_PAC. DO the first three sections to get
%average and smoothed data for plotting

clear all_pac0;
file_list = dir('*PAC.mat');  % Adjust the pattern to match your filenames
n_animals = length(file_list);

for i = 1:n_animals
    tmp = load(file_list(i).name);  % This loads as a struct
    if isfield(tmp, 'pac0')
        all_pac0(:, :, i) = tmp.pac0;
    else
        warning('%s does not contain pac0', file_list(i).name);
    end
end

% Now average
pac_mean = mean(all_pac0, 3, 'omitnan');

% Plot
phase_freqs = 1:0.2:30;
amp_freqs = 1:0.2:100;

figure;
imagesc(phase_freqs, amp_freqs, pac_mean);
set(gca, 'YDir', 'normal');
xlabel('Phase Freq (Hz)');
ylabel('Amplitude Freq (Hz)');
title('Averaged PAC (Canolty MI)');
colormap jet; colorbar;

% Save
save('PAC_averaged.mat', 'pac_mean', 'all_pac0');
savefig('PAC_averaged.fig');
saveas(gcf, 'PAC_averaged.pdf');

%%

sigma = 4;  % standard deviation of Gaussian kernel; tweak this
% pac0_norm = pac_mean / max(pac_mean(:));
% pac0_smoothed = imgaussfilt(pac0_norm, sigma);

pac0_smoothed = imgaussfilt(pac_mean, sigma);

% Define the frequency axes (match your analysis)
phase_freq = 1:0.2:30;
amp_freq = 1:0.2:100;

% Smooth PAC matrix
% sigma = 1;  % tweak this value
% pac0_smoothed = imgaussfilt(pac_mean, sigma);

% Plot the smoothed heatmap
figure;
imagesc(phase_freq, amp_freq, pac0_smoothed);
set(gca, 'YDir', 'normal');
xlabel('Phase Frequency (Hz)');
ylabel('Amplitude Frequency (Hz)');
title('Smoothed PAC Heatmap');
colormap jet;
colorbar;
set(gca, 'FontSize', 12);

% Save
savefig('Smoothed_PAC_Heatmap.fig');
saveas(gcf, 'Smoothed_PAC_Heatmap.pdf');

%%

% Define windows
delta_band = [1 4];
theta_band = [4 8];      % phase (Hz)
beta_band  = [13 30];    % phase (Hz)
gamma_amp  = [30 100];   % amplitude (Hz)

hold on;
rectangle('Position', ...
    [delta_band(1), gamma_amp(1), ...
     diff(delta_band), diff(gamma_amp)], ...
    'EdgeColor', 'w', 'LineWidth', 2, 'LineStyle', '--');

text(delta_band(1)+0.3, gamma_amp(2)-5, ...
     'δ–γ', ...
     'Color', 'w', 'FontSize', 10);
rectangle('Position', [4, 30, 4, 70], ...
          'EdgeColor', 'w', 'LineWidth', 2, 'LineStyle', '--');
text(4.5, 95, 'θ–γ', 'Color', 'w', 'FontSize', 10);

% Beta–gamma window (13–30 Hz phase, 30–100 Hz amp)
rectangle('Position', [13, 30, 17, 70], ...
          'EdgeColor', 'w', 'LineWidth', 2, 'LineStyle', '--');
text(13.5, 95, 'β–γ', 'Color', 'w', 'FontSize', 10);

% Save as before
savefig('Labeled_PAC_Heatmap.fig');
saveas(gcf, 'Labeled_PAC_Heatmap.pdf');
% Save as before
savefig('Labeled_PAC_Heatmap.fig');
saveas(gcf, 'Labeled_PAC_Heatmap.pdf');



%%
%can also combine this way.Here you would load in the find straight off
%getlast60s and would contain the variable mean_sig0.This way is longer and
%more time consuming. 

clear all
close all
PathName = pwd
file_all = dir(fullfile(PathName,'*.mat'));
matfile = file_all([file_all.isdir] == 0); 
clear file_all PathName
x=[];                               % start w/ an empty array

for i=1:length(matfile)
    x=[x; load(matfile(i).name)];   % get all the .mat files' contents
end

for c=1:length(matfile)
LFP(:,c)=x(c).mean_sig0
end
mean_sig0=LFP
mean_sig0 = mean(LFP, 2); 

% [pac0,ph,amp]=find_pac_shf(mean_LFP(60000:120000),1000,'mi',mean_LFP(60000:120000),[1:0.2:101],[1:0.2:101])
% set(gcf,'position',[0 200 500 400]);colormap jet;set(gcf,'color','w')
% set(gca,'fontsize',12,'linewidth',1,'box','off')%axis setting
% savefig(['Aged_Hip_PAC'])
% saveas(gcf,'Aged_Hip_PAC.pdf')

        %[pac0_raw, ph, amp, pac0] = find_pac_shf_LogTransform(mean_sig0, 1000,'mi',mean_sig0,[1:1:101],[1:1:101]);
        %[pac0, ph, amp] = find_pac_shf(mean_sig0, 1000,'mi',mean_sig0,[1:0.2:12],[30:0.2:100]);
        [pac0, ph, amp] = find_pac_shf(mean_sig0, 1000,'mi',mean_sig0,[1:0.2:20],[30:0.2:100]);
           % Assuming 'pac0' is your PAC signal

        set(gcf,'position',[0 200 500 400]); colormap jet; 
        savefig(['CHABC_Hip_D28'])
        saveas(gcf,'CHABC_D28_Hip_PAC.pdf')
        save(['CHABC_Hip_D28.mat'],'pac0');
%% Load the PAC data from a .mat file
data = load('CHABC_Hip_D28.mat');  % Loads the contents of the file into a struct
pac0 = data.pac0;  % Extract the pac0 variable from the struct
%%
% This is another way to smooth the data and is not as good
span = 50;  % Define the span for the Gaussian smoothing
pac0_smoothed = smoothdata(pac_mean, 'gaussian', span);  % Apply Gaussian smoothing

% Plot the Smoothed PAC Data
figure;
plot(pac0_smoothed, 'LineWidth', 2);  % Plot the smoothed PAC signal
xlabel('Sample Points');  % Label for the x-axis
ylabel('Smoothed PAC Amplitude');  % Label for the y-axis
title('Smoothed Phase-Amplitude Coupling (PAC) Signal');
set(gca, 'FontSize', 12);  % Set axis font size
grid on;  % Add grid to the plot

% Save the plot as a .fig and .pdf file
savefig('Smoothed_PAC_Simple_Plot.fig');
saveas(gcf, 'Smoothed_PAC_Simple_Plot.pdf');
%%
if ismatrix(pac0_smoothed) && ~isvector(pac0_smoothed)  % Check if pac0_smoothed is a matrix (2D)
    figure;
    
    % Define the x-axis (phase frequency 1-12 Hz) and y-axis (amplitude frequency 55-80 Hz)
    phase_freq = 1:0.2:20;  % x-axis (phase frequencies)
    amp_freq = 30:0.2:100;   % y-axis (amplitude frequencies)
    
    % Visualize the smoothed pac0 as a heatmap with the correct axes
    imagesc(phase_freq, amp_freq, pac0_smoothed);  % Use phase_freq and amp_freq as axis data
    colorbar;  % Add a colorbar to indicate magnitude
    colormap jet;  % Use the 'jet' colormap
    xlabel('Phase Frequency (Hz)');  % Label for the x-axis
    ylabel('Amplitude Frequency (Hz)');  % Label for the y-axis
    title('Smoothed PAC Heatmap');
    set(gca, 'FontSize', 12);  % Set axis font size
    set(gca, 'YDir', 'normal');

    % Save the heatmap as a .fig and .pdf file
    savefig('Smoothed_PAC_Heatmap.fig');
    saveas(gcf, 'Smoothed_PAC_Heatmap.pdf');
end

%%

ph = 1:0.2:20;    % Adjust this to match your original analysis
amp = 30:0.2:100;
figure;
imagesc(ph, amp, pac0_smoothed);  % phase on x, amp on y
set(gca, 'YDir', 'normal');  % y-axis low to high
xlabel('Phase Frequency (Hz)');
ylabel('Amplitude Frequency (Hz)');
title('PAC Comodulogram');
colormap jet;
colorbar;

% OPTIONAL: Highlight theta–gamma window (4–12 Hz phase, 30–100 Hz amp)
hold on;
rectangle('Position', [4, 30, 8, 70], 'EdgeColor', 'w', 'LineWidth', 2, 'LineStyle', '--');
text(4.5, 95, 'θ–γ window', 'Color', 'w', 'FontSize', 10);

% OPTIONAL: Mark peak PAC value
[max_val, max_idx] = max(pac0(:));
[amp_idx, ph_idx] = ind2sub(size(pac0), max_idx);
plot(ph(ph_idx), amp(amp_idx), 'wx', 'MarkerSize', 10, 'LineWidth', 2);


%%

