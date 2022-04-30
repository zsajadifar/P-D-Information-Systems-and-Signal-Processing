function [fas_out,gsc_speech]=FD_GSC(mic, w_FAS,B)

%% zeropad mic signal
fs_RIR = 44100;
num_mics = size(mic, 2);
zeropad = 100;
mic = [zeros(zeropad,num_mics);mic;zeros(zeropad,num_mics)];

%% STFT
L = 1024;
win = hamming(L);
[mic_stft, ~, ~] = stft(mic, 'Window', win, 'OverlapLength',L/2, 'FFTLength', L, 'FrequencyRange', 'onesided');
mic_stft = permute(mic_stft, [3, 2, 1]);

%% Filtering and NLMS
mu = 0.01;
alpha = 10^-5;

err = zeros(L, size(mic_stft, 2));
d = zeros(L, size(mic_stft, 2));

for t=1:size(mic_stft,2)%time
    W = zeros(size(mic_stft,2),num_mics-1);
    for freq=1:L/2%freq
        u = mic_stft(:,t,freq);
        d(freq,t) = conj(w_FAS(freq,:))*u;

        X=B(:,:,freq)'*u;
        X_norm = X'*X;
        temp(freq,t)= conj(W(freq,:))*X;
        err(freq,t)=d(freq,t)-temp(freq,t);
        W(freq+1,:) = W(freq,:).' + (mu/((X_norm^2)+alpha))*X*conj(err(freq,t));

    end
end

err(513:end-1, :) = conj(flipud(err(1:511, :)));
err(512, :) = 0;
err(end, :) = 0;
err = flipud(err);



d(513:end-1, :) = conj(flipud(d(1:511, :)));
d(512, :) = 0;
d(end, :) = 0;
d   = flipud(d);

fas_out = istft(d, fs_RIR, 'Window', win, 'OverlapLength',L/2, 'FFTLength', L);
gsc_speech = istft(err, fs_RIR, 'Window', win, 'OverlapLength',L/2, 'FFTLength', L);

fas_out(1:zeropad)=[];
fas_out(end-zeropad:end)=[];
gsc_speech(1:zeropad)=[];
gsc_speech(end-zeropad:end)=[];
