% --- Load preferred phases ---
if isfile('preferred_phases.mat')
    load('preferred_phases.mat', 'preferred_phase_all');
end

% Remove NaNs
valid_phases = preferred_phase_all(~isnan(preferred_phase_all));
n_animals = numel(valid_phases);

% Compute group vector
R_group = abs(mean(exp(1i * valid_phases)));
mu_group = angle(mean(exp(1i * valid_phases)));

% --- Create Polar Plot ---
figure;
polarhistogram(valid_phases, 12, 'Normalization', 'probability', ...
    'FaceColor', [0.6 0.8 1], 'EdgeColor', 'k');
hold on;

% Red line for mean vector
polarplot([0 mu_group], [0 R_group], 'r-', 'LineWidth', 2);

% Annotate R value (using annotation at fixed angle and radius)
[x_r, y_r] = pol2cart(mu_group, R_group);
text(x_r * 1.1, y_r * 1.1, sprintf('R = %.2f', R_group), ...
    'HorizontalAlignment', 'center', 'Color', 'r', 'FontSize', 12);

% --- Add jittered dots using polarplot ---
jitter_strength = 0.05;
r_jittered = 0.95 + rand(1, n_animals) * jitter_strength;
theta_jittered = valid_phases;

for i = 1:n_animals
    % Plot black dot
    polarplot(theta_jittered(i), r_jittered(i), 'ko', 'MarkerFaceColor', 'k');
    
    % Add animal index as label
    [x_text, y_text] = pol2cart(theta_jittered(i), r_jittered(i) + 0.05);
    text(x_text, y_text, sprintf('%d', i), ...
        'FontSize', 9, 'Color', 'k', 'HorizontalAlignment', 'center');
end

% Final formatting
title('Preferred Theta Phases Across Animals (radians)');
ax = gca;
ax.ThetaTick = [0 90 180 270];
ax.ThetaTickLabel = {'0', '\pi/2', '\pi', '3\pi/2'};


%%
% --- Load preferred phases ---
if isfile('preferred_phases.mat')
    load('preferred_phases.mat', 'preferred_phase_all');
else
    error('preferred_phases.mat not found.');
end

% Remove NaNs
valid_phases = preferred_phase_all(~isnan(preferred_phase_all));
n_animals = numel(valid_phases);

% Compute group vector
R_group = abs(mean(exp(1i * valid_phases)));
mu_group = angle(mean(exp(1i * valid_phases)));

% --- Create Polar Histogram ---
figure;
polarhistogram(valid_phases, 12, 'Normalization', 'probability', ...
    'FaceColor', [0.6 0.8 1], 'EdgeColor', 'k', 'LineWidth', 1.2);
hold on;

% --- Mean vector (red line) ---
polarplot([0 mu_group], [0 R_group], 'r-', 'LineWidth', 2);

