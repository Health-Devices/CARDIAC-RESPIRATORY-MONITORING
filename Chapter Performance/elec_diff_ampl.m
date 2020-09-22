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

% Code to plot simulation results from DDifferential amplifier
% Running model for the first time
model_name = 'Diff_ampl';
open_system(model_name);
sim(model_name)
plot(logsout_diff_amp{1}.Values.Time, logsout_diff_amp{1}.Values.Data(:,1))
% Making resistor labels visible
SETTING_PARAM=0;
if SETTING_PARAM
    blockNames = find_system( model_name , 'Type' , 'Block' );
    for k = 1 : length( blockNames )
        set_param( blockNames{k} , 'ShowName' , 'on' );
    end;
    set_param('Diff_ampl/ERef Diff Amp1' , 'ShowName' , 'off' );
    set_param('Diff_ampl/ERef Diff Amp' , 'ShowName' , 'off' );
end

% Get simulation results
% Max Tolerance
set_param('Diff_ampl/R1','enable_R_tol','3');
set_param('Diff_ampl/R2','enable_R_tol','2');
set_param('Diff_ampl/R3','enable_R_tol','3');
set_param('Diff_ampl/R4','enable_R_tol','2');
sim('Diff_ampl');
simlog_prSensorMaxTol = logsout_diff_amp.get('Pr_Signal');

% Min Tolerance
set_param('Diff_ampl/R1','enable_R_tol','2');
set_param('Diff_ampl/R2','enable_R_tol','3');
set_param('Diff_ampl/R3','enable_R_tol','2');
set_param('Diff_ampl/R4','enable_R_tol','3');
sim('Diff_ampl');
simlog_prSensorMinTol = logsout_diff_amp.get('Pr_Signal');

RANDOM_TOLERANCE=0
if RANDOM_TOLERANCE
    for i=1:1000
        set_param('Diff_ampl/R1','enable_R_tol','1'); % random tolerance
        set_param('Diff_ampl/R2','enable_R_tol','1');
        set_param('Diff_ampl/R3','enable_R_tol','1');
        set_param('Diff_ampl/R4','enable_R_tol','1');
        set_param('Diff_ampl/R1','tol_distribution','1'); %1 is uniform, 2 is Gaussian
        set_param('Diff_ampl/R2','tol_distribution','1');
        set_param('Diff_ampl/R3','tol_distribution','1');
        set_param('Diff_ampl/R4','tol_distribution','1');
        sim('Diff_ampl');
        simlog_param=logsout_diff_amp.get('Pr_Signal');
        param_mean(i)=mean(simlog_param.Values.Data(10:end,2));
    end
    figure, hist(param_mean)
    ylabel('Number of times the voltage appears in the bin')
    xlabel('Voltage(V)');
end
% Nominal Value
set_param('Diff_ampl/R1','enable_R_tol','0');
set_param('Diff_ampl/R2','enable_R_tol','0');
set_param('Diff_ampl/R3','enable_R_tol','0');
set_param('Diff_ampl/R4','enable_R_tol','0');

% Plot results
plot(simlog_prSensorMinTol.Values.Time, simlog_prSensorMinTol.Values.Data(:,1), 'k','LineWidth', 1)
hold on
plot(simlog_prSensorMaxTol.Values.Time, simlog_prSensorMaxTol.Values.Data(:,2), 'LineWidth', 1)
plot(simlog_prSensorMinTol.Values.Time, simlog_prSensorMinTol.Values.Data(:,2), 'LineWidth', 1)
hold off
grid on
title('Differential amplifier')
ylabel('Voltage (V)')
legend({'Differential Input', 'Max Tolerance','Min Tolerance'},'Location','Best');
xlabel('Time (s)');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sensitivity analysis

R1 = sdo.getParameterFromModel(model_name, 'R1');
R1.Minimum=R1.Value*1.01;
R1.Maximum=R1.Value*0.99;

R2 = sdo.getParameterFromModel(model_name, 'R2');
R2.Minimum=R2.Value*1.01;
R2.Maximum=R2.Value*0.99;

R3 = sdo.getParameterFromModel(model_name, 'R3');
R3.Minimum=R3.Value*1.01;
R3.Maximum=R3.Value*0.99;

R4 = sdo.getParameterFromModel(model_name, 'R4');
R4.Minimum=R4.Value*1.01;
R4.Maximum=R4.Value*0.99;
%%
v=[R1; R2; R3; R4];
ps = sdo.ParameterSpace(v);

%%
% Generate 100 samples from the parameter space.
rng default;   % for reproducibility
x  = sdo.sample(ps, 100); % uniform sampling
%sdo.scatterPlot(x);

%%
% For sensitivity analysis, it is simpler to use a scalar objective, so we
% will specify the sum of squared errors, "SSE":
% We are not really doing any optimization - just obtaining the output
% value.
estFcn = @(v) sdoVOR_Objective(v, Simulator, Exp, 'SSE');
y = sdo.evaluate(estFcn, ps, x);
sdo.scatterPlot(x,y)

