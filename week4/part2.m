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
speechfilename{1} = 'part1_track2_dry.wav'; 
speechfilename{2} = 'part1_track1_dry.wav'; 
noisefilename = [];
M = 5;
mic_length = 10; % sec

for i=1:5
    [mic(:,:,i),~,~,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR(:,:,:,i),RIR_noise);
end

for i=1:5
    [mic_rev(:,:,i),~,~,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_rev(:,:,:,i),RIR_noise);
end

for j=1:5
    

end