% Annotate R value
[x_r, y_r] = pol2cart(mu_group, R_group);
text(x_r * 1.15, y_r * 1.15, sprintf('R = %.2f', R_group), ...
    'HorizontalAlignment', 'center', 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');

% --- Add jittered animal dots and labels ---
jitter_strength = 0.05;
r_jittered = 0.95 + rand(1, n_animals) * jitter_strength;

for i = 1:n_animals
    polarplot(valid_phases(i), r_jittered(i), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
    [x_txt, y_txt] = pol2cart(valid_phases(i), r_jittered(i) + 0.06);
    text(x_txt, y_txt, sprintf('%d', i), ...
        'FontSize', 9, 'Color', 'k', 'HorizontalAlignment', 'center');
end


% Final formatting
title('Preferred Theta Phases Across Animals (radians)');
ax = gca;
ax.ThetaTick = [0 90 180 270];
ax.ThetaTickLabel = {'0', '\pi/2', '\pi', '3\pi/2'};

% Limit radial ticks to prevent labels like 2, 3 from showing
ax.RLim = [0 1];  % or a bit higher if needed for spacing
ax.RTick = [0 0.2 0.4 0.6 0.8 1];  % only show ticks up to 1

%%
% --- Load preferred phases ---
if isfile('preferred_phases.mat')
    load('preferred_phases.mat', 'preferred_phase_all');
else
    error('preferred_phases.mat not found.');
end

% Remove NaNs
valid_phases = preferred_phase_all(~isnan(preferred_phase_all));
n_animals = numel(valid_phases);

if n_animals == 0
    error('No valid phases found in preferred_phase_all.');
end

% Compute group vector
R_group = abs(mean(exp(1i * valid_phases)));
mu_group = angle(mean(exp(1i * valid_phases)));

% --- Create Polar Histogram ---
figure;
polarhistogram(valid_phases, 12, 'Normalization', 'probability', ...
    'FaceColor', [0.6 0.8 1], 'EdgeColor', 'k', 'LineWidth', 1.2);
hold on;

% --- Mean vector (red line) ---
polarplot([0 mu_group], [0 R_group], 'r-', 'LineWidth', 2);

% Annotate R value
[x_r, y_r] = pol2cart(mu_group, R_group);
text(x_r * 1.15, y_r * 1.15, sprintf('R = %.2f', R_group), ...
    'HorizontalAlignment', 'center', 'Color', 'r', ...
    'FontSize', 12, 'FontWeight', 'bold');

% --- Add jittered animal dots ---
jitter_strength = 0.03;
r_jittered = 1 + rand(1, n_animals) * jitter_strength;  % Slight jitter outside histogram

for i = 1:n_animals
    polarplot(valid_phases(i), r_jittered(i), 'ko', ...
        'MarkerFaceColor', 'k', 'MarkerSize', 6);
end

% Final formatting
title('Preferred Theta Phases Across Animals (radians)');
ax = gca;
ax.ThetaTick = [0 90 180 270];
ax.ThetaTickLabel = {'0', '\pi/2', '\pi', '3\pi/2'};
ax.RLim = [0 1.2];  % Extend slightly to fit jittered dots
ax.RTick = [0 0.2 0.4 0.6 0.8 1];  % Clean radial ticks

%%
% --- Load preferred phases ---
if isfile('preferred_phases.mat')
    load('preferred_phases.mat', 'preferred_phase_all');
    disp('Loaded preferred_phase_all:');
    disp(preferred_phase_all); % Check contents
else
    error('preferred_phases.mat not found.');
end

% Remove NaNs
valid_phases = preferred_phase_all(~isnan(preferred_phase_all));
n_animals = numel(valid_phases);

if n_animals == 0
    error('No valid phases found in preferred_phase_all.');
else
    fprintf('Found %d valid preferred phases.\n', n_animals);
end

% Compute group vector
R_group = abs(mean(exp(1i * valid_phases)));
mu_group = angle(mean(exp(1i * valid_phases)));
fprintf('Group R = %.3f, Mean Phase = %.2f rad (%.1f°)\n', ...
    R_group, mu_group, rad2deg(mu_group));

% --- Create Polar Histogram ---
fig = figure('Color', 'w'); % Force figure to open visibly
polarhistogram(valid_phases, 12, 'Normalization', 'probability', ...
    'FaceColor', [0.6 0.8 1], 'EdgeColor', 'k', 'LineWidth', 1.2);
hold on;

% --- Mean vector (red line) ---
polarplot([0 mu_group], [0 R_group], 'r-', 'LineWidth', 2);

% Annotate R value
[x_r, y_r] = pol2cart(mu_group, R_group);
text(x_r * 1.15, y_r * 1.15, sprintf('R = %.2f', R_group), ...
    'HorizontalAlignment', 'center', 'Color', 'r', ...
    'FontSize', 12, 'FontWeight', 'bold');

% --- Add jittered animal dots ---
jitter_strength = 0.03;
r_jittered = 1 + rand(1, n_animals) * jitter_strength;  % Slight jitter outside histogram

for i = 1:n_animals
    polarplot(valid_phases(i), r_jittered(i), 'ko', ...
        'MarkerFaceColor', 'k', 'MarkerSize', 6);
end

% --- Style plot ---
title('Preferred Theta Phases Across Animals (radians)');
ax = gca;
ax.ThetaTick = [0 90 180 270];
ax.ThetaTickLabel = {'0', '\pi/2', '\pi', '3\pi/2'};
ax.RLim = [0 1.2]; % Slightly larger radial axis
ax.RTick = [0 0.2 0.4 0.6 0.8 1];

drawnow; % Force immediate rendering
