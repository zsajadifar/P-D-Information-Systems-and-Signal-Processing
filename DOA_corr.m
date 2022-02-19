function [DOA_est,TDOA_est] = DOA_corr(mic_targets,m_pos,fs_RIR)
    
    target_num = size(mic_targets,3);
    d = abs(m_pos(1,2) - m_pos(2,2));
    c = 340; % speed of sound
    TDOA_est=zeros(1,target_num);
    for i=1:target_num
        TDOA_est(i) = TDOA_corr(mic_targets(:,:,i));
    end
     
    x_delay = c * (TDOA_est/fs_RIR);
    DOA_rad = acos(x_delay/d);
    DOA_deg = DOA_rad * 180/pi;
    DOA_est = DOA_deg;
    save('DOA_est.mat','DOA_est')
end
