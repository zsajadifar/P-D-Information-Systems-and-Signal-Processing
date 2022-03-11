clear 
load('Computed_RIRs.mat')
assert(fs_RIR==44100,'fs should be 44.1 KHz')
speechfilename{1} = 'speech2.wav'; % noise source
speechfilename{2} = 'speech1.wav'; % target source
noisefilename = [];
% noisefilename{1}='White_noise1.wav';
% noisefilename{1}='Babble_noise1.wav';
% noisefilename{1}='speech2.wav';
M = size(RIR_sources,2);
mic_length = 3; % desired length of microphone signals in Sec
[mic,noise,speech,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,M,fs_RIR,RIR_sources,RIR_noise);

%% speech
Q = size(RIR_sources,3);
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
d = m_pos(:,2) - m_pos(1,2);
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
DOA_target=DOA_est(I);

[RIR_stft,freq,~] = stft(RIR_sources(:,:,I),fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'FrequencyRange','onesided');
a = squeeze(mean(RIR_stft,2));
h = a ./ a(:,1);
% h = h(2:end,:);
w_FAS = h./(diag(h'*h))';

for i=1:L/2+1
    A = h(i,:);
    B (:,:,i)= null(A)';
end

%% Filtering and NLMS

mu = 10^-11;
alpha = 10^-5;

for j=1:size(mic_stft,3)%time
    W = zeros(size(mic_stft,2),M-1);
    for i=1:size(mic_stft,2)%freq
        u = mic_stft(:,i,j);
        desired(i,j) = conj(w_FAS(i,:))*u;

        X=conj(B(:,:,i))*u;
        X_norm = X'*X;
        t(i,j)= conj(W(i,:))*X;
        err(i,j)=desired(i,j)-t(i,j);
        W(i+1,:) = W(i,:).' + (mu/((X_norm^2)+alpha))*X*conj(err(i,j));

    end
    desired_sym(:,j)= [flip(conj(desired(2:end-1,j)));0;desired(2:end-1,j);0];
    err_sym(:,j)= [flip(conj(err(2:end-1,j)));0;err(2:end-1,j);0];

end

desired_time =istft(desired_sym,fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'Method','wola','ConjugateSymmetric',true);
err_time     =istft(err_sym,fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'Method','wola','ConjugateSymmetric',true);

figure,plot(err_time(100:end-100))
title('GSC final out')
figure,plot(desired_time(100:end-100))
title('output of FAS')
soundsc(err_time(100:end-100),fs_RIR)

% soundsc(desired_time(100:end-100),fs_RIR)






