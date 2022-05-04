clear

RIR_75_165 = load('simulations/RIR_15_-75.mat').RIR_sources;
RIR_60_150 = load('simulations/RIR_30_-60.mat').RIR_sources;
RIR_45_135 = load('simulations/RIR_45_-45.mat').RIR_sources;
RIR_30_120 = load('simulations/RIR_60_-30.mat').RIR_sources;
RIR_15_105 = load('simulations/RIR_75_-15.mat').RIR_sources;
RIR = cat(4,RIR_75_165,RIR_60_150,RIR_45_135,RIR_30_120,RIR_15_105);

RIR_75_165_rev = load('simulations/RIR_15_-75_rev.mat').RIR_sources;
RIR_60_150_rev = load('simulations/RIR_30_-60_rev.mat').RIR_sources;
RIR_45_135_rev = load('simulations/RIR_45_-45_rev.mat').RIR_sources;
RIR_30_120_rev = load('simulations/RIR_60_-30_rev.mat').RIR_sources;
RIR_15_105_rev = load('simulations/RIR_75_-15_rev.mat').RIR_sources;
RIR_rev = cat(4,RIR_75_165_rev,RIR_60_150_rev,RIR_45_135_rev,RIR_30_120_rev,RIR_15_105_rev);

RIR_noise=[];
fs_RIR=44100;
speechfilename{1} = 'wav/part1_track2_dry.wav'; 
speechfilename{2} = 'wav/part1_track1_dry.wav'; 
noisefilename = [];
M = 5;
mic_length = 10; % sec

for i=1:5
    [mic(:,:,i),~,~,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR(:,:,:,i),RIR_noise,i);
end

for i=1:5
    [mic_rev(:,:,i),~,~,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_rev(:,:,:,i),RIR_noise,i);
end

for i=1:5
    %% DOA estimation
    [DOA_est(:,i),mic_stft] = MUSIC_wideband(mic(:,:,i));
    
    %% FAS
    [w_FAS,B] = FAS(RIR(:,:,1,i));
    
    %% NLMS
    [fas_out(:,i),gsc_speech(:,i)]=FD_GSC(mic(:,:,i), w_FAS,B);
end

fas_out = fas_out(:);
gsc_speech=gsc_speech(:);
speech = mic(:,1,:);
speech = speech(:);

%% plot
figure
hold on
plot(speech, 'DisplayName', 'Microphone');
plot(fas_out, 'DisplayName', 'W_{fas} output');
plot(gsc_speech, 'DisplayName', 'GSC output');

xlabel('Samples');
ylabel('Amplitude');
% title(sprintf('Frequency-domain GSC: t_{60} = %2.2f', rev_time));
legend






