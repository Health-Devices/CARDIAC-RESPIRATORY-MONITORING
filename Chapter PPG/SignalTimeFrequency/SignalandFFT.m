%%    Copyright (C) <2020>  <Miodrag Bolic>
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details <https://www.gnu.org/licenses/>.

%% This code was developed by Miodrag Bolic for the book 
% PERVASIVE CARDIAC AND RESPIRATORY MONITORING DEVICES
% Dependencies include files rescale1.m, plethy.mat and ppg2.slx


% Generate Data
clear all
load('plethy.mat');
a1=rescale1([a;a;a;a;a;a;a;a;a;a]);
FS=77;
T=1/77;
t=T:T:length(a1)*T;
figure
plot(t,a1)
title('PPG signal')
xlabel('Time (s)')
ylabel('Normalized PPG amplitude')
xlim([0 2.1])
ylim([-0.1 1.1])
a3=line([0.3766 1.3766],[1 1],'Color','magenta','LineStyle','-.')
a2=line([1 2],[0 0],'Color','red','LineStyle','--')
%text(0.4,0.945,'\leftarrow DC component')
text(0.65,0.95,{'\uparrow Peak interval'})
text(1.3,0.05,'\downarrow Onset interval')

NyquistF = FS/2;
FResBPM = 0.5; %resolution (bpm) of bins in power spectrum used to determine PR and SNR
N = (60*2*NyquistF)/FResBPM; %number of bins in power spectrum

%% Periodogram
[Pxx,F] = periodogram(a1,hamming(length(a1)),N,FS);
figure
plot(F,pow2db(Pxx))
title('Power Spectrum')
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
xlim([0 16])
ylimreg=ylim;
