% Add NPMK toolbox path
%addpath('C:\Users\uqdxiao1\Desktop\ephys_code\NPMK');
addpath(genpath('I:\MBLAB1-Q3474\Phoebe\Codes for Ephys 2024\NPMK-master_2024\'));
savepath;
%
clear all
% Load the NS6 file
%lfp_data = 'D:\Balbi\balbc\balbc_953957_d7_gcamp1.ns6';
lfp_data = 'I:\PM2024-Q7289\MNDephys\Dongsheng\MND82_D21_gcamp1.ns6';
%lfp_data = 'Z:\Phoebe\MND\electrophysiology\MND63_D28_gcamp2.ns6';

%Define Common Saving Directory
commonSaveDir = pwd;

% Create directory if it doesn't exist
if ~exist(commonSaveDir, 'dir')
    mkdir(commonSaveDir);
end

openNSx(lfp_data);
lfp_data = NS6.Data; % This is just an example, generating random data
lfp_data = double(lfp_data);
numChannelsToPlot = 8;
sampling_rate = 30000; % Example sampling rate in Hz, adjust as needed
%
% for i = 1:numChannelsToPlot
%     subplot(numChannelsToPlot, 1, i);
%     % Assuming each channel is a row and data is sampled at 30 kHz
%     % Adjust the time vector if your sampling rate is different
%     t = (1:length(lfp_data(i, :))) / sampling_rate;
%     plot(t, lfp_data(i, :));
%     title(['Channel ' num2str(i)]);
%     xlabel('Time (s)');
%     ylabel('Amplitude');
%     ylim([-2000 2000]); 
% end
%%
% Find global minimum and maximum across all channels
globalMin = min(lfp_data(:));
globalMax = max(lfp_data(:));

% Add a small margin around the limits
margin = 50;  % Adjust margin as needed
commonYLim = [globalMin - margin, globalMax + margin];

for i = 1:numChannelsToPlot
    subplot(numChannelsToPlot, 1, i);
    t = (1:length(lfp_data(i, :))) / sampling_rate;
    plot(t, lfp_data(i, :));
    title(['Channel ' num2str(i)]);
    xlabel('Time (s)');
    ylabel('Amplitude (μV)');
    ylim(commonYLim);  % Use the dynamically determined y-limits
end

%select a range to plot
%
% Assuming 'NS6.Data' contains the LFP data
lfp_data = double(NS6.Data);
numChannels = size(lfp_data, 1); % Get the total number of channels
sampling_rate = 30000; % Adjust as needed

% Define the cutoff frequency for the high-pass filter
cutoff_freq = 300; % Example: 300 Hz
order = 4; % Filter order

% Normalize the cutoff frequency with respect to Nyquist frequency
nyquist_freq = sampling_rate / 2;
normalized_cutoff_freq = cutoff_freq / nyquist_freq;

% Use butter to create a high-pass filter (returns the filter coefficients)
[b, a] = butter(order, normalized_cutoff_freq, 'high');

% Prepare a matrix to hold the filtered data
filtered_lfp_data = zeros(size(lfp_data));

% Apply the filter to each channel
for ch = 1:numChannels
    filtered_lfp_data(ch, :) = filtfilt(b, a, lfp_data(ch, :));
end

% Define the time range to plot (in seconds)
start_time = 1; % Start time in seconds
end_time = 150;   % End time in seconds

% Convert time to indices
start_index = round(start_time * sampling_rate) + 1;
end_index = round(end_time * sampling_rate);

% Plot the filtered channels for the defined time range
figure('Units', 'normalized', 'Position', [0, 0, 1, 1]);
for i = 1:numChannels
    subplot(numChannels, 1, i);
    t = (start_index:end_index) / sampling_rate;
    plot(t, filtered_lfp_data(i, start_index:end_index));
    title(['Filtered Channel ' num2str(i)]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-5000 5000]); 
end

%% Choose one channel as reference.

% Define the cutoff frequency for the high-pass filter
cutoff_freq = 300; % Example: 300 Hz
order = 4; % Filter order

% Normalize the cutoff frequency with respect to Nyquist frequency
nyquist_freq = sampling_rate / 2;
normalized_cutoff_freq = cutoff_freq / nyquist_freq;

% Use butter to create a high-pass filter (returns the filter coefficients)
[b, a] = butter(order, normalized_cutoff_freq, 'high');

% Define the time range to plot (in seconds)
start_time = 1; % Start time in seconds
end_time = 2;   % End time in seconds

% Convert time range to indices
start_index = round(start_time * sampling_rate) + 1;
end_index = round(end_time * sampling_rate);

 
%Create new differential channels using Channel 1 as the reference
new_channels = bsxfun(@minus, lfp_data([5:6],:), lfp_data(7, :));
%new_channels = [lfp_data(1,:); lfp_data(7,:); new_channels(2,:)];
%new_channels = [lfp_data(1,:); lfp_data(5,:); new_channels];
%new_channels = [lfp_data(2,:); lfp_data(6,:)];
%new_channels = bsxfun(@minus, lfp_data(6, :), lfp_data(5, :));
%if only one channel: 
%new_channels = filtered_lfp_data([5,6,7,8], :);

%Filter the new differential channels
filtered_new_channels = zeros(size(new_channels));
for i = 1:size(new_channels, 1)
    filtered_new_channels(i, :) = filtfilt(b, a, new_channels(i, :));
end

start_time = 0; % Start time in seconds
end_time = 300;   % End time in seconds

% Convert time to indices
start_index = round(start_time * sampling_rate) + 1;
end_index = round(end_time * sampling_rate);
% Prepare the time vector for plotting the selected range
%t = (start_index:end_index) / sampling_rate;
% Clip to data length
max_index = size(filtered_new_channels, 2);
end_index = min(end_index, max_index);
start_index = max(1, start_index);

% Time vector
t = (start_index:end_index) / sampling_rate;
t = (start_index:end_index) / sampling_rate;

%Plot the filtered differential channels for the defined time range
figure;
for i = 1:size(filtered_new_channels, 1)
    subplot(size(filtered_new_channels, 1), 1, i);
    plot(t - t(1), filtered_new_channels(i, start_index:end_index)); % Adjust time vector so it starts at 0
    title(['High-pass Filtered Channel ' num2str(i+1) ' - Channel 1 (Cutoff: ' num2str(cutoff_freq) ' Hz)']);
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-2000 2000]); 
end
% for i = 1:size(new_channels, 1)
%     subplot(size(new_channels, 1), 1, i);
%     plot(t - t(1), new_channels(i, start_index:end_index)); % Adjust time vector so it starts at 0
%     title(['High-pass Filtered Channel ' num2str(i+1) ' - Channel 1 (Cutoff: ' num2str(cutoff_freq) ' Hz)']);
%     xlabel('Time (s)');
%     ylabel('Amplitude');
%     ylim([-5000 5000]); 
% end
set(gcf, 'Units', 'normalized', 'Position', [0, 0, 1, 1]);
% %% Adjust figure size and layout
% set(gcf, 'Units', 'normalized', 'Position', [0, 0, 1, 1]);
% %save(fullfile(commonSaveDir, 'filtered_lfp_data.mat'), 'filtered_lfp_data');
% 
% 
% % Example data
% % spike_data = randn(1, 1000) * 300;  % Generate random spike data for illustration
% % spike_data = spike_data + 500 * (rand(1, 1000) > 0.98);  % Adding random spikes above 500 µV
% 
% % Define threshold
% threshold = 500;  % 500 µV
% 
% % Find the spikes above the threshold
% above_threshold = abs(filtered_new_channels) > threshold;
% 
% % Subtract or remove spikes above the threshold
% % You can either set them to zero or apply other filtering
% filtered_new_channels(above_threshold) = 0;  % Set spikes above the threshold to zero
% 
% % Plot the original and cleaned spike data
% figure;
% subplot(2,1,1);
% plot(spike_data);
% title('Spike Data After Removing Spikes > 500 µV');
% xlabel('Time (samples)');
% ylabel('Amplitude (µV)');
% 
% subplot(2,1,2);
% plot(abs(spike_data));
% title('Absolute Value of Cleaned Spike Data');
% xlabel('Time (samples)');
% ylabel('Amplitude (µV)');
%%
% Define the cutoff frequency for the high-pass filter
cutoff_freq = 300; % Example: 300 Hz
order = 4; % Filter order

