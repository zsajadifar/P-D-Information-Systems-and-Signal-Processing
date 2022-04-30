function [DOA_est,spectrogram]= MUSIC_wideband(mic)

    load("Computed_RIRs.mat");
    
    assert(fs_RIR == 44100);
    num_srcs = size(RIR_sources, 3);
    
    %% STFT
    L = 512;
    win = hamming(L);
    [spectrogram, ~, ~] = stft(mic, 'Window', win, 'OverlapLength',L/2, 'FFTLength', L, 'FrequencyRange', 'onesided');
    spectrogram = permute(spectrogram, [3, 2, 1]);
    
    v_sound = 340;
    theta = 0 : 0.5 : 180;
    theta = theta.*(pi/180);

    p_mean = ones(size(theta, 2), 1);
    
    bin_range = 0:L/2;
    freq_range = 2 .* bin_range ./ L * (fs_RIR / 2);
    omega_range = 2*pi*freq_range;
    
    d = m_pos(:,2)-m_pos(1,2);

    cutoff = ceil(L / 2);

    for freq_bin=2:cutoff
        [E, ~] = eig(cov(spectrogram(:,:,freq_bin)'));
        null_dim = size(E, 1) - num_srcs;
        E = E(:, 1:null_dim);
    
        %% define the steering matrix
        TDOA = d*cos(theta)/v_sound;
        G = exp(-1i * omega_range(freq_bin) * TDOA);
        p = 1./diag((G'*E)*E'*G);
        p_mean = p_mean.*p;
    end
    
    p_mean = p_mean.^(1/(cutoff-1));
    
    %% CFAR
    cfar = phased.CFARDetector();
    cfar.ThresholdOutputPort = true;
    cfar.ThresholdFactor = 'Custom';
    cfar.CustomThresholdFactor = 1.2;
    cfar.NumTrainingCells = 6;
    cfar.NumGuardCells = 10;
    [detected, ~] = cfar(abs(p_mean), 1:length(p_mean));
    detected = detected.*abs(p_mean);
    figure,plot(detected)
    [peaks, p_pos] = findpeaks(detected);
  
    figure,plot(real(p_mean))
    [peaks, p_pos] = findpeaks(real(p_mean));

    [~, index] = maxk(peaks, num_srcs);

    DOA_est = p_pos(index) * 0.5;
    
    save("DOA_est.mat", "DOA_est");

end