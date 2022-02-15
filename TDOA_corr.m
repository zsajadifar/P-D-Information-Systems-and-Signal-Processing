%% Week1,part3,Cross-correlation-based TDOA estimation
clear all
load('D:\KU Leuven\Semester 2\P&D\week1\sim_environment\Computed_RIRs.mat');

%% ground truth for TDOA estimation 

figure,
plot(RIR_sources(:,1),'r')
hold on
plot(RIR_sources(:,2),'b')

indx1 = find(RIR_sources(:,1)~=0);
indx2 = find(RIR_sources(:,2)~=0);

TDOA_groundtruth = abs(indx1(1)-indx2(1));

%% estimated TDOA
%speechfilename{1} = 'whitenoise_signal_1.wav';
speechfilename{1} = 'part1_track1_dry.wav';
noisefilename=[];
mic_length = 10; % desired length of microphone signals in Sec
mic_num = size(RIR_sources,2); 
mic = create_mic_sigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise);

figure,
plot(mic(:,1),'r')
hold on
plot(mic(:,2),'b')

segment = mic(1:40000,2);
[r,lag] = xcorr(mic(:,1),segment);
[max_corr,indx] = max(abs(r));
TDOA_estimated = abs(lag(indx));
figure,stem(lag,r)
title('time domain cross correlation function')

differnce= TDOA_estimated - TDOA_groundtruth



function [mic] = create_mic_sigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise)
    L = mic_length*fs_RIR;
    mic_targets=zeros(L,mic_num);
    mic_noises =zeros(L,mic_num);
    for i=1:length(speechfilename)
        [speech,fs] = audioread(speechfilename{i});
        % resampling
        if(fs ~= fs_RIR)
            speech = resample(speech,fs_RIR,fs);
        end
        mic_targets= mic_targets+fftfilt(RIR_sources(:,:,i),speech(1:L));
    end
    
    for i=1:length(noisefilename)
        [noise,fs] = audioread(noisefilename{i});
        %resampling
        if(fs ~= fs_RIR)
            noise = resample(noise,fs_RIR,fs);
        end
        mic_noises= mic_noises+fftfilt(RIR_noise(:,:,i),noise(1:L));
    end
    mic = mic_noises + mic_targets;
    save('mic.mat','mic','fs_RIR');
end




