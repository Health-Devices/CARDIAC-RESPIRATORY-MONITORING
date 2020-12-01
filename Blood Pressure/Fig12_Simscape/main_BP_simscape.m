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
% PERVASIVE CARDIAC AND RESPIRATORY MONITORING DEVICES Chapter 4

%clear all
%close all
coef(1)=0.65;
coef(2)=0.6;
delta_T=0.005;
fs=1/delta_T;
SBP=120;
DBP=80;

[P, Pa]=model1_simscape (SBP,DBP, fs);
Psim(:,1)=0:delta_T:55;
Psim(:,2)=3.2520e-05*P; % Max input strain that will result in deltaR=0.2484 kOhm for the bridge in https://omronfs.omron.com/en_US/ecb/products/pdf/en-2smpp-02.pdf
             % is 0.0081. Max pressure of 250mmH should correspond to
             % 0.0081. Therefore, multiply pressure with 0.0081/250
simOut = sim('BloodPressure_ADC1', 'CaptureErrors', 'on');

% Rescale data
cp_adc=resample(simOut.Cpsim.Data,1,5)';  
cp_rescaled=0.3038*(cp_adc-493)+150; %0.2291*(cp_adc-668)+150;
i=1:length(P)
f=fit(i',cp_rescaled','poly3');
cp=f(i);

omw_adc=resample(simOut.Omwsim.Data,1,5)'; 
cutoff = 10;
omw_scaled=(mean(omw_adc)-omw_adc)/1000;
omw = lowpass(omw_scaled, cutoff, fs);

BP = bp_est_simscape(cp, omw, coef, fs)