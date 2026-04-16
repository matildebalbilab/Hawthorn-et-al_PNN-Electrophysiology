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

d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49.5,'HalfPowerFrequency2',50.5, ...
               'DesignMethod','butter','SampleRate',1000);

 mean_LFP = filtfilt(d,mean_LFP);


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