% Normalize the cutoff frequency with respect to Nyquist frequency
nyquist_freq = sampling_rate / 2; % NOTE: it should be /2, not /4
normalized_cutoff_freq = cutoff_freq / nyquist_freq;

% Create a high-pass Butterworth filter
[b, a] = butter(order, normalized_cutoff_freq, 'high');

% Create new differential channels using Channel 5 as reference
new_channels = bsxfun(@minus, lfp_data(6,:), lfp_data(5,:));

% Filter the new differential channels
filtered_new_channels = zeros(size(new_channels));
for i = 1:size(new_channels, 1)
    filtered_new_channels(i, :) = filtfilt(b, a, new_channels(i, :));
end

% Define the time range to plot (in seconds)
start_time = 0;  % Start time in seconds
end_time = 300;  % End time in seconds

% Convert time range to indices
start_index = round(start_time * sampling_rate) + 1;
end_index = round(end_time * sampling_rate);

% Prevent index from exceeding the available data
max_index = size(filtered_new_channels, 2);
if end_index > max_index
    end_index = max_index;
end

% Prepare the time vector for plotting the selected range
t = (start_index:end_index) / sampling_rate;

% Plot the filtered differential channels
figure;
for i = 1:size(filtered_new_channels, 1)
    subplot(size(filtered_new_channels, 1), 1, i);
    plot(t - t(1), filtered_new_channels(i, start_index:end_index)); % Adjust time to start at 0
    title(['High-pass Filtered Channel ' num2str(i + 5) ' - Channel 5 (Cutoff: ' num2str(cutoff_freq) ' Hz)']);
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-7000 7000]);
end

