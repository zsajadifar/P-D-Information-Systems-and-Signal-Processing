clear
path="measurments_IR";
IRname_60 =["/IR_LMA_M1_60.wav","/IR_LMA_M2_60.wav","/IR_LMA_M3_60.wav","/IR_LMA_M4_60.wav"];
IRname_135=["/IR_LMA_M1_135.wav","/IR_LMA_M2_135.wav","/IR_LMA_M3_135.wav","/IR_LMA_M4_135.wav"];
RIR_sources=[];

for j=1:4
    [IR_linear(:,j,1),fs_RIR]=audioread(path+IRname_60(j));
    [IR_linear(:,j,2),fs_RIR]=audioread(path+IRname_135(j));
end

IRname_60 =["/IR_HMAL_M1_60.wav","/IR_HMAL_M2_60.wav","/IR_HMAR_M1_60.wav","/IR_HMAR_M2_60.wav"];
IRname_135=["/IR_HMAL_M1_135.wav","/IR_HMAL_M2_135.wav","/IR_HMAR_M1_135.wav","/IR_HMAR_M2_135.wav"];
RIR_sources=[];

for j=1:4
    [IR_HM(:,j,1),fs_RIR]=audioread(path+IRname_60(j));
    [IR_HM(:,j,2),fs_RIR]=audioread(path+IRname_135(j));
end

speechfilename{1} = 'speech1.wav'; 
speechfilename{2} = 'White_noise1.wav'; 
noisefilename = [];
RIR_noise=[];
RIR_sources = IR_linear;
d =[0,0.05,0.1,0.15]';
% RIR_sources = IR_HM;
% noisefilename{1}='White_noise1.wav';
% noisefilename{1}='Babble_noise1.wav';
% noisefilename{1}='speech2.wav';
M = size(RIR_sources,2);
Q = size(RIR_sources,3);
mic_length = 3; % desired length of microphone signals in Sec
[mic,noise,speech,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_sources,RIR_noise);

%% DOA

L=1024;
overlap=L/2;
[mic_stft,freq,~] = stft(mic,fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'FrequencyRange','onesided');
mic_stft = permute(mic_stft,[3 1 2]);% M*n_F*n_T
power = mean(mean(abs(mic_stft).^2,3),1);
[~,W_max_indx] = max(power);
figure,plot(power)

c=340;
teta = 0:0.5:180;
teta = teta.*(pi/180);
TDOA = d*cos(teta)/c;

p_averaged=1;
for i=2:L/4
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
DOA_est=sort(DOA_est);
save("DOA_est.mat", "DOA_est");

[~,I]= min(abs(DOA_est-90));
DOA_target=DOA_est(I)