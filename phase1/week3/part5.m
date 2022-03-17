path="D:\KU Leuven\Semester 2\P&D\week1\Head_mounted_IRs\Head_mounted_IRs";
filename =["\s30","\s60","\s90","\s-30","\s-60","\s-90"];
IRname =["\HMIR_L1.wav","\HMIR_L2.wav","\HMIR_R1.wav","\HMIR_R2.wav"];
RIR_sources=[];
for i=1:length(filename)
    for j=1:length(IRname)
        [RIR_sources(:,j,i),fs_RIR]=audioread(path+filename(i)+IRname(j));
    end
end

speechfilename(1:6) = "part1_track1_dry.wav";
noisefilename=[];
mic_length = 10; % desired length of microphone signals in Sec
mic_num = size(RIR_sources,2);
RIR_noise = [];
[mic,mic_noises,mic_targets] = create_micsigs(speechfilename,noisefilename,mic_length,mic_num,fs_RIR,RIR_sources,RIR_noise);
        
soundsc([mic_targets(:,1,1) mic_targets(:,3,1)], fs_RIR)       

d1=1.3/100;
d2=21.5/100;
