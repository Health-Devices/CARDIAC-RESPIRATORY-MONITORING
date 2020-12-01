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

% For Table 3 set simsc =0 and motion =0 in the first run and then motion
% =1 in the second run
% For Table 5, set simsc =1 and motion =0
%% Parameters
%clear all
%close all
coef(1)=0.65;
coef(2)=0.61;
delta_T=0.005;
fs=1/delta_T;
simsc=1;  % 1 Include Simscape model into simulation
          % 0 Run simulation in just Matlab - do not consider electronics
motion=1; % 1 Add noise and motion artifacts
          % 0 no noise and motion artifacts

%% Train
% mu=[130 80 0.09 0.027];
% sigma=[10^2 0.2*10*5 -0.6*10*0.02 -0.4*10*0.004; 0.2*10*5 5^2 -0.25*5*0.02 -0.35*5*0.004; -0.6*10*0.02 -0.25*5*0.02 0.02^2 0.75*0.02*0.004; -0.4*10*0.004 -0.35*5*0.004 0.75*0.02*0.004 0.004^2];
% rng(123)  % For reproducibility
% R = mvnrnd(mu,sigma,100);
% for i=1:100
%
% [P, Pa]=model1 (R(i,3),R(i,4),R(i,1),R(i,2), fs, 0);
% [cp,omw] = extract_omw(P, fs);
% % motion artifacts
%
% [BP, MAP, omwe, peak_ind] = bp_est(cp, omw, coef, fs,0);
% SBP_est_fixed(i)=BP(1);
% DBP_est_fixed(i)=BP(2);
% [alpha(i), beta(i), gamma(i), c_sbp, c_dbp]=param_bp(cp, MAP, omwe, peak_ind, R(i,1),R(i,2));
% x(i,:)=[alpha(i), beta(i), gamma(i), MAP, R(i,3),R(i,4),R(i,1),R(i,2), mean(Pa),c_sbp, c_dbp];
% BP = bp_est_max_slope(cp, omw, coef, fs, 0)
% SBP_est_slope(i)=BP(1);
% DBP_est_slope(i)=BP(2);
% end
% lm_db = fitlm([x(:,1) x(:,2) x(:,3) x(:,4)],x(:,11));
% lm_sb = fitlm([x(:,1) x(:,3) x(:,4)],x(:,10));
% coef(1)= mean(x(:,10));
% coef(2)= mean(x(:,10));
% bias_SP_slope=mean((SBP_est_slope-R(:,1)'));
% bias_DP_slope=mean((DBP_est_slope-R(:,2)'));
% bias_SP_fixed=mean((SBP_est_fixed-R(:,1)'));
% bias_DP_fixed=mean((DBP_est_fixed-R(:,2)'));
% save('lm_db.mat','lm_db')
% save('lm_sb.mat','lm_sb')

%% Generate values for SBP, DBP, a and b
load('lm_db.mat');
load('lm_sb.mat');
% Test
mu=[140 80 0.09 0.027];
sigma=[10^2 0.2*10*5 -0.6*10*0.02 -0.6*10*0.004; 0.2*10*5 5^2 -0.3*5*0.02 -0.3*5*0.004; -0.6*10*0.02 -0.3*5*0.02 0.02^2 0.75*0.02*0.004; -0.6*10*0.004 -0.3*5*0.004 0.75*0.02*0.004 0.004^2];
rng(125)  % For reproducibility
R = mvnrnd(mu,sigma,100);

%%
% run simulation 100 times
t=-500*delta_T:delta_T:500*delta_T; eta=1.5; motion_signal=5*sin(pi*t/eta)./(pi*t); motion_signal(501)=0.5*(motion_signal(500)+motion_signal(502));
for i=1:100
    
    [P, Pa]=model1 (R(i,3),R(i,4),R(i,1),R(i,2), fs, 0);
    % motion artifacts
    if motion==1
        z=zeros(1,length(P));
        start=1500+7500*rand(1);  % add motion artifact at the random place on the pressure signal
        z(start:start+length(motion_signal)-1)=motion_signal;
        P=P+z+0.4*randn(1,length(P));
    end
    %P=P+0.4*randn(1,length(P));
    [cp,omw] = extract_omw(P, fs);
    % Include Simscape simulation
    if simsc==1
        Psim(:,1)=0:delta_T:55;
        Psim(:,2)=3.2520e-05*P; % Max input strain that will result in deltaR=0.2484 kOhm for the bridge in https://omronfs.omron.com/en_US/ecb/products/pdf/en-2smpp-02.pdf
        % is 0.0081. Max pressure of 250mmH should correspond to
        % 0.0081. Therefore, multiply pressure with 0.0081/250
        simOut = sim('BloodPressure_ADC1', 'CaptureErrors', 'on');
        
        cp_adc=resample(simOut.Cpsim.Data,1,5)';
        cp_rescaled=0.3038*(cp_adc-493)+150; %0.2291*(cp_adc-668)+150;
        i1=1:length(P);
        f=fit(i1',cp_rescaled','poly3');
        cp=f(i1);
        
        omw_adc=resample(simOut.Omwsim.Data,1,5)';
        cutoff = 10;
        omw_scaled=(mean(omw_adc(4000:8000))-omw_adc)/200;
        omw = lowpass(omw_scaled, cutoff, fs);
    end
    % MAA algorithm with fixed coefficients
    [BP, MAP, omwe, peak_ind] = bp_est(cp, omw, coef, fs,0);
    SBP_est_fixed(i)=BP(1);
    DBP_est_fixed(i)=BP(2);
    
    % MAA algorithm with correction of coefficients of SBP and DBP
    [alpha(i), beta(i), gamma(i), c_sbp, c_dbp]=param_bp(cp, MAP, omwe, peak_ind, R(i,1),R(i,2));
    x_test(i,:)=[alpha(i), beta(i), gamma(i), MAP, R(i,3),R(i,4),R(i,1),R(i,2), mean(Pa),c_sbp, c_dbp];
    c_sbp = predict(lm_sb,[x_test(i,1) x_test(i,3) x_test(i,4)]);
    c_dbp = predict(lm_db,[x_test(i,1) x_test(i,2) x_test(i,3) x_test(i,4)]);
    [BP, MAP, omwe, peak_ind] = bp_est(cp, omw, [c_sbp, c_dbp], fs,0);
    SBP_est(i)=BP(1);
    DBP_est(i)=BP(2);
    
    % Max slope algorithms
    BP = bp_est_max_slope(cp, omw, coef, fs, 0)
    SBP_est_slope(i)=BP(1);
    DBP_est_slope(i)=BP(2);
end
% Compute errors for all 3 algorithms
mean(abs(SBP_est_fixed-R(:,1)'))
std(SBP_est_fixed-R(:,1)')
mean(abs(DBP_est_fixed-R(:,2)'))
std(DBP_est_fixed-R(:,2)')

mean(abs(SBP_est-R(:,1)'))
std(SBP_est-R(:,1)')
mean(abs(DBP_est-R(:,2)'))
std(DBP_est-R(:,2)')

mean(abs(SBP_est_slope-R(:,1)'))
std(SBP_est_slope-R(:,1)')
mean(abs(DBP_est_slope-R(:,2)'))
std(DBP_est_slope-R(:,2)')
test=1;

