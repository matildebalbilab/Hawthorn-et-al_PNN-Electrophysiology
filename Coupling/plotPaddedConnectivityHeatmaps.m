function plotPaddedConnectivityHeatmaps(groupFolders, groupNames)
% Plots average Hip→RSC connectivity heatmaps per group based on strongest Z-scores
% Combines excitatory and inhibitory (whichever is stronger), and computes group difference map.

nGroups = length(groupFolders);
maxHip = 0; maxRSC = 0;

% Pass 1: Determine max Hippocampus and RSC unit counts across groups
for g = 1:nGroups
    files = dir(fullfile(groupFolders{g}, '*_connection_table.xlsx'));
    for k = 1:length(files)
        [~, name, ~] = fileparts(files(k).name);
        animalID = regexp(name, '^(\d+)', 'match', 'once');
        if isempty(animalID), continue; end

        metaFile = fullfile(groupFolders{g}, [animalID '_UnitRegionMetadata.mat']);
        if ~isfile(metaFile), continue; end

        metaVar = load(metaFile);
        unitRegionTable = metaVar.unitRegionTable;

        hipCount = sum(strcmp(unitRegionTable.Region, 'Hippocampus'));
        rscCount = sum(strcmp(unitRegionTable.Region, 'RSC'));
        maxHip = max(maxHip, hipCount);
        maxRSC = max(maxRSC, rscCount);
    end
end

% Pass 2: Build per-animal padded matrices of strongest z-score
groupZ = cell(nGroups,1);
for g = 1:nGroups
    groupMat = [];
    files = dir(fullfile(groupFolders{g}, '*_connection_table.xlsx'));
    for k = 1:length(files)
        [~, name, ~] = fileparts(files(k).name);
        animalID = regexp(name, '^(\d+)', 'match', 'once');
        if isempty(animalID), continue; end

        metaFile = fullfile(groupFolders{g}, [animalID '_UnitRegionMetadata.mat']);
        if ~isfile(metaFile), continue; end

        metaVar = load(metaFile);
        unitRegionTable = metaVar.unitRegionTable;

        T = readtable(fullfile(groupFolders{g}, files(k).name));
        hipUnits = unitRegionTable.Unit(strcmp(unitRegionTable.Region, 'Hippocampus'));
        rscUnits = unitRegionTable.Unit(strcmp(unitRegionTable.Region, 'RSC'));

        matZ = NaN(maxHip, maxRSC);

        for i = 1:height(T)
    from = T.From(i);
    to   = T.To(i);

    if ismember(from, hipUnits) && ismember(to, rscUnits)
        iRow = find(hipUnits == from);
        iCol = find(rscUnits == to);
        if isempty(iRow) || isempty(iCol), continue; end

        zExc = T.ZScore_Excitatory(i);
        zInh = T.ZScore_Inhibitory(i);

        isExc = zExc >= 2;
        isInh = zInh <= -1.96;

        if isExc && ~isInh
            matZ(iRow, iCol) = zExc;
        elseif isInh && ~isExc
            matZ(iRow, iCol) = zInh;
        elseif isExc && isInh
            if abs(zExc) > abs(zInh)
                matZ(iRow, iCol) = zExc;
            else
                matZ(iRow, iCol) = zInh;
            end
        end
    end
end

        groupMat = cat(3, groupMat, matZ);
    end
    groupZ{g} = groupMat;
end

% Plot average Z-score heatmaps per group
figure('Name', 'Combined Heatmaps'); colormap(jet);
for g = 1:nGroups
    meanZ = nanmean(groupZ{g}, 3);
    subplot(1, nGroups, g);
    h = imagesc(meanZ, [-5 5]);
    title(groupNames{g}, 'FontWeight', 'bold');
    xlabel('RSC Units'); ylabel('Hippocampus Units');
    axis square; colorbar;
    xlim([0.5 6.5]); ylim([0.5 6.5]);
    xticks([2 4 6]); yticks([2 4 6]);
    set(gca, 'Color', [1 1 1]); % NaNs white
    set(h, 'AlphaData', ~isnan(meanZ));
end

% Plot difference heatmap (Group 2 - Group 1)
if nGroups == 2
    diffZ = nanmean(groupZ{2}, 3) - nanmean(groupZ{1}, 3);
    figure('Name', 'Difference (Group 2 - Group 1)');
    colormap(parula);
    h = imagesc(diffZ, [-5 5]);
    title('Difference Z-score (Group 2 - Group 1)', 'FontWeight', 'bold');
    xlabel('RSC Units'); ylabel('Hippocampus Units');
    axis square; colorbar;
    xlim([0.5 6.5]); ylim([0.5 6.5]);
    xticks([2 4 6]); yticks([2 4 6]);
    set(gca, 'Color', [1 1 1]);
    set(h, 'AlphaData', ~isnan(diffZ));
end
end
