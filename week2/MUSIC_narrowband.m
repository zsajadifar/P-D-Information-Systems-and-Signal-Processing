clear 
load('Computed_RIRs.mat')
assert(fs_RIR==44100,'fs should be 44.1 KHz')
speechfilename{1} = 'speech1.wav';
noisefilename=[];
mic_length = 10; % desired length of microphone signals in Sec
mic_num = size(RIR_sources,2);
[mic] = create_micsigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise);

L=1024;
overlap=512;
[mic_stft,freq,~] = stft(mic,fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L);
mic_stft = permute(mic_stft,[3 1 2]);% M*n_F*n_T
power = mean(mean(abs(mic_stft).^2,3),1);
figure,plot(freq,10*log10(power))
xlabel('frequency'); ylabel('power')
title('Power, averaged over all mics and time frames')
[~,W_max_indx] = max(power);
W_max = freq(W_max_indx);

%% pseudospectrum
teta = 0:0.5:180;
