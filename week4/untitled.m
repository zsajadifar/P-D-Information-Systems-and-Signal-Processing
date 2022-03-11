[mic_stft,freq,~] = stft(mic(:,1),fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'FrequencyRange','onesided');
for j=1:257
    x=mic_stft(:,j);  
    x_sym(:,j)= [flip(conj(x(2:end-1)));0;x(2:end-1);0];
end
x_time=istft(x_sym,fs_RIR,'Window',hann(L),'OverlapLength',overlap,'FFTLength',L,'Method','wola');

figure,plot(mic(:,1))
hold on,plot(x_time)
