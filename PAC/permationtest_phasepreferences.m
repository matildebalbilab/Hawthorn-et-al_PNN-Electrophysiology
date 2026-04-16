%import preferred_phases variable in the PAC_phase_summary.mat file. Rename as phases_group 1 or phases_group 2 
%saline = group1, chabc = group 2

% Pool all preferred phases
% all_phases = [phases_group1, phases_group2];
% labels = [ones(1,length(phases_group1)), 2*ones(1,length(phases_group2))];
% 
% % Observed R difference
% R1 = abs(mean(exp(1i * phases_group1)));
% R2 = abs(mean(exp(1i * phases_group2)));
% R_obs_diff = abs(R1 - R2);
% 
% % Permutation
% n_perm = 10000;
% R_diff_null = zeros(1,n_perm);
% for i = 1:n_perm
%     perm_idx = labels(randperm(length(labels)));
%     R1_perm = abs(mean(exp(1i * all_phases(perm_idx == 1))));
%     R2_perm = abs(mean(exp(1i * all_phases(perm_idx == 2))));
%     R_diff_null(i) = abs(R1_perm - R2_perm);
% end
% 
% p_val = mean(R_diff_null >= R_obs_diff);
% fprintf('Permutation test p = %.4f\n', p_val);

% Compute observed vector strengths
R1_obs = abs(mean(exp(1i * phases_group1)));
R2_obs = abs(mean(exp(1i * phases_group2)));
deltaR_obs = R1_obs - R2_obs;

% Permutation test setup
n_perms = 10000;
all_phases = [phases_group1(:); phases_group2(:)];
n1 = numel(phases_group1);
deltaR_perm = zeros(1, n_perms);

% Permutation loop
for p = 1:n_perms
    shuffled = all_phases(randperm(numel(all_phases)));
    g1 = shuffled(1:n1);
    g2 = shuffled(n1+1:end);
    deltaR_perm(p) = abs(mean(exp(1i * g1))) - abs(mean(exp(1i * g2)));
end

% Compute p-value
p_value = mean(abs(deltaR_perm) >= abs(deltaR_obs));

% Plot histogram
figure;
histogram(deltaR_perm, 40, 'FaceColor', [0.6 0.8 1], 'EdgeColor', 'k');
hold on;
yl = ylim;
plot([deltaR_obs deltaR_obs], yl, 'r--', 'LineWidth', 2);
xlabel('\DeltaR (R_{group1} - R_{group2})');
ylabel('Count');
title(sprintf('Permutation Test\nObserved ΔR = %.4f, p = %.4f', deltaR_obs, p_value));
legend('Permuted ΔR', 'Observed ΔR', 'Location', 'best');
