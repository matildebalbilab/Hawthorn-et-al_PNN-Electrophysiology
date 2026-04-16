clear all
PathName = pwd
file_all = dir(fullfile(PathName,'*.mat'));
matfile = file_all([file_all.isdir] == 0); 
clear file_all PathName
x=[];                               % start w/ an empty array
for i=1:length(matfile)
    x=[x; load(matfile(i).name)];   % get all the .mat files' contents
end

for c=1:length(matfile)
corr(c,:)=x(c).RSC_Hip_corr'
end


save RSCtoHip corr


 
