function vals = sdoVOR_Objective(v, Simulator, Exp,  Method)
% Compare model output with data
%
%    Inputs:
%       v - vector of parameters and/or states
%       Simulator - used to simulate the model
%       Exp - Experiment object
%       Method - 'SSE' for scalar output, 'Residuals' for vector of residuals

% Copyright 2014-2015 The MathWorks, Inc.

% Requirement setup
req = sdo.requirements.SignalTracking;
req.Type = '==';
req.Method = Method;

% If Residuals requested, keep on same scale as signals, for plotting
switch Method
	case 'Residuals'
		req.Normalize = 'off';
end

% Simulate the model
Exp = setEstimatedValues(Exp, v);   % use vector of parameters/states
Simulator = createSimulator(Exp,Simulator);
Simulator = sim(Simulator);

% Compare model output with data
SimLog = Simulator.LoggedData.logsout_diff_amp{1}.Values.Data(:,2);
vals.Voltage = mean(SimLog);