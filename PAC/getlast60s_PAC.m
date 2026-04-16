function getlast60s_PAC(filename,Ch1,Ch2)

    close all
    fs = 30000;  
    f1 = 1; 
    f2 = 100; 
    band = [f1 f2];

    % Load data
    fileData = load([filename '.mat']);
    dataStruct = fileData.NSx;
    data = double(dataStruct.Data)';

    % Loop through Hip and RSC channels
    for i = [Ch1 Ch2]

        channelData = data(:,i);

        % last 60 s
        segment = channelData((end-60*fs+1):end);

        % bandpass filter
        [sig0,newfs0,N] = myfilter(segment,band(1)-0.5,band(1),band(2),band(2)+0.5,80,1,80,fs);
        fprintf('Channel %d, newfs0 = %.2f Hz\n', i, newfs0);

        % notch filter
        d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49.5,'HalfPowerFrequency2',50.5, ...
               'DesignMethod','butter','SampleRate',newfs0);

        mean_sig0 = filtfilt(d,sig0);

        % Decide whether this channel is Hip or RSC
        if i == Ch1
            region = 'Hip';
        elseif i == Ch2
            region = 'RSC';
        end

        % Save filtered trace
        save([filename '_' region '_filtered.mat'],'mean_sig0','newfs0');

        % PAC
        [pac0, ph, amp] = find_pac_shf(mean_sig0, newfs0, 'mi', mean_sig0, [1:0.2:20], [1:0.2:101]);

        % Save PAC output
        save([filename '_' region '_PAC.mat'],'pac0','ph','amp','newfs0');

        % Save figure separately
        title([filename ' ' region ' PAC']);
        set(gcf,'position',[0 200 500 400]);
        colormap jet;
        savefig([filename '_' region '_PAC.fig']);
        saveas(gcf,[filename '_' region '_PAC.png']);

        close(gcf)
    end
end