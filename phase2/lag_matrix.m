function y = lag_matrix(x,lag)

% x is eeg matrix: t*64
y=[];
for i=1:size(x,2)
    temp = x(:,i);
    for j=1:lag
        temp_laged(:,j)=delayseq(temp,-(j-1));
    end
    y = cat(2,y,temp_laged);
end
y = y(1:end-lag+1,:);

end