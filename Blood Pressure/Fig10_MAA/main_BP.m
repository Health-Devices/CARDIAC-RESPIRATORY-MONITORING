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
% Plots for figure 5, 6 and 7

%clear all
close all
coef(1)=0.65;
coef(2)=0.6; % different coefficient is used in the chapter
delta_T=0.005;
fs=1/delta_T;
SBP=120;
DBP=80;
%% MAA algorithms Fig 10
% Stiff artery
a=0.076;
b=0.021;
[P, Pa]=model1 (a,b,SBP,DBP, fs, 0);
[cp,omw] = extract_omw(P, fs);
BP = bp_est_MAA(cp, omw, coef, fs,1)

% Normal artery
a=0.11;
b=0.03;
[P, Pa]=model1 (a,b,SBP,DBP, fs, 0);
[cp,omw] = extract_omw(P, fs);
BP = bp_est_MAA(cp, omw, coef, fs,1)

%% Slope based algorithms
% Normal artery
BP = bp_est_max_slope(cp, omw, fs,1)

%% MAA algorithms Fig 14 - motion artifact
SBP=140;
DBP=69;
a=0.092;
b=0.028;
rng('default')
[P, Pa]=model1 (a,b,SBP,DBP, fs, 0);
if motion==1
    z=zeros(1,length(P));
    start=1500+7500*rand(1);
    z(start:start+length(motion_signal)-1)=motion_signal;
    P=P+z+0.4*randn(1,length(P));
end
[cp,omw] = extract_omw(P, fs);
BP = bp_est_MAA(cp, omw, coef, fs,1) % Set Plot_envelope_smoothing==1