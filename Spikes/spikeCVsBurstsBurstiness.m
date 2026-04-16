%% Burst analysis with Median ISI (works for 's' or 'ms' spike times)
clear; clc;

% ========================= USER CONFIG =========================
folder_path = pwd;
file_patterns = { ...
    '*spike_trains_times_channel_1.mat', ...
    '*spike_trains.mat' ...
    '*spike_trains_times_polytrode1.mat'...
};

units = 's';           % <<< 's' if spike_trains are in seconds, 'ms' if in milliseconds

% Thresholds / params (set both; the code picks the right set by 'units')
burst_thr_ms     = 10;      % ms   (when units='ms')
acf_bin_ms       = 1;       % ms   (for ACF binning; units='ms')
acf_short_ms     = 50;      % ms   integrate |lag|<=this (exclude lag=0)
burst_thr_s      = 0.010;   % s    (when units='s')  == 10 ms
acf_bin_s        = 0.001;   % s    (1 ms)
acf_short_s      = 0.050;   % s    (50 ms)

min_burst_size   = 3;       % >= this many spikes per burst
min_spikes_keep  = 5;       % skip trains with too few spikes
% ===============================================================

% Helpers for conversion (used only when units='ms')
to_ms = @(x) x * (strcmpi(units,'s')*1000 + strcmpi(units,'ms')*1);
to_s  = @(x) x / (strcmpi(units,'s')*1 + strcmpi(units,'ms')*1000);

% Gather files in current folder
mat_files = [];
for p = 1:numel(file_patterns)
    mat_files = [mat_files; dir(fullfile(folder_path, file_patterns{p}))]; %#ok<AGROW>
end

results = table();

for k = 1:numel(mat_files)
    file_name = mat_files(k).name;
    S = load(fullfile(folder_path, file_name));
    if ~isfield(S, 'spike_trains')
        warning('No variable "spike_trains" in %s (skipping)', file_name);
        continue;
    end
    spike_trains = S.spike_trains;   % cell array expected

    for train_idx = 1:numel(spike_trains)
        st = spike_trains{train_idx};
        if isempty(st), continue; end

        % Clean & sort
        st = st(:);
        st = st(isfinite(st));
        st = sort(st);
        if numel(st) < min_spikes_keep, continue; end

        % Drop first/last to reduce boundary artifacts (optional)
        if numel(st) >= 3
            st = st(2:end-1);
        end
        if numel(st) < min_spikes_keep, continue; end

        switch lower(units)
            case 'ms'
                % ============ MS BRANCH ============
                st_ms  = to_ms(st);                 % treat spike times as ms
                ISIs   = diff(st_ms);               % ms
                if numel(ISIs) < 2, continue; end

                CV_ISI         = std(ISIs, 0, 1) / mean(ISIs);
                median_ISI_ms  = median(ISIs);
                median_ISI_s   = median_ISI_ms / 1000;

                % Burst detection (runs of short ISIs)
                shortISI = ISIs < burst_thr_ms;
                [num_bursts, burst_members, burstiness_ratio] = ...
                    runs_and_members(shortISI, numel(st_ms), min_burst_size);

                % Autocorrelation burst index (ms)
                st_ms_round = max(round(st_ms), 1);
                T_ms = max(st_ms_round);
                if T_ms < 5, continue; end
                spike_vec = sparse(st_ms_round, 1, 1, T_ms, 1); % binary vector
                [acf, lags] = xcorr(full(spike_vec), 'coeff');
                W = (abs(lags) > 0) & (abs(lags) <= acf_short_ms);
                burst_index = any(acf) * sum(acf(W)) / max(sum(abs(acf)), eps);

                % Save row (includes median ISI)
                row = table( ...
                    string(file_name), uint32(train_idx), ...
                    double(CV_ISI), uint32(num_bursts), ...
                    double(burst_index), double(burstiness_ratio), ...
                    double(median_ISI_s), double(median_ISI_ms), ...
                    string(units), double(burst_thr_ms), uint32(min_burst_size), ...
                    double(acf_bin_ms), double(acf_short_ms), ...
                    'VariableNames', {'File','Train','CV_ISI','NumBursts','BurstIndex','ISI_Burstiness', ...
                                      'MedianISI_s','MedianISI_ms', ...
                                      'Units','BurstThr_ms','MinBurstSize','ACF_Bin_ms','ACF_ShortWin_ms'});
                results = [results; row]; %#ok<AGROW>

                % Raster (ms)
                make_raster_and_save(st_ms, burst_members, 'Time (ms)', ...
                    fullfile(folder_path, sprintf('%s_train%d_burst.fig', file_name(1:end-4), train_idx)), ...
                    file_name, train_idx, CV_ISI, num_bursts, burst_index);

            case 's'
                % ============ SECONDS BRANCH ============
                ISIs = diff(st);                     % seconds
                if numel(ISIs) < 2, continue; end

                CV_ISI         = std(ISIs) / mean(ISIs);
                median_ISI_s   = median(ISIs);
                median_ISI_ms  = median_ISI_s * 1000;

                % Burst detection (runs of short ISIs)
                shortISI = ISIs < burst_thr_s;
                if any(shortISI)
                    d = diff([false; shortISI(:); false]);
                    run_starts  = find(d == 1);
                    run_ends    = find(d == -1) - 1;
                    run_lengths = run_ends - run_starts + 1;
                    ok = run_lengths >= (min_burst_size - 1);
                    num_bursts = sum(ok);

                    burst_members = false(size(st)); % one flag per spike
                    for r = find(ok).'
                        i1 = run_starts(r);
                        i2 = run_ends(r);
                        burst_members(i1:(i2+1)) = true; % ISIs->spikes
                    end
                    burstiness_ratio = mean(shortISI);
                else
                    num_bursts = 0;
                    burstiness_ratio = 0;
                    burst_members = false(size(st));
                end

                % Autocorrelation burst index (seconds)
                dt = acf_bin_s;                                  % 1 ms bins
                bins  = max(1, round(st / dt) + 1);
                Tbins = max(bins) + 2;
                spike_vec = accumarray(bins, 1, [Tbins, 1]);     % counts per bin
                if nnz(spike_vec) >= 2
                    [acf, lags] = xcorr(spike_vec, 'coeff');
                    lags_s = lags * dt;
                    W = (abs(lags_s) > 0) & (abs(lags_s) <= acf_short_s);
                    burst_index = any(acf) * sum(acf(W)) / max(sum(abs(acf)), eps);
                else
                    burst_index = 0;
                end

                % Save row (includes median ISI)
                row = table( ...
                    string(file_name), uint32(train_idx), ...
                    double(CV_ISI), uint32(num_bursts), ...
                    double(burst_index), double(burstiness_ratio), ...
                    double(median_ISI_s), double(median_ISI_ms), ...
                    string(units), double(burst_thr_s), uint32(min_burst_size), ...
                    double(acf_bin_s), double(acf_short_s), ...
                    'VariableNames', {'File','Train','CV_ISI','NumBursts','BurstIndex','ISI_Burstiness', ...
                                      'MedianISI_s','MedianISI_ms', ...
                                      'Units','BurstThr_s','MinBurstSize','ACF_Bin_s','ACF_ShortWin_s'});
                results = [results; row]; %#ok<AGROW>

                % Raster (s)
                make_raster_and_save(st, burst_members, 'Time (s)', ...
                    fullfile(folder_path, sprintf('%s_train%d_burst.fig', file_name(1:end-4), train_idx)), ...
                    file_name, train_idx, CV_ISI, num_bursts, burst_index);

            otherwise
                error('units must be ''ms'' or ''s''.');
        end
    end
