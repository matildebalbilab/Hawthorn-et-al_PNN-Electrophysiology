function CGG_jitter_part3(filename)
close all

load([filename '.mat']);  
ct = 0;

% === Convert spike times from ms to seconds ===
% for k = 1:length(unit_t)
%     unit_t{k} = unit_t{k} / 1000;
% end

z_inh_all = NaN(size(unit_t,2)^2, 1);

figure; set(gcf,'position',[0 100 1000 800]);

for i = 1:size(unit_t,2)
    for j = 1:size(unit_t,2)
        for c = 1:10
            new_unit_t = unit_t{i} + 0.01 * randn(size(unit_t{i}));
            [tsOffsets, ~, ~] = crosscorrelogram(new_unit_t, unit_t{j}, [-0.025 0.025]);
            [m(c,:), ~] = hist(tsOffsets, 101);
        end

        subplot(size(unit_t,2), size(unit_t,2), size(unit_t,2)*(i-1)+j)
        [tsOffsets1, ~, ~] = crosscorrelogram(unit_t{i}, unit_t{j}, [-0.025 0.025]);
        [counts1, centers1] = hist(tsOffsets1, 101);
        bar(centers1, counts1); hold on

        for n = 1:101
            CI(n,:) = poissinv([0.01, 0.5, 0.99], mean(m(:,n)));
        end

        xlim([-0.02 0.02]);
        set(gca, 'XTick', [-0.02, 0, 0.02]);
        set(gca, 'XTickLabel', {'-0.02', '0', '0.02'});
        ylim([0 100]);

%         if i ~= j
%             ct = ct + 1;
% 
%             plot(linspace(-0.025, 0.025, 101), CI(:,1), 'g--', 'Linewidth', 0.5);
%             plot(linspace(-0.025, 0.025, 101), CI(:,3), 'g--', 'Linewidth', 0.5);
% 
%             window_exc = counts1(50:57)';
%             CI_window_up = CI(50:57,3);
%             peak = sum(window_exc > CI_window_up);
% 
%             if sum(counts1 <= 1) >= 101
%                 z = 0;
%             else
%                 z = (max(window_exc) - mean(m(:))) / std(m(:));
%             end
% 
%             text(-0.003, max(ylim)*1.1, sprintf('%.1f', z), 'color', 'm', 'FontSize', 8);
%             if z >= 2
%                 text(min(xlim), max(ylim)*0.85, '*excitatory', 'color', 'r', 'FontSize', 8);
%             end
%             connection(ct,1) = z;
% 
%             % Inhibitory check: expanded window (50–65), z ≤ -1.96
%             z_inh = NaN;
%             window_inh = counts1(50:65)';
%             CI_window_down = CI(50:65,1);
%             trough = sum(window_inh < CI_window_down);
%             if trough > 1
%                 p = find(window_inh < CI_window_down);
%                 if length(p) >= 2 && any(diff(p) == 1)
%                     z_inh = (min(window_inh) - mean(m(:))) / std(m(:));
%                     text(min(xlim)+0.032, max(ylim)*0.8, '*inhibitory', 'color', 'b', 'FontSize', 7);
%                     text(min(xlim)+0.032, max(ylim)*0.92, sprintf('%.1f', z_inh), 'color', 'b', 'FontSize', 7);
%                 end
%             end
%             z_inh_all(ct,1) = z_inh;
%         end
%     end
% end
if i ~= j
    ct = ct + 1;

    plot(linspace(-0.025, 0.025, 101), CI(:,1), 'g--', 'Linewidth', 0.5);
    plot(linspace(-0.025, 0.025, 101), CI(:,3), 'g--', 'Linewidth', 0.5);

    % ==== Excitatory detection ====
    window_exc = counts1(50:57)';
    CI_window_up = CI(50:57,3);
    peak = sum(window_exc > CI_window_up);

    if sum(counts1 <= 1) >= 101
        z = 0;
    else
        z = (max(window_exc) - mean(m(:))) / std(m(:));
    end

    text(-0.003, max(ylim)*1.1, sprintf('%.1f', z), 'color', 'm', 'FontSize', 8);

    if z >= 2 && any(window_exc > CI_window_up)
        text(min(xlim), max(ylim)*0.85, '*excitatory', 'color', 'r', 'FontSize', 8);
    end

    connection(ct,1) = z;

    % ==== Inhibitory detection ====
    z_inh = NaN;
    window_inh = counts1(50:65)';
    CI_window_down = CI(50:65,1);
    trough = sum(window_inh < CI_window_down);

    if trough > 1
        p = find(window_inh < CI_window_down);
        if length(p) >= 2 && any(diff(p) == 1)
            z_inh = (min(window_inh) - mean(m(:))) / std(m(:));

            if z_inh <= -1.96 && any(window_inh < CI_window_down)
                text(min(xlim)+0.032, max(ylim)*0.8, '*inhibitory', 'color', 'b', 'FontSize', 7);
                text(min(xlim)+0.032, max(ylim)*0.92, sprintf('%.1f', z_inh), 'color', 'b', 'FontSize', 7);
            end
        end
    end

    z_inh_all(ct,1) = z_inh;
end
    end
saveas(gcf,[filename 'CCG.fig']);
xlswrite([filename 'CCG.xlsx'], connection);

% === Summary Table ===
conn_from = [];
conn_to = [];
zscore_exc = [];
zscore_inh = [];
conn_label = {};

ct = 0;
for i = 1:size(unit_t,2)
    for j = 1:size(unit_t,2)
        if i == j
            continue;
        end

        ct = ct + 1;
        z_exc = NaN;
        z_inh_val = NaN;
        label = "None";

        if ct <= size(connection,1)
            z_exc = connection(ct,1);
        end
        if ct <= size(z_inh_all,1)
            z_inh_val = z_inh_all(ct,1);
        end

        if ~isnan(z_exc) && z_exc >= 2 && ~isnan(z_inh_val) && z_inh_val <= -1.96
            label = "Both";
        elseif ~isnan(z_exc) && z_exc >= 2
            label = "Excitatory";
        elseif ~isnan(z_inh_val) && z_inh_val <= -1.96
            label = "Inhibitory";
        end

        conn_from(end+1,1) = i;
        conn_to(end+1,1) = j;
        zscore_exc(end+1,1) = round(z_exc, 2);
        zscore_inh(end+1,1) = round(z_inh_val, 2);
        conn_label{end+1,1} = label;
    end
end

output_table = table(conn_from, conn_to, zscore_exc, zscore_inh, conn_label, ...
    'VariableNames', {'From', 'To', 'ZScore_Excitatory', 'ZScore_Inhibitory', 'Type'});
writetable(output_table, [filename '_connection_table.xlsx']);

end

