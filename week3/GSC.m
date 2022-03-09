clear

%% Run DAS_BF
DAS_BF

%% Blocking matrix and NLMS
mu = 0.5;
alpha = 10^-4;
L = 1024;
delta = L/2;
B = -eye(M-1);
B = [ones(M-1,1),B];
mic_delayed = speech_delayed + noise_delayed;
desired=[zeros(delta,1);DAS_out]; %% delayed DAS_out
VAD=abs(speech(:,1))>std(speech(:,1))*1e-3;
X = mic_delayed * B';
W = zeros(L,M-1);
err =zeros(numel(desired),1);


for i=L:length(X(:,1))
    X_norm=norm(X(i-L+1:i,:));
    t(i) = trace(W'*X(i-L+1:i,:));
    err(i)=desired(i)-t(i);
    W = W +(~VAD(i).*(mu/((X_norm^2)+alpha)*X(i-L+1:i,:)*err(i)));
end

GSC_out=err(L/2+1:end);

hold on
plot(GSC_out,'green');
hold on
plot(speech_DAS,'m');
legend('mic','DAS out','GSC out','speech DAS')

%% SNR
signal_power=var(GSC_out(VAD==1));
noise_power=var(GSC_out(VAD==0));    
SNR_out_GSC=10*log10((signal_power-noise_power)/noise_power);

soundsc(X(:,1),fs_RIR);                  
soundsc(DAS_out,fs_RIR);
soundsc(GSC_out,fs_RIR);    