end

% ===== Write CSV/TXT at the folder root =====
out_csv = fullfile(folder_path, 'CVs_and_bursts.csv');
out_txt = fullfile(folder_path, 'CVs_and_bursts.txt');
if ~isempty(results)
    writetable(results, out_csv);
    writetable(results, out_txt, 'Delimiter', '\t', 'FileType', 'text');
    fprintf('Done. Saved results to:\n  %s\n  %s\n', out_csv, out_txt);
else
    warning('No results produced (check inputs/units/files).');
end

% ============================= HELPERS =============================
function [num_bursts, burst_members, burstiness_ratio] = runs_and_members(shortISI, nSpikes, min_burst_size)
% Given a logical vector of "short" ISIs, mark spikes that belong to bursts.
d = diff([false; shortISI(:); false]);
run_starts  = find(d == 1);
run_ends    = find(d == -1) - 1;
run_lengths = run_ends - run_starts + 1;    % in ISI count
ok = run_lengths >= (min_burst_size - 1);
num_bursts = sum(ok);

burst_members = false(nSpikes, 1);
for r = find(ok).'
    i1 = run_starts(r);
    i2 = run_ends(r);
    % ISIs i1..i2 correspond to spikes i1..(i2+1); flag those spikes
    burst_members(i1:(i2+1)) = true;
end
burstiness_ratio = mean(shortISI);
end

function make_raster_and_save(xvals, burst_members, xlab, out_path, file_name, train_idx, CV_ISI, num_bursts, burst_index)
figure('Color','w','Position',[200 200 900 180]); hold on;
y0 = 0; y1 = 1;
for i = 1:numel(xvals)
    if burst_members(i)
        plot([xvals(i) xvals(i)], [y0 y1], '-', 'LineWidth', 1.2);
    else
        plot([xvals(i) xvals(i)], [y0 y1], '-', 'LineWidth', 0.8);
    end
end
set(gca,'YTick',[]); ylim([0 1]); box on;
xlabel(xlab);
title(sprintf('%s | Train %d | CV=%.2f | Bursts=%d | BI=%.3f', ...
      file_name, train_idx, CV_ISI, num_bursts, burst_index), 'Interpreter','none');
xlim([min(xvals) max(xvals)]);
savefig(out_path);
close(gcf);
end
