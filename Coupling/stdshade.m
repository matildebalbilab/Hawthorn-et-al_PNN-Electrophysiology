function stdshade(amatrix, alpha, acolor, F, smth)
% usage: stdshade(amatrix, alpha, acolor, F, smth)
% - amatrix: rows = subjects, columns = timepoints
% - alpha: transparency of shaded area
% - acolor: RGB triplet or character (e.g., 'k') for mean line color
% - F: x-axis vector
% - smth: smoothing factor (default = 1)

if nargin < 3 || isempty(acolor)
    acolor = [0 0 0];  % default black
end
if nargin < 4 || isempty(F)
    F = 1:size(amatrix, 2);
end
if nargin < 5 || isempty(smth)
    smth = 1;
end

if size(F, 1) ~= 1
    F = F';
end

% Compute mean and SEM
amean = smooth(nanmean(amatrix, 1), smth)';
astd  = nanstd(amatrix, 0, 1) / sqrt(size(amatrix, 1));

% Plot shaded area
hold on;
fill([F fliplr(F)], ...
     [amean + astd fliplr(amean - astd)], ...
     acolor, 'FaceAlpha', alpha, 'EdgeColor', 'none');

% Plot mean line (darker version of shade if RGB)
if isnumeric(acolor)
    linecolor = max(acolor - 0.3, 0);  % darken for contrast
else
    linecolor = 'k';
end
plot(F, amean, 'Color', linecolor, 'LineWidth', 1.5);

end
