clear 
load("env_data.mat")
load("EEG.mat")


for i=1:37
    eeg =[];
    env = [];
    for j=1:numel(EEG{i,1}.trial)
            SNR=EEG{i,1}.trial{j,1}.FileHeader.SNR;
            AttendedSpeaker=string(EEG{i,1}.trial{j,1}.AttendedTrack.SexOfSpeaker);
            UnattendedSpeaker=string(EEG{i,1}.trial{j,1}.UnattendedTrack.SexOfSpeaker);
            if SNR==100 && AttendedSpeaker=='M' && UnattendedSpeaker=='F'
                eeg = cat(1,eeg,EEG{i,1}.trial{j,1}.eegprepro.reg);
                env_name = {EEG{i,1}.trial{j,1}.AttendedTrack.Envelope};
                num  = sscanf(sprintf('%s', env_name{:}),'envelope_track_%d.wav');
                env = cat(1,env,env_reg(:,num));
            end
    end

    if ~isempty(eeg)
        eeg_train = eeg(1:5000,:);
        env_train = env(1:5000,:);
        eeg_test = eeg(5001:end,:);
        env_test = env(5001:end,:);

        %% train
        L=6;
        for k=1:size(eeg_train,1)-L+1
            m = eeg_train(k:k+L-1,:);
            m = m(:);
            A(k,:) = m;
        end

        d(:,i) = A\env_train(1:k);

        %% test
        L=6;
        for k=1:size(eeg_test,1)-L+1
            m = eeg_test(k:k+L-1,:);
            m = m(:);
            B(k,:) = m;
        end
        env_hat = B*d(:,i);
%         err = mean((abs(env_hat-env_test(1:k))).^2);

    end

end

