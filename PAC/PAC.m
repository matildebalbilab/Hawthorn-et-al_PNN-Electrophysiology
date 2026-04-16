%% --- Setup ---
clear; close all;
fs = 1000;                     % Sampling rate (Hz)
nbins = 18;                    % Number of theta phase bins
mouse_id = 5;                  % <<< CHANGE this per mouse >>>

%% --- Load persistent stores (if available) ---
if isfile('MI_values.mat')
    load('MI_values.mat', 'z_MI', 'raw_MI');
else
    z_MI  = NaN(1, 10);
    raw_MI = NaN(1, 10);
end

if isfile('all_aligned.mat')
    load('all_aligned.mat', 'all_aligned');
else
    all_aligned = NaN(10, nbins);
end

if isfile('PAC_phase_summary.mat')
    load('PAC_phase_summary.mat','vector_strengths','preferred_phases');
else
    vector_strengths = NaN(1, 10);
    preferred_phases = NaN(1, 10);
end

if isfile('preferred_phases.mat')
    load('preferred_phases.mat', 'preferred_phase_all');
else
    preferred_phase_all = NaN(1, 10);
end

%% --- Load and preprocess LFP ---
% load('617764_D28_gcamp2RH.mat');            % <<< Alternative file
load('MND61_D28_gcamp1.ns6_RH_last60s_avg_ch1-2-3-4');   % <<< Your file
lfp = mean_sig0;                               % Must exist in the mat file

t = (0:length(lfp)-1)/fs;
t_start = 0; t_end = 50;                       % Use first 50 s
idx = t >= t_start & t <= t_end;
lfp_seg = lfp(idx);

% --- Optional mains notch (50 Hz) before bandpass ---
% use_hz = 50; bw = 1.0;
% notchFilt = designfilt('bandstopiir','FilterOrder',2, ...
%     'HalfPowerFrequency1', use_hz - bw/2, ...
%     'HalfPowerFrequency2', use_hz + bw/2, ...
%     'DesignMethod','butter','SampleRate', fs);
% lfp_clean = filtfilt(notchFilt, lfp_seg);
% sig_for_filters = lfp_clean;

sig_for_filters = lfp_seg;  % if not using notch

%% --- Filter for Theta and Gamma Bands ---
theta_band = [1 4];                 % <<< Set to [1 4] if you want delta
gamma_band = [30 100];

thetaFilt = designfilt('bandpassiir', 'FilterOrder', 4, ...
    'HalfPowerFrequency1', theta_band(1), ...
    'HalfPowerFrequency2', theta_band(2), ...
    'SampleRate', fs);

gammaFilt = designfilt('bandpassiir', 'FilterOrder', 4, ...
    'HalfPowerFrequency1', gamma_band(1), ...
    'HalfPowerFrequency2', gamma_band(2), ...
    'SampleRate', fs);

theta_sig = filtfilt(thetaFilt, sig_for_filters);
gamma_sig = filtfilt(gammaFilt, sig_for_filters);
gamma_amp = abs(hilbert(gamma_sig));
theta_phase = angle(hilbert(theta_sig));   % -pi..pi

%% --- Bin and average gamma amplitude by theta phase ---
edges = linspace(-pi, pi, nbins+1);
theta_centers = edges(1:end-1) + diff(edges)/2;

[~, ~, bin_idx] = histcounts(theta_phase, edges);
amp_dist = zeros(1, nbins);
for b = 1:nbins
    vals = gamma_amp(bin_idx == b);
    amp_dist(b) = mean(vals, 'omitnan');
end
amp_dist = amp_dist / max(eps, sum(amp_dist));   % Normalize safely

%% --- Canolty MI and Z-scored MI ---
zvec = gamma_amp .* exp(1i * theta_phase);
MI_canolty = abs(mean(zvec));
n_shuffles = 200;
mi_shuffled = zeros(1, n_shuffles);
for s = 1:n_shuffles
    shift = randi(length(gamma_amp) - 1);
    gamma_amp_shuf = circshift(gamma_amp, shift);
    z_shuf = gamma_amp_shuf .* exp(1i * theta_phase);
    mi_shuffled(s) = abs(mean(z_shuf));
end
mu_shuf = mean(mi_shuffled);
sigma_shuf = std(mi_shuffled);
z_canolty = (MI_canolty - mu_shuf) / sigma_shuf;