% Maximize figure window
set(gcf, 'Units', 'normalized', 'Position', [0, 0, 1, 1]);




%% spike sorting use wave clus from here 
% save data for wave clus
% Step 1: Save Individual Channel Data
commonSaveDir = pwd;

% Loop through each channel and save its data
for ch = 1:size(filtered_new_channels, 1)
    data = filtered_new_channels(ch, :)'; % Transpose for Wave_clus
    sr = sampling_rate; % Define the sampling rate
    filename = fullfile(commonSaveDir, sprintf('channel_%d.mat', ch));
    save(filename, 'data', 'sr');
end

% create txt
%Step 2: Create Text Files for Polytrodes
% Define the polytrode channels
polytrodeChannels = {1:3}; % Array of arrays, each sub-array is a set of channels for a polytrode

% Loop through each polytrode and create a text file
for p = 1:length(polytrodeChannels)
    fileID = fopen(fullfile(commonSaveDir, sprintf('polytrode%d.txt', p)), 'w');
    for ch = polytrodeChannels{p}
        fprintf(fileID, 'channel_%d.mat\n', ch);
    end
    fclose(fileID);
end


%
%Step 3: Running Spike Detection and Clustering
% Run for each polytrode
for p = 1:length(polytrodeChannels)
    Get_spikes_pol(p);
    Do_clustering(p);
end

wave_clus;
%***manually open wave_clus in the command window and sort through the spikes
%and update the sorted file as time_polytrode1.mat
%%
% Load the sorted data file
%commonSaveDir = 'I:\MBLAB1-Q3474\Montana\Healthy_Ageing_Ephys\Aged_Montana\ephys_alone\hip_mot\361263\Left motor - 1-4\new new';
commonSaveDir = pwd;
load('times_polytrode1.mat'); % Replace with your file name

% The variable 'cluster_class' contains two columns:
% Column 1: Cluster numbers
% Column 2: Spike times


% Extracting individual clusters
numClusters = max(cluster_class(:,1));
spike_trains = cell(numClusters, 1);

for i = 1:numClusters
    spike_trains{i} = cluster_class(cluster_class(:,1) == i, 2)/1000;
end


% Plotting spike trains
figure;
hold on;
for i = 1:numClusters
    spikes = spike_trains{i};
    for j = 1:length(spikes)
        plot([spikes(j), spikes(j)], [i-0.4, i+0.4], 'k'); % Creates a vertical line for each spike
    end
end
xlabel('Time (ms)');
ylabel('Cluster');
title('Spike Trains of Each Cluster');
xlim([0, max(cluster_class(:,2))/1000]); % Adjust x-axis to show entire time range
hold off;

