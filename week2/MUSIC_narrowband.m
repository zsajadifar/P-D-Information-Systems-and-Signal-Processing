clear 
load('Computed_RIRs.mat')
assert(fs_RIR==44100,'fs should be 44.1 KHz')
speechfilename{1} = 'speech1.wav';
speechfilename{2} = 'speech2.wav';
noisefilename=[];
Q = size(RIR_sources,3);
mic_length = 10; % desired length of microphone signals in Sec
M = size(RIR_sources,2);
[mic] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_sources,RIR_noise);

L=1024;
overlap=512;
[mic_stft,freq,~] = stft(mic,fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'FrequencyRange','onesided');
mic_stft = permute(mic_stft,[3 1 2]);% M*n_F*n_T
power = mean(mean(abs(mic_stft).^2,3),1);
figure,plot(freq,10*log10(power))
xlabel('frequency'); ylabel('power')
title('Power, averaged over all mics and time frames')
[~,W_max_indx] = max(power);
y = squeeze(mic_stft(:,W_max_indx,:));
omega_max = 2*pi*freq(W_max_indx);
R = cov(y.');
[V,D]=eig(R);
E = V(:,1:M-Q);

%% pseudospectrum
c=340;
teta = 0:0.5:180;
teta = teta.*(pi/180);
d = m_pos(:,2) - m_pos(1,2);
TDOA = d*cos(teta)/c;
G = exp(-1j*omega_max*TDOA);
p = 1./diag((G'*E)*E'*G);
% figure,stem(abs(p))
figure,plot(abs(p))


[pks,loc] = findpeaks(abs(p));
[~,index] = maxk(pks, Q);
DOA_est=loc(index);
DOA_est = DOA_est*0.5;
save("DOA_est.mat", "DOA_est");



