function [mic,noise,speech,SNR] = create_micsigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise)
    
    speech_num = length(speechfilename);
    noise_num = length(noisefilename);
    L = mic_length*fs_RIR;
    mic_targets=zeros(L,mic_num,speech_num);
    mic_noises =zeros(L,mic_num,noise_num);
    
    for i=1:speech_num
        [speech,fs] = audioread(speechfilename{i});
        % resampling
        if(fs ~= fs_RIR)
            speech = resample(speech,fs_RIR,fs);
        end
        mic_targets(:,:,i)=fftfilt(RIR_sources(:,:,i),speech(1:L));
    end
    
    for i=1:noise_num
        [noise,fs] = audioread(noisefilename{i});
        %resampling
        if(fs ~= fs_RIR)
            noise = resample(noise,fs_RIR,fs);
        end
        mic_noises(:,:,i)=fftfilt(RIR_noise(:,:,i),noise(1:L));
    end

    noise=[];
    speech = sum(mic_targets,3);
    VAD=abs(speech(:,1))>std(speech(:,1))*1e-3;% voice activity detection
    active = speech(VAD==1,1);
    speech_power = var(active);
    arbitrary_noise = wgn(size(speech,1),size(speech,2),speech_power*0.1,'linear');
    noise = arbitrary_noise + sum(mic_noises,3);
    mic = speech + noise;
    SNR = 10*log10(speech_power/var(noise(:,1)));
    save('mic.mat','mic','fs_RIR');
end




