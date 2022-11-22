function [br_rate] = br_rate_est_freq(resp,fs, method_num, PLOTTING)
% method_num = 1 Welch
% method_num = 2 FFT
if method_num==1
    window = blackman(length(resp));
    [pxx,fxx] = pwelch(resp,window,170,2^16,fs,'power'); %pwelch(filteredPersonBinSignal,window,[],2^16,fs);
    [pmax,pmaxIndex] = max(pxx);
    br_rate = fxx(pmaxIndex)*60;
elseif method_num==2
    FFT_R=abs(fft(hamming(length(resp)).*resp,2^16)); % change number of fft freq. points
    [hh index]=max(FFT_R);
    br_rate=index*fs/2^16*60;
    if PLOTTING ==1
        k=(fs/2^16)*(0:(2^16-1));
        plot(k,FFT_R/max(FFT_R))
        xlabel('Frequency (Hz)');grid;
        ylabel('Normalized magnitude');xlim([0 2]);title('DFT of the breathing signal');
    end
end