% Save the spike trains
save(fullfile(commonSaveDir, 'spike_trains.mat'), 'spike_trains');

%%
%calulate the firing rate
commonSaveDir = pwd;
% Load the spike train data from the file
data = load('spike_trains.mat');
% % Extract the spike trains variable
spike_trains = data.spike_trains;
% Open a file to save the firing rates
%commonSaveDir = 'I:\MBLAB1-Q3474\Montana\Healthy_Ageing_Ephys\Young Phoebe\M66\RH\spiketrain_CJ';
fileID = fopen(fullfile(commonSaveDir, 'firing_rates.txt'), 'w');
firing_rate_data = [];
% Loop over each spike train
for i = 1:length(spike_trains)
    % Extract the spike times for the current train
    spike_times = spike_trains{i};
    % Calculate the number of spikes
    num_spikes = length(spike_times);
    % Calculate the duration of the spike train
   
    % Compute the firing rate (spikes per second)
    if num_spikes > 0
         duration = max(spike_times) - 0;
         firing_rate = num_spikes / duration;
    else 
        firing_rate = 0; 
    end 
    % Save the firing rate to the text file
    fprintf(fileID, 'Spike Train %d: Firing Rate = %.4f spikes/s\n', i, firing_rate);
    firing_rate_data = [firing_rate_data; i, firing_rate];
end
% Close the text file
fclose(fileID);
writematrix(firing_rate_data, fullfile(commonSaveDir, 'firing_rates.xlsx'), 'FileType', 'spreadsheet');
% Display a message indicating the file has been saved
disp('Firing rates have been saved to firing_rates.txt');




%% 
%Parameters for Autocorrelation and PSD
maxLag = 100;      % Maximum lag for autocorrelation
binSize = 1;       % Bin size in milliseconds
window = 128;      % Window size for PSD
noverlap = [];     % Overlap for PSD
nfft = 512;        
% Number of FFT points for PSD
% sampling_rate = 1000; % Sampling rate in Hz (example, change as needed)
% end_time = 1000;   % Define the total duration of the recording in ms (change as needed)
% saveDir = 'path_to_save_dir'; % Set this to the directory where you want to save the plots
results = struct();
% Load the spike train data from the file
% Loop through each spike train
for i = 1:length(spike_trains)
    % Load the spike times for the current train
    spike_times = spike_trains{i};

    % Convert spike times to a binary spike train (1 ms bins)
    time_bins = 0:binSize:end_time; % Define time bins
    binary_spike_train = histcounts(spike_times, time_bins); % Binary vector
        % Check the length of the binary spike train
    signalLength = length(binary_spike_train);
        % Adjust window and overlap for PSD
    window = min(window, signalLength); % Ensure window is <= signal length
    noverlap = max(0, floor(window / 2)); % Set overlap to half the window or less
    nfft = min(nfft, signalLength); % Ensure nfft is <= signal length

    % Autocorrelation
    [autocorrPos, lags] = xcorr(binary_spike_train, maxLag, 'coeff');
    results(i).autocorrelation = autocorrPos; % Save autocorrelation data
    results(i).lags = lags * binSize; % Convert lags to ms and save

    figure;
    plot(lags * binSize, autocorrPos); % Convert lag to ms by multiplying by binSize
    title(['Autocorrelation - Spike Train ', num2str(i)]);
    xlabel('Lag (ms)');
    ylabel('Autocorrelation');
    % Save Autocorrelation figure
    saveas(gcf, fullfile(commonSaveDir, sprintf('Autocorrelation_Train_%d.png', i)));
    close(gcf); 

    % Power Spectral Density (PSD)
    [Pxx, F] = pwelch(binary_spike_train, window, noverlap, nfft, sampling_rate);
    results(i).PSD = Pxx; % Save PSD data
    results(i).frequencies = F; % Save frequency data
    figure;
    plot(F, 10*log10(Pxx)); % Plot in dB/Hz
    title(['Power Spectral Density - Spike Train ', num2str(i)]);
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    % Save PSD figure
    saveas(gcf, fullfile(commonSaveDir, sprintf('PSD_Train_%d.png', i)));

     if ~exist('results', 'var') || length(results) < i
        results(i).autocorrelation = [];
        results(i).lags = [];
        results(i).psd = [];
        results(i).frequency = [];
     end

       % Save the computed data to the results struct
    results(i).autocorrelation = autocorrPos;  % Save autocorrelation data
    results(i).lags = lags * binSize;          % Save corresponding lags in seconds
    results(i).psd = Pxx;                      % Save PSD data
    results(i).frequency = F;                  % Save frequency data
   
