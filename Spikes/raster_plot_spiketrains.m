% spike_trains{1,1} contains spike times in milliseconds — convert to seconds
spike_times = spike_trains{1,1};

wrap_time = 30;        % time per row (in seconds)
total_time = 300;      % total duration (5 minutes)
line_height = 1;       % spacing between rows

figure; hold on;

for i = 1:length(spike_times)
    t = spike_times(i);
    if t > total_time
        continue
    end

    x = mod(t, wrap_time);         % wrapped time on x-axis (0–30s)
    y = floor(t / wrap_time);      % which row this spike belongs to
    plot([x x], [y y] + [-0.4 0.4], 'k');  % draw vertical tick
end

xlabel('Time in seconds (0–30 per row)');
ylabel('30s blocks');
title('Single Neuron Raster Plot (Wrapped Every 30s)');
xlim([0 wrap_time]);
ylim([-0.5 ceil(total_time / wrap_time)]);

%%

% Get spike times in ms and convert to seconds
spike_times = spike_trains{1,1};  % assuming spike times are in ms

% Keep only the first half (first 2.5 minutes = 150 seconds)
total_time = 150;
spike_times = spike_times(spike_times <= total_time);

wrap_time = 30;  % wrap every 30 seconds

% Compute wrapped X and Y positions
x = mod(spike_times, wrap_time);             % time within 30s line
y = floor(spike_times / wrap_time);          % which 30s block (row)

% Plot
figure; hold on;
plot(x, y + 1, 'r.', 'MarkerSize', 10);      % Add 1 to y for 1-based indexing

xlabel('Time (s) [0–30 per row]');
ylabel('30s blocks');
title('Spike Train Raster Plot (Wrapped Every 30s)');
xlim([0 wrap_time]);
ylim([0.5 ceil(total_time / wrap_time) + 0.5]);  % add buffer around rows
yticks(1:ceil(total_time / wrap_time));
yticklabels(arrayfun(@(i) sprintf('%d–%d s', (i-1)*wrap_time, i*wrap_time), 1:ceil(total_time / wrap_time), 'UniformOutput', false));

set(gca, 'YDir', 'reverse');  % Optional: flip Y so earlier blocks are on top


%%

% Convert spike times from ms to seconds
spike_times = spike_trains{1,1};

% Keep only the first 150 seconds
total_time = 150;
spike_times = spike_times(spike_times <= total_time);

wrap_time = 30;           % seconds per row
row_spacing = 0.15;       % spacing between rows (adjust this to make rows tighter)

% Calculate X and Y positions
x = mod(spike_times, wrap_time);         % time within 0–30s window
y_block = floor(spike_times / wrap_time); 
y = y_block * row_spacing;               % compressed row height

% Plot
figure; hold on;
plot(x, y, '.', 'MarkerSize', 6, 'Color', [0.9255 0 0.5490]);  % CMYK magenta in RGB
%plot(x, y, '.', 'MarkerSize', 6, 'Color', [0.5 0.5 0.50]);  % CMYK magenta in RGB

xlabel('Time (s) [0–30 per row]');
ylabel('Blocks (compressed)');
title('Spike Train Raster (30s/row, Compressed)');
xlim([0 wrap_time]);
ylim([-0.1, max(y) + row_spacing]);

set(gca, 'YTick', []);  % Optional: remove y-ticks for cleaner look
