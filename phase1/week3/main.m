clear 
load('Computed_RIRs.mat')
assert(fs_RIR==44100,'fs should be 44.1 KHz')
speechfilename{1} = 'speech1.wav';
speechfilename{2} = 'speech2.wav';
% noisefilename{1}= 'White_noise1.wav';
noisefilename=[];
Q = size(RIR_sources,3);
mic_length = 5; % desired length of microphone signals in Sec
M = size(RIR_sources,2);
[mic,noise,speech,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_sources,RIR_noise);
soundsc(mic(:,1),fs_RIR)