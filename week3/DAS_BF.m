clear 
load('Computed_RIRs.mat')
assert(fs_RIR==44100,'fs should be 44.1 KHz')
speechfilename{1} = 'speech1.wav'; 
%  noisefilename = [];
noisefilename{1}='White_noise1.wav';
%  noisefilename{1}='Babble_noise1.wav';
% noisefilename{1}='speech2.wav';
M = size(RIR_sources,2);
mic_length = 3; % desired length of microphone signals in Sec
[mic,noise,speech,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_sources,RIR_noise);

%% speech
Q = size(RIR_sources,3)+size(RIR_noise,3);
L=1024;
overlap=L/2;
[mic_stft,freq,~] = stft(mic,fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'FrequencyRange','onesided');
mic_stft = permute(mic_stft,[3 1 2]);% M*n_F*n_T
power = mean(mean(abs(mic_stft).^2,3),1);
[~,W_max_indx] = max(power);

c=340;
teta = 0:0.5:180;
teta = teta.*(pi/180);
d = m_pos(:,2) - m_pos(1,2);
TDOA = d*cos(teta)/c;

p_averaged=1;
for i=2:L/2
    y = squeeze(mic_stft(:,i,:));
    omega_max = 2*pi*freq(i);
    R = cov(y.');
    [V,D]=eig(R);
    E = V(:,1:M-Q);
    G = exp(-1j*omega_max*TDOA);
    p(:,i) = 1./diag((G'*E)*E'*G);
    p_averaged= p_averaged .* p(:,i);  
end

figure,loglog(abs(p_averaged))
title('averaged power'),xlabel('theta')
[pks,loc] = findpeaks(abs(p_averaged));
[~,index] = maxk(pks, Q);
hold on,loglog(loc(index),pks((index)),'*')
DOA_est=loc(index);
DOA_est = DOA_est*0.5;
save("DOA_est.mat", "DOA_est");

%% delays
[~,I]= min(abs(DOA_est-90));
DOA_target=DOA_est(I);
d = m_pos(:,2) - m_pos(1,2);
TDOA = d*cos(deg2rad(DOA_target))/ c;
delay=ceil(TDOA*fs_RIR);

scale =1/M;
speech_delayed = delayseq(speech,delay);
speech_DAS =scale*sum(speech_delayed,2);

noise_delayed = delayseq(noise,delay);
noise_DAS =scale*sum(noise_delayed,2);

DAS_out = speech_DAS + noise_DAS;

SNR_out_DAS = 10*log10(var(speech_DAS)/var(noise_DAS));

figure,
plot(mic(:,1),'r')
hold on,
plot(DAS_out,'b')
title('the first mic signal and the DAS BF signal')
xlabel('t')
legend('mic','DAS out')

% soundsc(DAS_out,fs_RIR);    
% soundsc(mic(:,1),fs_RIR); 







