%% Week1,part4,Cross-correlation-based DOA estimation
clear
load('D:\KU Leuven\Semester 2\P&D\week1\Computed_RIRs.mat');

% Microphone distance
d = m_pos(1,2) - m_pos(2,2);
c = 340; % speed of sound

%% estimated TDOA
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

x_delay = c * (TDOA_estimated/fs_RIR);

DOA_rad = acos(x_delay/d);
DOA_deg = DOA_rad * 180/pi;
DOA_est = DOA_deg;

save('DOA_est.mat','DOA_est')


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





