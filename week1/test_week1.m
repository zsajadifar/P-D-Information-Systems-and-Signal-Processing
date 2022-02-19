%% Week1,part2,microphone signal
clear
load('D:\KU Leuven\Semester 2\P&D\week1\sim_environment\Computed_RIRs.mat');

% define desired speech and noise filename 
speechfilename{1} = 'speech1.wav';
% speechfilename{2} = 'speech2.wav';
% noisefilename{1}  = 'whitenoise_signal_1.wav';
% noisefilename{1}  = 'whitenoise_signal_2.wav';
%noisefilename{1}  = 'Babble_noise1.wav';
noisefilename=[];

mic_length = 10; % desired length of microphone signals in Sec
mic_num = size(RIR_sources,2); 

mic = create_micsigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise);

figure,
plot(mic(:,1))
hold on
plot(mic(:,2))

soundsc(mic(:,2),fs_RIR)

%%

%% Week1,part3,Cross-correlation-based TDOA estimation
clear
load('D:\KU Leuven\Semester 2\P&D\week1\sim_environment\Computed_RIRs.mat');
% ground truth for TDOA estimation 
figure,
plot(RIR_sources(:,1),'r')
hold on
plot(RIR_sources(:,2),'b')

indx1 = find(RIR_sources(:,1)~=0);
indx2 = find(RIR_sources(:,2)~=0);

TDOA_groundtruth = abs(indx1(1)-indx2(1));

% estimated TDOA
%speechfilename{1} = 'whitenoise_signal_1.wav';
speechfilename{1} = 'part1_track1_dry.wav';
noisefilename=[];
mic_length = 10; % desired length of microphone signals in Sec
mic_num = size(RIR_sources,2); 
mic = create_micsigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise);

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


%%

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
mic = create_micsigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise);

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



