%% phase2, preprocessing audio data
clear 
folder = '/Users/zahra/data/data';
eeg = '/eeg_train';
eeg_file1=dir(fullfile([folder,eeg]));
eeg_file1=eeg_file1(4:end);

EEG = struct([]);

for i=1:37

        %% step1, load data
        eeg_file2=dir(fullfile([folder,eeg,'/',eeg_file1(i).name,'/'],'*.mat'));
        name ={eeg_file2.name};
        num  = sscanf(sprintf('%s', name{:}),'trial-%d.mat');
        [~, index] = sort(num);
        eeg_file2 = eeg_file2(index);

        for j=1:numel(eeg_file2)
            load([eeg_file2(j).folder,'/',eeg_file2(j).name]);
            E = trial.RawData.EegData;
            E = double(E);
    
            %% step2, resampling
            E_reg = resample(E,20,128,'Dimension',1);
            E_cnn = resample(E,70,128,'Dimension',1);
    
            %% step3, bandpass filter
            % If x is a matrix, the function filters each column independently.
            [b1,a1] = butter(5,[1 9]/(20/2),'bandpass');
            [b2,a2] = butter(5,[1 32]/(70/2),'bandpass');
            E_reg = filter(b1,a1,E_reg);
            E_cnn = filter(b2,a2,E_cnn);


%             E_reg = bandpass(E_reg,[1 9],20);
%             E_cnn = bandpass(E_cnn,[1 32],70);
    
            EEG{i,1}.trial{j,1}=rmfield(trial,'RawData');
            EEG{i,1}.trial{j,1}.eegprepro.reg=E_reg;
            EEG{i,1}.trial{j,1}.eegprepro.cnn=E_cnn;
    
%             eeg_reg(:,:,i,j)=E_reg;
%             eeg_cnn(:,:,i,j)=E_cnn;

        end
        i
end