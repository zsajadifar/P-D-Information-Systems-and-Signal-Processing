function TDOA_est = TDOA_corr(mic)

    segment_length = 50000;
    segment_start = 1;
    segment = mic(segment_start:segment_start+segment_length,2);
    [r,lag] = xcorr(mic(:,1),segment);
    [~,indx] = max(abs(r));
    TDOA_est = (lag(indx));
%     figure,stem(lag,r)
%     xlabel('lag')
%     ylabel('cross correlation')
%     title('time domain cross correlation function')

%%
%%

%     seg_length = 3000;
%     test_length = 500;
% 
%     ref = mic(42000:42000+seg_length, 1);
%     target = mic(:, 2);
% 
%     TDOA_est = 0;
% 
%     % scan the second microphone signal
%     for start=42000:42000+test_length
%         [ccor, ~,  ~] = crosscorr(ref, target(start:start+length(ref)), 'NumLags', ceil(0.2 * length(ref)));
%         [ccor_max, ind] = max(ccor);
%         if(ccor_max > 0.6)
%             % terminate
%             TDOA_est = round((length(ccor) + 1)/2) - ind;
%             fprintf("TDOA: %d samples\n", TDOA_est);
%             break;
%         end
%     end
%     
%     figure,
%     crosscorr(ref, target(start:start+length(ref)), 'NumLags', ceil(0.2 * length(ref)));
end