end
save(fullfile(commonSaveDir, 'spike_analysis_results.mat'), 'results');

disp('Analysis complete. All figures saved to the specified directory.');
%close all;

%%
% CVs and bursts 

% Directory containing the .mat files
%folder_path = 'I:\MBLAB1-Q3474\Montana\Healthy_Ageing_Ephys\Young_Montana\448795\Polytrode3-LM\again\againn no subtract\spiketrains';

% Load spike train data
data = load('spike_trains.mat');
spike_trains = data.spike_trains;

% Initialize arrays to store results
CVs = [];
results = [];

% Open a text file to save the CVs and bursts info
fileID = fopen(fullfile(commonSaveDir, 'CVs_and_bursts.txt'), 'w');
fprintf(fileID, 'Spike Train Index\tCV\tNumber of Bursts\n');

% Define the burst threshold (e.g., ISI < 0.02 seconds)
burst_threshold = 0.02;

%% Loop over each spike train
for i = 1:length(spike_trains)
    %Extract the spike times for the current train
    spike_times = spike_trains{i};

    % Exclude the first and last data points
    spike_times = spike_times(2:end-1);
    
    % Calculate the inter-spike intervals (ISIs)
    ISIs = diff(spike_times);
    
    % Calculate the coefficient of variation (CV) of ISIs
    CV_ISI = std(ISIs) / mean(ISIs);
    
    % Initialize the number of bursts to zero
    num_bursts = 0;
    
    % Only count bursts if CV_ISI >= 1.1
    if CV_ISI >= 1.1
        % Identify bursts based on ISI threshold
        burst_indices = find(ISIs < burst_threshold);
        
        if ~isempty(burst_indices)
            % Identify the start of each burst
            burst_starts = burst_indices([true; diff(burst_indices) > 1]);
            % Count the number of bursts
            num_bursts = length(burst_starts);
        end
    end
    
    % Append results to the array and write to the text file
    CVs = [CVs; CV_ISI];
    results = [results; CV_ISI, num_bursts];
    fprintf(fileID, '%d\t%.4f\t%d\n', i, CV_ISI, num_bursts);

    % Plotting the Raster, ISI Histogram, and Autocorrelation
    figure;
    
    % Subplot 1: Raster plot
    subplot(3,1,1);
    hold on;
    burst_colors = lines(max(1, num_bursts)); % Avoid issues if no bursts
    burst_color_idx = 1;
    in_burst = false;
    
     % Ensure burst_indices is defined and valid
    if exist('burst_indices', 'var') && ~isempty(burst_indices)
        % Loop through spike times
        for j = 1:length(spike_times)
            if ismember(j, burst_indices)
                % Do burst-specific processing
                if ~in_burst
                    in_burst = true;
                    burst_color = burst_colors(burst_color_idx, :);
                    burst_color_idx = burst_color_idx + 1;
                end
                line([spike_times(j) spike_times(j)], [0 1], 'Color', burst_color);
            else
                in_burst = false;
                line([spike_times(j) spike_times(j)], [0 1], 'Color', 'k');
            end
        end
    else
        error('burst_indices is not defined or is empty.');
    end
    
    hold off;
    xlabel('Time (s)');
    ylabel('Neuron');
    title(['Raster Plot (CV = ' num2str(CV_ISI) ')']);
    set(gca, 'YTick', []);
    xlim([min(spike_times) max(spike_times)]);

    %% Subplot 2: ISI Histogram
    subplot(3,1,2);
    histogram(ISIs, 'BinMethod', 'fd');
    xlabel('Inter-Spike Interval (s)');
    ylabel('Count');
    title('ISI Histogram');
    xlim([min(ISIs) max(ISIs)]);
    grid on;
    
    %% Subplot 3: Autocorrelation
    dt = 0.001; % Time bin size in seconds
    t_max = ceil(max(spike_times) / dt) * dt; % Maximum time for the spike train
    time_bins = 0:dt:t_max; % Create time bins
    spike_train = histcounts(spike_times, time_bins); % Binary spike train
    
    % Calculate the autocorrelation
    [acf, lags] = xcorr(spike_train, 'coeff');
    
    subplot(3,1,3);
    bar(lags * dt, acf);
    xlabel('Lag (s)');
    ylabel('Autocorrelation');
    title('Autocorrelation of Spike Train');
    xlim([-0.1 0.1]);
    ylim([min(acf) max(acf)]);
    grid on;
    
    % Save the figure
    saveas(gcf, fullfile(commonSaveDir, sprintf('firing_pattern_burst_analysis_%d.png', i)));
    close(gcf);
