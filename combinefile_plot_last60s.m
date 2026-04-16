%% Run this separately for the folders for left and right channels
% no need to scale NS4 files but need to divide sig1/mean_LFP by 10 for NS6
% files at three places: ~line 31 plot(); ~line 37 spectrogram(); ~line 47 pwelch()

clear matfile
close all
PathName = pwd;
[~, filename] = fileparts(PathName);
file_all = dir(fullfile(PathName,'*.mat'));
matfile = file_all([file_all.isdir] == 0); 
clear file_all

% if contains(PathName, 'right')==1
%     channelPos='_right';
% elseif contains(PathName, 'left')==1
%     channelPos='_left';
% end
% 
% if contains(PathName, '40Hz') == 1
%     conditionCode ='40Hz';
% elseif contains(PathName, 'random') == 1
%     conditionCode ='random';
% elseif contains(PathName, 'sham') == 1
%     conditionCode ='sham';
% end

x=[]; LFP=[];                        % start w/ an empty array
for i = 1:length(matfile)
    x = [x; load(matfile(i).name)];   % get all the .mat files' contents
end

for c=1:length(matfile)
    LFP(:,c) = x(c).mean_sig0;
end

if length(matfile)>1
    mean_LFP = mean(LFP,2)';
elseif length(matfile)==1
    mean_LFP = LFP';
end

% x = []; 
% LFP = [];  % initialize
% 
% for i = 1:length(matfile)
%     temp = load(matfile(i).name);
% 
%     % Get signal and force column vector
%     signal = temp.mean_sig0(:);
% 
%     % Trim or pad to exactly 600000 samples
%     if length(signal) > 600000
%         signal = signal(1:600000);
%     elseif length(signal) < 600000
%         signal(end+1:600000) = signal(end);  % or use NaN
%     end
% 
%     % Store trimmed signal
%     LFP(:, i) = signal;
% 
%     % Store struct if you still need full metadata
%     x = [x; temp];
% end
% 
% % Average across LFP columns
% if size(LFP, 2) > 1
%     mean_LFP = mean(LFP, 2);
% else
%     mean_LFP = LFP';
% end
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49.5,'HalfPowerFrequency2',50.5, ...
               'DesignMethod','butter','SampleRate',1000);

%save('notchfilter','d');

%load notchfilter.mat
 mean_LFP = filtfilt(d,mean_LFP);

% % =========================================================================
% % Artifact rejection based on amplitude threshold
% % =========================================================================
% artifact_thresh = 150;  % in µV
% buffer = round(0.5 * newfs0);  % 0.5 sec padding around artifact
% 
% artifact_idx = find(abs(mean_LFP) > artifact_thresh);  % sample indices above threshold
% 
% % Create a logical mask for artifact regions
% artifact_mask = false(size(mean_LFP));
% for i = 1:length(artifact_idx)
%     idx_range = max(1, artifact_idx(i)-buffer):min(length(mean_LFP), artifact_idx(i)+buffer);
%     artifact_mask(idx_range) = true;
% end
% 
% % Option 1: Replace with NaNs (safe for plotting, breaks some analyses)
% clean_LFP = mean_LFP;
% clean_LFP(artifact_mask) = NaN;
% 
% % Option 2: Interpolate instead (preferred for spectral analysis)
% % clean_LFP = fillmissing(mean_LFP, 'linear');
% Artifact rejection


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
mean_LFP = mean_sig0;
newfs0 = 1000;
figure(1)
subplot(2,1,1)
plot(1/newfs0:1/newfs0:length(mean_LFP/10)/newfs0, mean_LFP/10,'r','Linewidth',0.5); 
ylabel('Amplitude(uV)'); 
ylim([-300 300]); 
xlim([0 length(mean_LFP)]/newfs0) % ylim([-250 250]) in the og script
%xlim([0 20])
set(gca,'fontsize',12,'linewidth',1,'box','off')
hold on
subplot(2,1,2)


