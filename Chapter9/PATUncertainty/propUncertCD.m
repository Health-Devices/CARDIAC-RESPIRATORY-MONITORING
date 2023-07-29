function [uncert, value]= propUncertCD(func,vals,uncerts,corrMat)
% propUncertCD() propagates uncertanity through the function 'func' using 
% a central difference approximation of the standard uncertainty propagation 
% equation:
%       https://en.wikipedia.org/wiki/Propagation_of_uncertainty#Non-linear_combinations
% Especially useful if the differentiation of 'func' is intractable or 
% symbolic differentiation is not desired/supported.
%
% INPUTS:
%   func        function handle of the function to propagate error through
%   vals        row vector containing estimated values of each variable in 'func'
%   uncerts     row vector containing the uncertainity in each variable
%   corrMat     (Optional) Pearson correlation coefficent matrix
%
%   'corrMat' is an optional parameter to be used when variables are not 
%   assumed to be independent and correlations are known.
%
%   Note that the order of elements in 'vals', 'uncerts' and 'corrMat' must correspond 
%   to the order of the variables in the '@(x,y,z)' part of the function handle.

% OUTPUTS
%   uncert      uncertainity in the esimate of the function output
%   value       estimate of the function output

% %EXAMPLE
% % Use the ideal gas law (P=rho*R*T) to find the uncertanity in the density 
% % of air given a measured pressure of 100 +/- 1 kPa and temperature of 
% % 300 +/- 3 Kelvin. No uncertanity in the gas law constant R (kJ/(kg*Kelvin)).
%
% P = 100; T = 300; uP = 1; uT = 3;      
% R = 0.287;
%       
% rho = @(press,temp)press/(R*temp);
% [rhoUncert, rhoEst] = propUncertCD(rho,[P T],[uP uT])
%
% % >> rhoUncert = 0.016425
% % >> rhoEst = 1.1614

% % For more examples see 'uncert_prop_examples.m'.
%Joe Klebba 3/21

valCells = num2cell(vals);
N=numel(valCells);
value = func(valCells{:});

% Compute the function's jacobian using Central difference approximation
jacob = zeros(1,N);
for i = 1:N
    if(uncerts(i) == 0)
        %Prevent divide by 0 errors. This derivative is inconsequential 
        %anyway, since the associated variance & covariance terms must be zero.
        jacob(i) = 0;
    else
    temp = valCells{i};
    valCells{i} = temp + uncerts(i);
    term1 = func(valCells{:});
    valCells{i} = temp - uncerts(i);
    jacob(i) = (term1 - func(valCells{:}))/(2*uncerts(i));
    valCells{i} = temp;
    end
end

if (~exist('corrMat', 'var')) 
    uncert = sqrt(sum((jacob.*uncerts).^2));
else
    %Create the covariance matrix
    covar = corrMat;
    for i = 1:N
        covar(i,:)=covar(i,:).*uncerts(i);
        covar(:,i)=covar(:,i).*uncerts(i);
    end
    uncert = sqrt(jacob*covar*transpose(jacob));
end

end
    