end

% Finalization

% Close the text file
fclose(fileID);

% Display the results
disp('Coefficient of Variation of ISIs and Number of Bursts for each spike train:');
disp(results);
    % Ensure burst_indices is defined and valid
% if exist('burst_indices', 'var') && ~isempty(burst_indices)
%     % Loop through spike times
%     for j = 1:length(spike_times)
%         if ismember(j, burst_indices)
%             % Do burst-specific processing
%             if ~in_burst
%                 in_burst = true;
%                 burst_color = burst_colors(burst_color_idx, :);
%                 burst_color_idx = burst_color_idx + 1;
%             end
%             line([spike_times(j) spike_times(j)], [0 1], 'Color', burst_color);
%         else
%             in_burst = false;
%             line([spike_times(j) spike_times(j)], [0 1], 'Color', 'k');
%         end
%     end
% else
%     error('burst_indices is not defined or is empty.');
% end
% 
% %     
% %     for j = 1:length(spike_times)
% %         if ismember(j, burst_indices)
% %             if ~in_burst
% %                 in_burst = true;
% %                % if burst_color_idx <= size(burst_colors, 1)
% %                 burst_color = burst_colors(burst_color_idx, :);
% %            % else
% %                 burst_color = [0 0 0]; % Fallback color if out of bounds
% %             end
% %                 burst_color = burst_colors(burst_color_idx, :);
% %                 burst_color_idx = burst_color_idx + 1;
% %             end
% %             line([spike_times(j) spike_times(j)], [0 1], 'Color', burst_color);
% %         else
% %             in_burst = false;
% %             line([spike_times(j) spike_times(j)], [0 1], 'Color', 'k');
% %         end
% %     end
%     
%     hold off;
%     xlabel('Time (s)');
%     ylabel('Neuron');
%     title(['Raster Plot (CV = ' num2str(CV_ISI) ')']);
%     set(gca, 'YTick', []);
%     xlim([min(spike_times) max(spike_times)]);
% 
%     % Subplot 2: ISI Histogram
%     subplot(3,1,2);
%     histogram(ISIs, 'BinMethod', 'fd');
%     xlabel('Inter-Spike Interval (s)');
%     ylabel('Count');
%     title('ISI Histogram');
%     xlim([min(ISIs) max(ISIs)]);
%     grid on;
%     
%     % Subplot 3: Autocorrelation
%     dt = 0.001; % Time bin size in seconds
%     t_max = ceil(max(spike_times) / dt) * dt; % Maximum time for the spike train
%     time_bins = 0:dt:t_max; % Create time bins
%     spike_train = histcounts(spike_times, time_bins); % Binary spike train
%     
%     % Calculate the autocorrelation
%     [acf, lags] = xcorr(spike_train, 'coeff');
%     
%     subplot(3,1,3);
%     bar(lags * dt, acf);
%     xlabel('Lag (s)');
%     ylabel('Autocorrelation');
%     title('Autocorrelation of Spike Train');
%     xlim([-0.1 0.1]);
%     ylim([min(acf) max(acf)]);
%     grid on;
%     
%     % Save the figure
%     saveas(gcf, fullfile(commonSaveDir, sprintf('firing_pattern_burst_analysis_%d.png', i)));
%     close(gcf);
% end
% 
% % Close the text file
% fclose(fileID);
% 
% % Display the results
% disp('Coefficient of Variation of ISIs and Number of Bursts for each spike train:');
% disp(results);
