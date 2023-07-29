function CCC = f_CCC(data,alpha)
% Computes Lin's Concordance Correlation  Coefficients CCC,
% Based on the development by Lin1989 and corrections in 2000, and presentation 
% by McBride2005
% Data is returned as presented in the form returned by the CCC function in the 
% R package 'DescTools' 

% Lawrence, I., and Kuei Lin. "A concordance correlation coefficient to evaluate 
% reproducibility." Biometrics (1989): 255-268.
% McBride, G. B. "A proposal for strength-of-agreement criteria for Lin痴 
% concordance correlation coefficient." NIWA Client Report: HAM2005-062 (2005).

% Syntax: 
% Input: 
%   data is an k by m matrix of k targets by m raters
%   alpha is the alpha level for significance using the confidence intevals
%   rho0 is the hypothesised value of ICC (set to zero if unsure)
% Output: 
%   CCC
%   Scale and location shifts
%   Bias Correction Factor (gauge of accuracy)
%   Pearson's Correlation Coeff (gauge of precision)
%   Confidence limits at the significance given in alpha

% Example: (data from McGraw Table 6, modified to have shifted scale value)
% data = [103,109;% 82,65;116,106;102,102;99,105;98,100;104,107;
%           62,85;97,101;107,110];
% alpha     = 0.05;
% CCC = C_ICC(data,alpha);

% Verification from R:
%        est    lwr.ci    upr.ci
% 1 0.729616 0.2406287 0.9232147
% 
% $s.shift
% [1] 0.9256678     (=1/1.0803)
% 
% $l.shift
% [1] 0.1460437     (sign flipped)
% 
% $C.b
% [1] 0.9865349
% 
% $blalt
%     mean delta
% 1  106.0    -6
% 2   73.5    17
% 3  111.0    10
% 4  102.0     0
% 5  102.0    -6
% 6   99.0    -2
% 7  105.5    -3
% 8   73.5   -23
% 9   99.0    -4
% 10 108.5    -3

% RPMatthew 20180412




Ybar        = mean(data);
S           = cov(data,1);
r           = (S(1,2))/sqrt((S(1,1))*(S(2,2)));      % Pearson's corrleation coeff (precision)
u           = (Ybar(1)-Ybar(2))/(sqrt(sqrt(S(1,1))*sqrt(S(2,2))));  % locShift
v           = sqrt(S(1,1))/sqrt(S(2,2));                            % scaleShift
Cb          = ((v+1/v+u^2)/(2))^-1;                 % Bias Correction Factor (accuracy)

% rho     = (2*S(1,2))/(S(1,1)+S(2,2)+(Ybar(1)-Ybar(2))^2)
rho     = r*Cb;

Z       = atanh(rho);
E       = sqrt((...
    ((1-r^2)*rho^2)/((1-rho^2)*r^2)...
    +(2*rho^3*u^2*(1-rho))/(r*(1-rho^2)^2)...
    -(rho^4*u^4)/(2*r^2*(1-rho^2)^2))...
    /(size(data,1)-2));

z = @(p) -sqrt(2) * erfcinv(p*2);

clear CCC
CCC{1}.name   = 'Lin''s Concordance Correlation Coefficient';
CCC{1}.est              = rho;
CCC{1}.scaleShift       = v;
CCC{1}.locationShift    = u;
CCC{1}.biasCorrection   = Cb;
CCC{1}.pearsonCorrCoeff = r;
CCC{1}.confInterval     = [tanh(Z+z(0.5*alpha)*E),tanh(Z+z(1-0.5*alpha)*E)];
end