fprintf('Canolty MI: %.4f\n', MI_canolty);
fprintf('Z-scored Canolty MI: %.4f (real MI = %.4f, shuffled μ = %.4f, σ = %.4f)\n', ...
    z_canolty, MI_canolty, mu_shuf, sigma_shuf);

% Save MI values
z_MI(mouse_id) = z_canolty;
raw_MI(mouse_id) = MI_canolty;
save('MI_values.mat', 'z_MI', 'raw_MI');

%% --- Raw (unaligned) plots ---
figure; bar(rad2deg(theta_centers), amp_dist, 'FaceColor', [0.5 0.5 0.5]);
xlim([-180 180]); xticks([-180 -90 0 90 180]);
xlabel('Theta Phase (°)'); ylabel('Norm. Gamma Amp'); title('Raw PAC Bar Plot');
saveas(gcf, sprintf('bar_raw_mouse%d.png', mouse_id));

figure; polarplot([theta_centers theta_centers(1)], [amp_dist amp_dist(1)], 'LineWidth', 2);
rlim([0 0.07]); title('Raw PAC Polar Plot');
saveas(gcf, sprintf('polar_raw_mouse%d.png', mouse_id));

figure; polarhistogram('BinEdges', edges, 'BinCounts', amp_dist, ...
    'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none');
rlim([0 0.07]); title('Raw PAC Rose Plot');
saveas(gcf, sprintf('rose_raw_mouse%d.png', mouse_id));

%% --- Align and save aligned figures ---
[~, max_idx] = max(amp_dist);
preferred_phase_rad = theta_centers(max_idx);
preferred_phase_all(mouse_id) = preferred_phase_rad;
save('preferred_phases.mat', 'preferred_phase_all');

shift_amt = ceil(nbins/2) - max_idx;
amp_aligned = circshift(amp_dist, shift_amt);

all_aligned(mouse_id, :) = amp_aligned;
save('all_aligned.mat', 'all_aligned');

figure; bar(rad2deg(theta_centers), amp_aligned, 'FaceColor', [0.3 0.6 0.6]);
xlim([-180 180]); xticks([-180 -90 0 90 180]);
xlabel('Theta Phase (°)'); ylabel('Norm. Gamma Amp'); title('Aligned PAC Bar Plot');
saveas(gcf, sprintf('bar_aligned_mouse%d.png', mouse_id));

figure; polarplot([theta_centers theta_centers(1)],[amp_aligned amp_aligned(1)],'LineWidth',2);
rlim([0 0.07]); title('Aligned PAC Polar Plot');
saveas(gcf, sprintf('polar_aligned_mouse%d.png', mouse_id));

figure; polarhistogram('BinEdges', edges, 'BinCounts', amp_aligned, ...
    'FaceColor', [0.2 0.5 0.7], 'EdgeColor', 'none');
rlim([0 0.07]); title('Aligned PAC Rose Plot');
saveas(gcf, sprintf('rose_aligned_mouse%d.png', mouse_id));

close all;

%% --- Vector Strength (R) and Preferred Phase (phi_pref) from bins ---
% Use the same representation (binned) for both R and phi
Z = sum(amp_dist .* exp(1i * theta_centers));
R = abs(Z);                   % 0..1
phi_pref = angle(Z);          % radians

% Persist across animals
vector_strengths(mouse_id) = R;
preferred_phases(mouse_id) = phi_pref;
save('PAC_phase_summary.mat', 'vector_strengths', 'preferred_phases');

fprintf('Mouse %d: Vector Strength R = %.3f, Preferred Phase = %.2f rad (%.1f°)\n', ...
    mouse_id, R, phi_pref, rad2deg(phi_pref));

%% --- KL divergence vs uniform (stable) ---
uniform_dist = ones(1, nbins) / nbins;
p = max(amp_dist, eps);
KL_div = sum(p .* log(p ./ uniform_dist));

%% --- Group stats (NaN-safe) ---
valid = ~isnan(preferred_phases);
if any(valid)
    R_group = abs(mean(exp(1i * preferred_phases(valid))));
    mu_group = angle(mean(exp(1i * preferred_phases(valid))));
else
    R_group = NaN;
    mu_group = NaN;
end

fprintf('Group R = %.3f, Preferred Phase = %.2f rad (%.1f°)\n', ...
    R_group, mu_group, rad2deg(mu_group));
