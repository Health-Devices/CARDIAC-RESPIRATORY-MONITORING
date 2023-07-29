function noise=additive_noise_model(N, fs, varargin)
% This  function models noise
% N is th enumber of samples. It is expected to be at least 10-20 pulses.
% fs is th esampling frequncy
% varargin are different types of noise with its parameters that one can
%   select

% 'Gaussian', [mean std], Example: noise_model(5, 'Gaussian', [0 0.1]) 
% 'NarrowBand', [ampl freq], Example: noise_model(500, 250, 'NarrowBand', [1 60]) 
% '60 Hz', [ampl], Example: noise_model(500, 250, '60 Hz', [1])
% 'Impulse', [ampl, eta], Example: noise_model(5000, 250, 'Impulse', [5,
%       1.5])  - generates about 3 sec long motion artifacts. The lenght of
%       the artifacts can be adjusted by eta. The position of the artifact
%       in the signal is random.
% 'BandLimited', [ampl freql freqh], Example: noise_model(500, 250,
%       'BandLimited', [0.5, 0.05, 10])  - generates the signal of
%       amplitude 0.5 in the freq range of 0.05Hz to 10 Hz.
% 'Lowpass', [ampl freqh], Example: noise_model(500, 250,
%       'Lowpass', [0.5, 10])  - generates the signal of
%       amplitude 0.5 in the freq range of 0.05Hz to 10 Hz.
% 'BandLimited Impulse', [ampl freql freqh], Example: noise_model(500, 250,
%       'BandLimited Impulse', [0.5, 0.05, 10])  - generates the signal of
%       amplitude 0.5 in the freq range of 0.05Hz to 10 Hz.
% 'Plotting'

noise=zeros(1,N);
vaIdx=1;
T=1/fs;
plotting=0;
while vaIdx <= length(varargin)
    currArg = varargin{vaIdx};
    notLastArg = vaIdx~=length(varargin);
    switch(currArg)
        case {'Gaussian'}        
            if notLastArg && ~ischar(varargin{vaIdx+1})
                x=varargin{vaIdx+1};
            end
            noise=noise+x(1)*ones(1,N)+x(2)*randn(1,N);
            vaIdx=vaIdx+2;
        case {'NarrowBand'}        
            if notLastArg && ~ischar(varargin{vaIdx+1})
                x=varargin{vaIdx+1};
                ampl=x(1);
                f=x(2);
            end
            i=1:N;
            noise=noise+ampl*sin(2*pi*i*f/fs);
            vaIdx=vaIdx+2;   
        case {'60 Hz'}        
            if notLastArg && ~ischar(varargin{vaIdx+1})
                x=varargin{vaIdx+1};
                ampl=x;
                f=60;
            end
            i=1:N;
            noise=noise+ampl*sin(2*pi*i*f/fs);
            vaIdx=vaIdx+2;  
        case {'Impulse'}        
            if notLastArg && ~ischar(varargin{vaIdx+1})
                x=varargin{vaIdx+1};
                ampl=x(1);
                eta=x(2);
            end 
            range=2.5*fs; 
            t1=-range*T:T:range*T;
            %eta=1.5;
            motion_signal=ampl*sin(pi*t1/eta)./(pi*t1);
            motion_signal(range+1)=0.5*(motion_signal(range)+motion_signal(range+2));
            %z=zeros(1,length(P));
            start=floor(rand()*N);
            if start+length(motion_signal)-1>N
                end_index=N;
                noise(start:end_index)=noise(start:end_index)+motion_signal(1:N+1-start);
            else 
                end_index=start+length(motion_signal)-1;
                noise(start:end_index)=noise(start:end_index)+motion_signal;
            end
            vaIdx=vaIdx+2;          
        case {'BandLimited'}        
            if notLastArg && ~ischar(varargin{vaIdx+1})
                x=varargin{vaIdx+1};
                ampl=x(1);
                f_l=x(2);
                f_h=x(3);
            end
            noise=noise+ampl*bandpass(randn(1,N),[f_l f_h],fs);
            vaIdx=vaIdx+2;  
        case {'Lowpass'}        
            if notLastArg && ~ischar(varargin{vaIdx+1})
                x=varargin{vaIdx+1};
                ampl=x(1);
                f_h=x(2);
            end
            noise=noise+ampl*lowpass(randn(1,N),f_h,fs, 'Steepness', 0.95);
            vaIdx=vaIdx+2;              
        case {'BandLimited Impulse'}    
        % generates the burst of random length between a and b seconds at
        % the random place in the signal.
          beta = -2; %set beta value
        %send this to the colored noise generator:       
        
            if notLastArg && ~ischar(varargin{vaIdx+1})
                x=varargin{vaIdx+1};
                ampl=x(1);
                f_l=x(2);
                f_h=x(3);
            end
            a=3; % minimum of the burst in seconds
            b=10; % maximum of the burst in seconds
            duration= a + (b-a).*rand;  % variable length signal from 3 sec to 10 sec
          
            %impulse_sig= ampl*bandpass(randn(1,floor(fs*duration)),[f_l
            %f_h],fs);
            wave = (color_noise_generator(beta,floor(fs*duration)))';
            impulse_sig= ampl*bandpass(wave,[f_l f_h],fs);
            %z=zeros(1,length(P));
            start=floor(rand()*N);
            if start+length(impulse_sig)-1>N
                end_index=N;
                noise(start:end_index)=noise(start:end_index)+impulse_sig(1:N+1-start);
            else 
                end_index=start+length(impulse_sig)-1;
                noise(start:end_index)=noise(start:end_index)+impulse_sig;
            end
            vaIdx=vaIdx+2;    
        case {'Plotting'}
            plotting =1;
            vaIdx=vaIdx+1;
        otherwise
            if ischar(currArg)
                disp("noise_model: The string '"+currArg+"' in the function parameters was not recognized as a valid option.")
            end
            vaIdx=vaIdx+1;
    end
end
if plotting ==1
    figure
    t = (0:N-1)*T;        % Time vector
    plot(t,noise)
    title('Noise(t)')
    xlabel('Time (s)')
    ylabel('Amplitude (V)')
    
    figure
    Y = fft(noise);
    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:(N/2))/N;
    plot(f,P1) 
    title('Single-Sided Amplitude Spectrum of noise(t)')
    xlabel('f (Hz)')
    ylabel('|P(f)|')
    
    figure
    stft(noise,fs,'Window',kaiser(256,5),'OverlapLength',220,'FFTLength',512, 'FrequencyRange',"onesided");
end

%%
% This fuction is from "Oscillator and Signal Generator"
% version 1.8.0.0 (15.2 KB) by W. Owen Brimijoin
% A simple command-line function for generating standard waveforms, click trains and noise bursts.
% https://www.mathworks.com/matlabcentral/fileexchange/37376-oscillator-and-signal-generator?s_tid=srchtitle
% 

function wave = color_noise_generator(beta,num_samples)
%this handles the various colors of noise like pink, brown, blue, etc
%create frequency vector folded at center:
freqs = [linspace(0,.5,floor(num_samples/2)),fliplr(linspace(0,.5,ceil(num_samples/2)))]';
freqs = (freqs.^2).^(beta/2);
freqs(freqs==inf) = 0; %to prevent inf errors
phase_vals = rand(num_samples,1);
%now apply an inverse fft:
wave = real(ifft(sqrt(freqs).*(cos(2*pi*phase_vals)+1i*sin(2*pi*phase_vals))));
wave = wave./max(abs(wave)); %normalize to +/- 1.
