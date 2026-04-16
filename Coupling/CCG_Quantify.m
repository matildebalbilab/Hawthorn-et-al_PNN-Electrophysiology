% ==== set your hemispheres (ranges or explicit vectors) ====
RH = 1:4;        % Right hemisphere unit IDs
LH = 5:6;       % Left hemisphere unit IDs

% ==== load your connection table ====
T = readtable('M82_D28_connection_table.xlsx');  % change filename

% ==== choose ONE direction only: RH -> LH ====
mask_dir = ismember(T.From, RH) & ismember(T.To, LH);

% ==== decide what counts as "connected" ====
isConnected = false(height(T),1);
if any(strcmp('Type', T.Properties.VariableNames))
    % Anything not "None" counts
    isConnected = ~strcmp(string(T.Type), "None");
elseif any(strcmp('ZScore_Excitatory', T.Properties.VariableNames))
    % Fallback: z_exc >= 2 counts
    isConnected = T.ZScore_Excitatory >= 2;
else
    error('No Type or ZScore_Excitatory column found.');
end

% ==== compute counts (unidirectional only) ====
n_possible = numel(RH) * numel(LH);         % RH->LH possible pairs
n_connected = sum(mask_dir & isConnected);  % RH->LH connected pairs
pct = 100 * n_connected / max(n_possible,1);

fprintf('Cross-hemisphere (RH->LH) connected: %d / %d (%.1f%%)\n', ...
        n_connected, n_possible, pct);

% OPTIONAL: if you want LH->RH instead, uncomment the next 5 lines:
% mask_dir_LHtoRH = ismember(T.From, LH) & ismember(T.To, RH);
% n_possible_LHtoRH = numel(LH) * numel(RH);
% n_connected_LHtoRH = sum(mask_dir_LHtoRH & isConnected);
% pct_LHtoRH = 100 * n_connected_LHtoRH / max(n_possible_LHtoRH,1);
% fprintf('Cross-hemisphere (LH->RH) connected: %d / %d (%.1f%%)\n', n_connected_LHtoRH, n_possible_LHtoRH, pct_LHtoRH);
