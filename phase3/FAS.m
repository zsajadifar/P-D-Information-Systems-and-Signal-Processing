function [w_FAS,B] = FAS(RIR)

%% normalized DFT of target IR
L=1024;
a = fft(RIR,L);
h = a ./ a(:,1);

%% filter and sum
w_FAS = zeros(size(h, 1)/2, size(h, 2));
for freq=1:L/2
    w_FAS(freq, :) = h(freq, :) ./ (h(freq, :) * h(freq, :)');
    B (:,:,freq)= null(h(freq,:));
end

end
