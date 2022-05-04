clear
% close all

load('Computed_RIRs.mat')
assert(fs_RIR==44100,'fs should be 44.1 KHz')
speechfilename{1} = 'wav/whitenoise_signal_1.wav'; % noise source
speechfilename{2} = 'wav/speech1.wav'; % target source
noisefilename = [];
% noisefilename{1}='White_noise1.wav';
% noisefilename{1}='Babble_noise1.wav';
% noisefilename{1}='speech2.wav';
M = size(RIR_sources,2);
mic_length = 20; % desired length of microphone signals in Sec
[mic,noise,speech,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_sources,RIR_noise,1);

%% DOA estimation
[DOA_est,mic_stft] = MUSIC_wideband(mic);

%% find target speech
[~,I]= min(abs(DOA_est-90));
DOA_target=DOA_est(I);

%% FAS
[w_FAS,B] = FAS(RIR_sources(:,:,I));

%% NLMS
[fas_out,gsc_speech]=FD_GSC(mic, w_FAS,B);

%% plot
figure
hold on
plot(mic(:, 1), 'DisplayName', 'Microphone');
plot(fas_out, 'DisplayName', 'W_{fas} output');
plot(gsc_speech, 'DisplayName', 'GSC output');

xlabel('Samples');
ylabel('Amplitude');
title(sprintf('Frequency-domain GSC: t_{60} = %2.2f', rev_time));
legend




