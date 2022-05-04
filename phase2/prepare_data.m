clear 
load("env_test_newsub.mat")
load("EEG_test_newsub.mat")
k=1;
for i=1:3
    for j=1:numel(EEG{i,1}.trial)
        eeg(:,:,k) = EEG{i,1}.trial{j,1}.eegprepro.cnn;
        env_attend_name = {EEG{i,1}.trial{j,1}.track1.Envelope};
        env_unattend_name = {EEG{i,1}.trial{j,1}.track2.Envelope};

        num_attend = sscanf(sprintf('%s', env_attend_name{:}),'envelope_track_%d.wav');
        num_unattend = sscanf(sprintf('%s', env_unattend_name{:}),'envelope_track_%d.wav');

        env1(:,1,k) = env_cnn(:,num_attend);
        env2(:,1,k) = env_cnn(:,num_unattend);

        k=k+1;

    end
end

x=[];
y=[];
z=[];
window_time = 700;
for tt=1:floor(size(eeg,1)/window_time)
    x=cat(3,x,eeg((tt-1)*window_time+1:(tt-1)*window_time+window_time,:,:));
    y=cat(3,y,env1((tt-1)*window_time+1:(tt-1)*window_time+window_time,:,:));
    z=cat(3,z,env2((tt-1)*window_time+1:(tt-1)*window_time+window_time,:,:));
end

eeg=[];
env1=[];
env2=[];

eeg=x;
env1=y;
env2=z;

% rng('default')
k=size(eeg,3);
indx = randsample(k,0.2*k);
%indx = 5:5:k;
% indx1 = 9:10:k;
% indx2 = 10:10:k;
% indx = sort([indx1,indx2]);


eeg_valid=eeg(:,:,indx);
env1_valid=env1(:,:,indx);
env2_valid=env2(:,:,indx);

eeg_train=eeg;
env1_train=env1;
env2_train=env2;

eeg_train(:,:,indx)=[];
env1_train(:,:,indx)=[];
env2_train(:,:,indx)=[];

save('eeg_valid.mat',"eeg_valid","-v7.3")
save('env1_valid.mat',"env1_valid","-v7.3")
save('env2_valid.mat',"env2_valid","-v7.3")
save('eeg_train.mat',"eeg_train","-v7.3")
save('env1_train.mat',"env1_train","-v7.3")
save('env2_train.mat',"env2_train","-v7.3")

