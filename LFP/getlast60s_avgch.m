function getlast60s_avgch(filename, tetrode1_chans, tetrode2_chans)
    % Input: filename - base name of the .mat file containing NS6
    %        tetrode1_chans - vector of channel numbers for tetrode 1 (2, 3, or 4 channels)
    %        tetrode2_chans - vector of channel numbers for tetrode 2 (2, 3, or 4 channels)

    close all
    fs = 30000;  % Sampling rate
    f1 = 1; f2 = 100; band = [f1 f2];  % Bandpass filter range

    % Load data
    fileData = load([filename '.mat']);
    dataStruct = fileData.NS6;
    data = double(dataStruct.Data)';  % [samples x channels]

    tetrode_list = {tetrode1_chans, tetrode2_chans};

    for t = 1:2
        ch_group = tetrode_list{t};
        n_channels = length(ch_group);

        % Assert that there are 2, 3, or 4 channels, not more or less
        if ~ismember(n_channels, [1, 2, 3, 4])
            error('Each tetrode must have 2, 3, or 4 channels.');
        end

        start_sample = 60 * fs + 1;   % start at 60 s
        end_sample   = 120 * fs;      % end at 120 s
        this_60s_idx = start_sample:end_sample;
        sigs = [];

        for j = 1:n_channels
            channelData = data(this_60s_idx, ch_group(j));
            [s_filt, newfs0, ~] = myfilter(channelData, band(1)-0.5, band(1), band(2), band(2)+0.5, 80, 1, 80, fs);
            sigs(:, j) = s_filt(:);
        end

        % Average across the available channels
        avg_sig = mean(sigs, 2);

        % Apply notch filter at 50 Hz
        d = designfilt('bandstopiir', 'FilterOrder', 2, ...
                       'HalfPowerFrequency1', 49.5, 'HalfPowerFrequency2', 50.5, ...
                       'DesignMethod', 'butter', 'SampleRate', newfs0);
        mean_sig0 = filtfilt(d, avg_sig);

        % Save output
        outdir = 'I:\MBLAB1-Q3474\Phoebe\MND\electrophysiology\LFP\Average';
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end

        % Create a tag for the channels used (e.g., "1-4" or "7-8")
        chanTag = strjoin(arrayfun(@num2str, ch_group, 'UniformOutput', false), '-');

        % Side label
        if t == 1
            side = 'RH';
        else
            side = 'LH';
        end

        % File name includes side + channels
        outfile = fullfile(outdir, sprintf('%s_%s_last60s_avg_ch%s.mat', filename, side, chanTag));

        % Save the data along with metadata
        channels_used = ch_group; % store in file for clarity
        save(outfile, 'mean_sig0', 'newfs0', 'channels_used');

    end
end


