%% Week1,part2,microphone signal
clear all
load('D:\KU Leuven\Semester 2\P&D\week1\sim_environment\Computed_RIRs.mat');

% define desired speech and noise filename 
speechfilename{1} = 'speech1.wav';
% speechfilename{2} = 'speech2.wav';
% noisefilename{1}  = 'whitenoise_signal_1.wav';
% noisefilename{1}  = 'whitenoise_signal_2.wav';
noisefilename{1}  = 'Babble_noise1.wav';

mic_length = 10; % desired length of microphone signals in Sec
mic_num = size(RIR_sources,2); 

mic = create_mic_sigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise);

figure,
plot(mic(:,1))
hold on
plot(mic(:,2))

soundsc(mic(:,1),fs_RIR)


function [mic] = create_mic_sigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise)
    L = mic_length*fs_RIR;
    mic_targets=zeros(L,mic_num);
    mic_noises =zeros(L,mic_num);
    for i=1:length(speechfilename)
        [speech,fs] = audioread(speechfilename{i});
        % resampling
        if(fs ~= fs_RIR)
            t = 0:1/fs_RIR:length(speech)/fs -1/fs_RIR;
            speech = resample(speech,t,fs_RIR);
        end
        mic_targets= mic_targets+fftfilt(RIR_sources(:,:,i),speech(1:L));
    end
    
    for i=1:length(noisefilename)
        [noise,fs] = audioread(noisefilename{i});
        %resampling
        if(fs ~= fs_RIR)
            t = 0:1/fs_RIR:length(noise)/fs -1/fs_RIR;
            noise = resample(noise,t,fs_RIR);
        end
        mic_noises= mic_noises+fftfilt(RIR_noise(:,:,i),noise(1:L));
    end
    mic = mic_noises + mic_targets;
    save('mic.mat','mic','fs_RIR');
end




