clear all;
%% all in a folder
% Directory containing the .mat files
folder_path = 'Z:\MBLAB1-Q3474\Phoebe\balbc\For_dongsheng_Spikeanalysis\sorted\D7\951_D7_gcamp2_ref1_diff2_3_4_notgood\spike_trains';

% Get a list of all .mat files in the folder
mat_files = dir(fullfile(folder_path, '*.mat'));

% Initialize an array to store CVs
CVs = [];

% Open a text file to save the CVs
fileID = fopen(fullfile(folder_path, 'CVs.txt'), 'w');
fprintf(fileID, 'File\tCV\n');

% Process each .mat file
for k = 1:length(mat_files)
    % Load the .mat file
    file_name = mat_files(k).name;
    data = load(fullfile(folder_path, file_name));
    
    % Check if the data is stored in 'neg_spikes' or 'pos_spikes'
    if isfield(data, 'neg_spikes')
        spike_times = data.neg_spikes;
    elseif isfield(data, 'pos_spikes')
        spike_times = data.pos_spikes;
    else
        error('No recognizable spike time variable found in %s', file_name);
    end
    
    % Exclude the first and last data points
    spike_times = spike_times(2:end-1);
    
    % Calculate the inter-spike intervals (ISIs)
    ISIs = diff(spike_times);
    
    % Calculate the coefficient of variation (CV) of ISIs
    CV_ISI = std(ISIs) / mean(ISIs);
    
    % Append CV to the array and write to the text file
    CVs = [CVs; CV_ISI];
    fprintf(fileID, '%s\t%.4f\n', file_name, CV_ISI);
    
    % Plotting the raster plot
    figure;
    subplot(3,1,1);
    hold on;
    for i = 1:length(spike_times)
        line([spike_times(i) spike_times(i)], [0 1], 'Color', 'k');
    end
    hold off;
    xlabel('Time (s)');
    ylabel('Neuron');
    title('Raster Plot of Spike Train Data');
    set(gca, 'YTick', []);
    set(gca, 'YTickLabel', []);
    xlim([min(spike_times) max(spike_times)]);
    
    % Plotting the ISI histogram
    subplot(3,1,2);
    histogram(ISIs, 'BinMethod', 'fd');
    xlabel('Inter-Spike Interval (s)');
    ylabel('Count');
    title(['ISI Histogram (CV = ' num2str(CV_ISI) ')']);
    xlim([min(ISIs) max(ISIs)]);
    ylim([0 max(histcounts(ISIs, 'BinMethod', 'fd'))]);
    grid on;
    
    % Convert spike times to a binary spike train
    dt = 0.001; % Time bin size in seconds
    t_max = ceil(max(spike_times) / dt) * dt; % Maximum time for the spike train
    time_bins = 0:dt:t_max; % Create time bins
    spike_train = histcounts(spike_times, time_bins); % Binary spike train
    
    % Calculate the autocorrelation
    [acf, lags] = xcorr(spike_train, 'coeff');
    
    % Plotting the autocorrelation histogram
    subplot(3,1,3);
    bar(lags * dt, acf);
    xlabel('Lag (s)');
    ylabel('Autocorrelation');
    title('Autocorrelation of Spike Train');
    xlim([-0.1 0.1]); % Adjust the lag range as needed
    ylim([min(acf) max(acf)]);
    grid on;
    
    % Save the figure
    saveas(gcf, fullfile(folder_path, [file_name(1:end-4) '_firing_pattern.png']));
    close(gcf);
end

% Close the text file
fclose(fileID);

% Display the CVs
disp('Coefficient of Variation of ISIs for each file:');
disp(CVs);




%% label bursts

% Get a list of all .mat files in the folder
mat_files = dir(fullfile(folder_path, '*.mat'));

% Initialize an array to store CVs and number of bursts
results = [];

% Open a text file to save the CVs and number of bursts
fileID = fopen(fullfile(folder_path, 'CVs_and_bursts.txt'), 'w');
fprintf(fileID, 'File\tCV\tNumber of Bursts\n');

% Define the burst threshold (e.g., ISI < 0.02 seconds)
burst_threshold = 0.02;

% Process each .mat file
for k = 1:length(mat_files)
    % Load the .mat file
    file_name = mat_files(k).name;
    data = load(fullfile(folder_path, file_name));
    
    % Check if the data is stored in 'neg_spikes' or 'pos_spikes'
    if isfield(data, 'neg_spikes')
        spike_times = data.neg_spikes;
    elseif isfield(data, 'pos_spikes')
  
        spike_times = data.pos_spikes;
    else
        error('No recognizable spike time variable found in %s', file_name);
    end
    
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
    results = [results; CV_ISI, num_bursts];
    fprintf(fileID, '%s\t%.4f\t%d\n', file_name, CV_ISI, num_bursts);
    
    % Plotting the raster plot with bursts labeled
    figure;
    hold on;
    if num_bursts > 0
        burst_colors = lines(num_bursts); % Generate different colors for bursts
        burst_color_idx = 1;
        in_burst = false;
        
        for i = 1:length(spike_times)
            if ismember(i, burst_indices)
                if ~in_burst
                    in_burst = true;
                    burst_color = burst_colors(burst_color_idx, :);
                    burst_color_idx = burst_color_idx + 1;
                end
                line([spike_times(i) spike_times(i)], [0 1], 'Color', 'r');
            else
                in_burst = false;
                line([spike_times(i) spike_times(i)], [0 1], 'Color', 'k');
            end
        end
    else
        for i = 1:length(spike_times)
            line([spike_times(i) spike_times(i)], [0 1], 'Color', 'k');
        end
    end
    hold off;
    xlabel('Time (s)');
    ylabel('Neuron');
    title(['Raster Plot with Bursts Labeled (CV = ' num2str(CV_ISI) ')']);
    set(gca, 'YTick', []);
    set(gca, 'YTickLabel', []);
    xlim([min(spike_times) max(spike_times)]);
    
    % Save the figure
    saveas(gcf, fullfile(folder_path, [file_name(1:end-4) '_burst_analysis.png']));
    close(gcf);
end

% Close the text file
fclose(fileID);

% Display the results
disp('Coefficient of Variation of ISIs and Number of Bursts for each file:');
disp(results);