% spectrogram(mean_LFP(1:(round(length(mean_LFP))-1)),2000,1980,[1:0.5:100],newfs0,'yaxis');%Pf=Pf/mean(Pf(:))
%spectrogram(mean_LFP(1:(round(length(mean_LFP)))), round(newfs0*2), round(newfs0*2-100),[1:0.025:100], newfs0, 'yaxis');%Pf=Pf/mean(Pf(:))
spectrogram(mean_LFP(1:(round(length(mean_LFP))-2531)), round(newfs0*2), round(newfs0*2-100),[1:0.025:100], newfs0, 'yaxis'); 
% colormap jet;set(gca,'ydir','normal');caxis([-10,25]); ylim([1 100]);xlim([0 57]); colorbar off


%saxon edit
    
%     win=2*newfs;%window size original was 2*newfs
%     %test = [band(1):0.0025:band(2)]; %[band(1):diff(band)/:band(2)] %experimenting with different sampling rates for frequency domain
%     test = [0:0.25:100];
%     spectrogram(mean_LFP(1:(round(length(mean_LFP))-2531)), round(win), round(win-win/20), test, newfs, 'yaxis');%Pf=



colormap jet;set(gca,'ydir','normal');caxis([0,40]); ylim([1 100]);
set(gcf,'position',[10 100 800 400])
set(gcf,'color','w')
set(gca,'fontsize',12,'linewidth',1,'box','off') %axis setting
%xlim([0 20])
savefig(['data and PSD.fig'])

% there are two ways to calculate power, pwelch or chronux tool
w0 = hanning(round(length(mean_LFP(1:(length(mean_LFP)-2531)))/16));
[pxx0,fxx0] = pwelch(mean_LFP(1:(length(mean_LFP)-2531)),w0,0,[],newfs0);
%   params.Fs=1000;%params.tapers=7
%   [S,f]=mtspectrumc(sig1,params)
%   pf=[f,S]
   
% save powerdistribution.mat, 1st column is frequecy, 2nd column is power
% value
pf = [fxx0,pxx0]; save(['powerdistri.mat'],'pf')
deltarange = find(pf(:,1)>=1.5&pf(:,1)<=4)
deltapower = mean(10*log10(pf(deltarange,2))) 

thetarange = find(pf(:,1)>=4&pf(:,1)<=8)
thetapower = mean(10*log10(pf(thetarange,2)))

alpharange = find(pf(:,1)>=8&pf(:,1)<=12)
alphapower = mean(10*log10(pf(alpharange,2)))

betarange = find(pf(:,1)>=12&pf(:,1)<=30)
betapower = mean(10*log10(pf(betarange,2)))

slowgammarange = find(pf(:,1)>=30&pf(:,1)<=55)
slowgammapower = mean(10*log10(pf(slowgammarange,2)))

fastgammarange = find(pf(:,1)>=55&pf(:,1)<=80)
fastgammapower = mean(10*log10(pf(fastgammarange,2)))

%sharpwaveripplerange = find(pf(:,1)>=100&pf(:,1)<=200)
%sharpwaveripplepower = mean(10*log10(pf(sharpwaveripplerange,2)))

totalrange = find(pf(:,1)>=1&pf(:,1)<=100)
totalpower = mean(10*log10(pf(totalrange,2)))
% save power value
save(['LFP power.mat'],'deltapower','alphapower','thetapower','betapower','slowgammapower','fastgammapower','totalpower');
%save(['LFP power.mat'],'deltapower','thetapower','betapower','slowgammapower','fastgammapower','totalpower');   
% movefile('*.fig*','LFP PSD figures')
% movefile('*power.mat','LFP power')
% movefile('*powerdistri_*','LFP powerdistribution')

%% another way of calculating power values


params.Fs=1000;params.tapers=[3 5];params.fpass=[0 100]
% 


   movingwin=[1 0.1]
   [S,t,f]=mtspecgramc(mean_LFP,movingwin,params)
   plot_matrix(S,t,f);
   colormap jet;set(gca,'ydir','normal');caxis([0,40]);ylim([1 95]);xlim([39 57]); colorbar off

 set(gcf,'position',[100 100 300 480])
 xlabel('Time (s)');ylabel('Frequency (Hz)')
 set(gcf,'color','w')
 set(gca,'fontsize',8,'linewidth',1,'box','off')%axis setting
 savefig(['Spectrogram'])

