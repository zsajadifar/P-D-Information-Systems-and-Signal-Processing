%% phase2, preprocessing audio data
%% Load data
clear 
load('audioprepro_constants.mat');
folder = '/Users/zahra/data/data';
env = '/env_train';
audio_files=dir(fullfile([folder,env],'*.wav'));
name ={audio_files.name};
num  = sscanf(sprintf('%s', name{:}),'envelope_track_%d.wav');
[~, index] = sort(num);
audio_files = audio_files(index);

fs = 8000;
for k=1:numel(audio_files)

    filename=audio_files(k).name;
    [A,Fs]= audioread([audio_files(k).folder,'/',audio_files(k).name]);

    %% step2, resampling
    A = resample(A,fs,Fs);
    
    %% step3, decompose to 15 frequency subbands
    for i=1:15
    A_filt(:,i)=fftfilt(g{i,1}.h,A);
    end
    
    %% step4, power law compression
    A_filt = abs(A_filt).^0.6;
    
    %% step5, downsampling
    A_reg = resample(A_filt,20,fs);
    A_cnn = resample(A_filt,70,fs);

    %% step6, combine bandbass filtered envelopes
    A_reg = sum(A_reg,2);
    A_cnn = sum(A_cnn,2);

    %% step7, bandpass filter
    [b1,a1] = butter(5,[1 9]/(20/2),'bandpass');
    [b2,a2] = butter(5,[1 32]/(70/2),'bandpass');
    A_reg = filter(b1,a1,A_reg);
    A_cnn = filter(b2,a2,A_cnn);

%     A_reg = bandpass(A_reg,[1 9],20);
%     A_cnn = bandpass(A_cnn,[1 32],70);

    env_reg(:,k)= A_reg;
    env_cnn(:,k)= A_cnn;

end

save('env_data.mat',"env_reg","env_cnn","-v7.3")