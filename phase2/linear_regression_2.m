clear 
load("env_data_butter.mat")
load("EEG_butter.mat")
warning off
L=6;
window_time=[1000,500,200,100,40,20];

for p=1:length(window_time)

    for i=1:15
        eeg =[];
        env = [];
        for j=1:numel(EEG{i,1}.trial)
                eeg = cat(1,eeg,EEG{i,1}.trial{j,1}.eegprepro.reg);
                env_attend_name = {EEG{i,1}.trial{j,1}.AttendedTrack.Envelope};
                env_unattend_name = {EEG{i,1}.trial{j,1}.UnattendedTrack.Envelope};
    
                num_attend(j)  = sscanf(sprintf('%s', env_attend_name{:}),'envelope_track_%d.wav');
                num_unattend(j) = sscanf(sprintf('%s', env_unattend_name{:}),'envelope_track_%d.wav');
    
                env = cat(1,env,env_reg(:,num_attend(j)));
        end
    
        for kk = 1:numel(EEG{i,1}.trial)%cross valication
    
            eeg_test = eeg((kk-1)*1000+1:(kk-1)*1000+1000,:);
            env_test = env((kk-1)*1000+1:(kk-1)*1000+1000,:);
            eeg_train = eeg;
            eeg_train((kk-1)*1000+1:(kk-1)*1000+1000,:)=[];
            env_train = env;
            env_train((kk-1)*1000+1:(kk-1)*1000+1000,:)=[];
            
    
            %% train
            M = lag_matrix(eeg_train,L);
            R = M'*M;
            r = M'*env_train(1:end-L+1); 
            d(:,i) = R\r;
    
            %% test
            tt = size(eeg_test,1)/window_time(p);
            c=[];
            for q=1:tt
                indx1=(q-1)*window_time(p)+1;
                indx2=(q-1)*window_time(p)+window_time(p);
                M_test= lag_matrix(eeg_test(indx1:indx2,:),L);       
                env_hat = M_test*d(:,i);
        
                a = corr(env_hat,env_reg(indx1:indx2-L+1,num_attend(kk)), 'type', 'Spearman');
                b = corr(env_hat,env_reg(indx1:indx2-L+1,num_unattend(kk)), 'type', 'Spearman');   
                c(q)= a> b;
            end
            C(i,kk,p)=sum(c)/numel(c);
        end
        i
    end
end

accuracy = sum(C,2)/size(C,2);

boxplot(squeeze(accuracy),(window_time/20))
xlabel('window length')
ylabel('accuracy')
title('linear regression accuracy, traind on 15 subjects, values averaged per subject')