% %% Plot the spectrogram
% % === Chronux spectrogram with theta and gamma band highlights ===
% params.Fs = 1000;
% params.tapers = [3 5];
% params.fpass = [0 100];
% 
% movingwin = [1 0.1];
% [S, t, f] = mtspecgramc(mean_LFP, movingwin, params);
% 
% % === Plot ===
% figure;
% plot_matrix(S, t, f);
% colormap jet;
% set(gca, 'ydir', 'normal');
% caxis([0, 40]);
% ylim([1 95]);
% xlim([2 20]);
% colorbar off;
% 
% % === Overlay white bands ===
% hold on;
% theta_band = [4 12];
% gamma_band = [30 80];
% 
% % Theta band overlay
% fill([t(1) t(end) t(end) t(1)], ...
%      [theta_band(1) theta_band(1) theta_band(2) theta_band(2)], ...
%      'w', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
% 
% % Gamma band overlay
% fill([t(1) t(end) t(end) t(1)], ...
%      [gamma_band(1) gamma_band(1) gamma_band(2) gamma_band(2)], ...
%      'w', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
% 
% % === Aesthetics ===
% xlabel('Time (s)');
% ylabel('Frequency (Hz)');
% set(gca, 'fontsize', 8, 'linewidth', 1, 'box', 'off');
% set(gcf, 'color', 'w');
% set(gcf, 'position', [100 100 300 480]);
% 
% % === Save the figure ===
% savefig('Spectrogram_withBands.fig');
% 
% 
% %    movingwin=[0.5 2]
% %    [S,t,f]=mtspecgramc(mean_LFP,movingwin,params)
% %    % Apply 2D Gaussian smoothing: [frequency smoothing, time smoothing]
% %     S_smooth = imgaussfilt(S, [1 2]);  % adjust values if needed
% %        
% %     % Plot original
% %     figure;
% %     subplot(1,2,1)
% %     plot_matrix(S, t, f);
% %     colormap jet;set(gca,'ydir','normal');caxis([0,40]);ylim([1 95]);xlim([2 20]); colorbar off
% %     title('Raw Spectrogram')
% % 
% %     % Plot the smoothed spectrogram
% %     plot_matrix(S_smooth, t, f);
% %     plot_matrix(S,t,f);
% %     colormap jet;set(gca,'ydir','normal');caxis([0,40]);ylim([1 95]);xlim([2 20]); colorbar off
% % 
% %  set(gcf,'position',[100 100 300 480])
% %  xlabel('Time (s)');ylabel('Frequency (Hz)')
% %  set(gcf,'color','w')
% %  set(gca,'fontsize',8,'linewidth',1,'box','off')%axis setting
% %  savefig(['Spectrogram'])



%  
% params.Fs=1000;params.tapers=[3 5];params.fpass=[1 100];movingwin=[2 0.1];
%     [S1,t1,f1]=mtspecgramc(mean_LFP,movingwin,params);
%     plot_matrix(S1,t1,f1);
%     colormap jet;
%     %set(gca,'ydir','normal');
%  
%     ylim([0 100])
%     xlabel('Time (s)');ylabel('Frequency (Hz)')
%     set(gca,'FontSize',12,'LineWidth',1,'box','off') %axis setting
%     title('PSD heatmap')
%     set(gcf,'color','w')
%     set(gcf,'position',[10 100 1000 800])
      
  
% savefig(['Left_EarlyBase_Evoked_mean_last60s_LFP_and_PSD'])
% saveas(gcf,'Left_EarlyBase_Evoked_mean_last60s_LFP_and_PSD.pdf')

% PATH='..\'
% movefile('*.pdf*',PATH)
% movefile('*.fig*',PATH)

