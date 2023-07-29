function [uncert, value] = propUncertSym(func,varNames,vals,uncerts,corrMat)
% propUncertSym() propagates uncertanity through the function 'func' using 
% the standard uncertainty propagation equation:
%       https://en.wikipedia.org/wiki/Propagation_of_uncertainty#Non-linear_combinations
% where the derivatives are calculated symbolically.

% INPUTS:
%   func        function handle of the function to propagate error through
%   varNames    row vector containing the names of the symbolic variables
%   vals        row vector containing estimated values of each variable in 'func'
%   uncerts     row vector containing the uncertainity in each each variable
%   corrMat     (Optional) Pearson correlation coefficent matrix
%
%   'corrMat' is an optional parameter to be used when variables are not 
%   assumed to be independent and correlations are known.
%
%   Note that the order of elements in 'varNames', 'vals', 'uncerts' and 'corrMat' must 
%   correspond to the order of the variables in the '@(x,y,z)' part of the function handle.

% OUTPUTS
%   uncert      uncertainity in the esimate of the function output
%   value       estimate of the function output

% %EXAMPLE
% % Use the ideal gas law (rho = P/RT) to find the uncertanity in the density 
% % of air given a measured pressure of 100 +/- 1 kPa and temperature of 
% % 300 +/- 3 Kelvin. No uncertanity in the gas law constant R (kJ/(kg*Kelvin)).
%
% P = 100; T = 300; R = 0.287; 
% uP = 1; uT = 3;      
% 
% syms Press Temp
% rho = Press/(R*Temp);
% [rhoUncert, rhoEst] = propUncertSym(rho,[Press Temp],[P T],[uP uT])
%
% % >> rhoUncert = 0.016425
% % >> rhoEst = 1.1614

% % For more examples see 'uncert_prop_examples.m'.
% Joe Klebba, 3/2021

value = double(subs(func,varNames,vpa(vals)));
N=numel(varNames);
jacob= jacobian(func,varNames);
jacob = double(subs(jacob,varNames,vpa(vals)));
uncert = sqrt(sum((jacob.*uncerts).^2));

%Handle correlations if neccesary
if (exist('corrMat', 'var')) 
    covar = corrMat;
    for i = 1:N
        covar(i,:)=covar(i,:).*uncerts(i);
        covar(:,i)=covar(:,i).*uncerts(i);
    end
    uncert = sqrt(jacob*covar*transpose(jacob));
end

end


% %--------------------A Minor Warning-----------------------
% % Passing a decimal to the symbolic function like in the example sometimes 
% % results in very small numerical errors, particularly in Octave. For 
% % most use cases this can safely be ignored.
% %
% % If greater pecision is desired then using vpa(val,d) on floating point 
% % values that are passed to the function should ensure accuracy to 'd' 
% % digits. Vpa's default value of 'd' is 32.
% % 
% % For example, assume temperature is known to be exactly 300.42 Kelvin.
% 
% P = 100;   uP = 1;
% T = 300.42;
%
% syms Press
% rho = Press/(vpa(0.287)*vpa(T));
% [rhoUncert, rhoEst] = PropUncertSym(rho,[Press],[P],[uP])
%
% % Notice vpa() is applied to both decimals ('0.287' and 'T') in the definition 
% % of the function 'rho'. This will reduce the potential numerical error.
