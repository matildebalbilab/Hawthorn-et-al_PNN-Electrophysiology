function LFP_Corr(filename, Ch1, Ch2)
   
    close all
    fs = 30000;  %sampling rate; for NS4 files, it's 10000; for NS6 files, 30000
    %f1=1;f2=100; band=[f1 f2];  %bandpass filter range
    f1 = [1.5 4 10 30 55 1];
    f2 = [4 10 30 55 100 100];
    % read channel data
    fileData = load([filename '.mat']);
    tic
    dataStruct = fileData.NSx;
    %dataStruct = fileData.NS6;
    data = double(dataStruct.Data)';
  
%     dataStruct = eval('NS6');
%     data = [dataStruct.Data]';
    c1 = data(:, Ch1);
    c2 = data(:, Ch2);
    %   data = double(data);

    corrvalue = zeros(length(f1), 2); % Initialize corrvalue matrix
    for m = 1:length(f1)
        a = f1(m);
        b = f2(m);

        [sig0, newfs0, N] = myfilter(c1((end-60*fs):end), f1(m)-0.5, f1(m), f2(m), f2(m)+0.5, 80, 1, 80, fs);
        % second step: notch filter get rid of 50Hz
        load notchfilter.mat
        RH = filtfilt(d, sig0);

        %extract Hip signal
        [sig0, newfs0, N] = myfilter(c2((end-60*fs):end), f1(m)-0.5, f1(m), f2(m), f2(m)+0.5, 80, 1, 80, fs);

        %second step: notch filter get rid of 60Hz
        LH = filtfilt(d, sig0);

        % Calculate cross-correlation between RSC and Hip
        [RH_LH_corr, l] = xcorr(RH, LH, ceil(newfs0/2), 'coeff');
        save([filename '_band_' num2str(m) '_RH_LH_corr'], 'RH_LH_corr');

        % Find max correlation coefficient and lag
        [maxcoeff, mIndex] = max(RH_LH_corr);
        lag = l(mIndex) / (newfs0) * 1000;
        corrvalue(m, :) = [maxcoeff; lag];

        % Save corrvalue for each band
        save([filename '_band_' num2str(m) '_corr_coefficient_and_lag'], 'corrvalue');

        % Move files
        movefile(['* band ' num2str(m) ' corr coefficient and lag*'], ['band_' num2str(m) '_LFP_coeff_lag']);
        movefile(['*_corr*'], ['band_' num2str(m) '_LFPcorr']);
    end
end