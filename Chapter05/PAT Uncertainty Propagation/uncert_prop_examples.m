% Examples for the uncertainity propagation functions.
% Joe Klebba 3/2021

clear, clc;
% Example 1
%Show that sum of squares and Monte Carlo give similar results for a 
%linear function.
fprintf('\nExample 1: Linear function\n')
X=5; uX=0.2;
Y=3; uY=0.1;
f=@(x,y)5.*x - 2.*y;
[uncertCD,valCD]=propUncertCD(f,[X Y],[uX uY])

syms x y
f_sym = 5.*x - 2.*y;
[uncertSym,valSym]=propUncertSym(f_sym,[x y],[X Y],[uX uY])

[CI,valMC]=propUncertMC(f,{{X uX};{Y uY}},100000);
uncertMC = (CI(2)-CI(1))/2
valMC


% Example 2
%Show that sum of squares and Monte Carlo can give very different results 
%when evaluated in a highly nonlinear region. Use propUncertMC() to plot 60 
%bin histrograms of the samples and the resulting distribution.
fprintf('\nExample 2: Highly nonlinear case\n')
X=6.67; uX=.3;
Y=3; uY=.2;
f=@(x,y)-x.^3+10.*x.^2+y;

[uncertCD,valCD]=propUncertCD(f,[X Y],[uX uY])

syms x y
f_sym = -x.^3+10.*x.^2+y;
[uncertSym,valSym]=propUncertSym(f_sym,[x y],[X Y],[uX uY])

[CI,valMC]=propUncertMC(f,{{X uX};{Y uY}},100000,'varHist',60,'hist',60);
uncertMC = (CI(2)-CI(1))/2
valMC

% Example 3
% Uncertainity propagation with correlated uncertainties.
%Estimate the exposed surface area of a type of cylindrical beam that will 
%be used in a corrosive underwater environment. We know from prior experience
%that the manufacturing/measurement process imparts a 0.6 correlation 
%between the uncertainties in the length and diameter of the beam.
fprintf('\nExample 3: Correlated Uncertainties\n')
length=10;    uLength=0.05;
diameter=0.5; uDiameter=0.003;
LDcorrMatrix=[1 0.6; 0.6 1];
SA = @(len,dia)len.*dia.*pi;

[uncertCD,valCD]=propUncertCD(SA,[length diameter],[uLength uDiameter],LDcorrMatrix)

syms l d
SA_sym = l*d*pi;
[uncertSym,valSym]=propUncertSym(SA_sym,[l d],[length diameter],[uLength uDiameter],LDcorrMatrix)

[CI,valMC]=propUncertMC(SA,{{'Corr',{{length uLength};{diameter uDiameter}},LDcorrMatrix}},100000);
uncertMC = (CI(2)-CI(1))/2
valMC


% Example 4
% Handle non-normal measurement uncertainty using propUncertMc().
%Calulate the area of a rectangular plate with height D1 and width D2. 
%Our measuring tool is a digital caliper which displays length measurements 
%to the nearest 0.01 inch. Every time we measure D1 we get 3.14 cm, so
%we characterize the measurement uncertainity as a uniform distribution 
%with lowerbound 3.135 and upperbound 3.145. D2 is treated similarly.
fprintf('\nExample 4: Variables with non-normal uncertainty\n')
D1=3.14;   lowD1=3.135;   highD1=3.145;
D2 = 5.03; lowD2=5.025;   highD2=5.035;
Area = @(d1,d2)d1.*d2;
[CI,valMC]=propUncertMC(SA,{{'uniform',lowD1,highD1};{'uniform',lowD2,highD2}},100000);
uncertMC = (CI(2)-CI(1))/2
valMC


% Example 5
% Use a truncated distribution.
%Some samples from X's distribution will be negative. The function 'f' is 
%the natural log. Since the logarithm of a negative number is complex this 
%can lead to unintended consequences and/or physically unrealistic 
%predictions. In many cases truncation can be used to remove problematic 
%outliers without signifigantly altering the shape of the distribution.
%Additionally, a truncated distribution may be a more accurate 
%representation of the uncertainity in some cases.
fprintf('\nExample 5: Using Truncated Distributions\n')
X=0.4; uX=0.1;
f = @(x)log(x);

[CI,valMC]=propUncertMC(f,{{X uX}},1000000,'mean');
uncertMC_noTrunc = (CI(2)-CI(1))/2
valMC_noTrunc=valMC
%Now truncate the distribution to prevent complex numbers.
upperB = 2*X;
[CI,valMC]=propUncertMC(f,{{X,uX,'trunc',0,upperB}},1000000,'mean');
uncertMC = (CI(2)-CI(1))/2
valMC


% Example 6
%Show an example of using the 'BootstrapMean' and 'Custom' options. Set a 
%95% CI inteval (default is 68%).
fprintf('\nExample 6: Different distribution options for propUncertMC()\n')
n=100000;
x_data = unifrnd(3,4,1,15);
y_data = normrnd(5,0.1,n,1);
f = @(x,y)x+5.*y;
[CI,valMC]=propUncertMC(f,{{'BootstrapMean',x_data}; {'Custom',y_data}},n,'CI',0.95);
uncertMC = (CI(2)-CI(1))/2
valMC






%remove the 'return' statements to run the following examples
return

% PROOF OF CONCEPT SIMULATIONS
% Example 7
%Run a simulation to verify the theory of error propagation works and that 
%our confidence interval captures the true value ~95.45% of the time for a 
%two sigma CI.

fprintf('\nExample 7: Simulation to Verify Error Propagation\n')
%Initialize the hidden params of true measurement distributions. These are 
%unknown to us, since in the real world the best we can do is approximate 
%the true mean and standard deviation using a sample of n measurements.
X_trueVal=6.67; uX=.3;
Y_trueVal=3; uY=.2;
f=@(x,y)x+5.*y;
trueVal = f(X_trueVal,Y_trueVal);

countMC =0; countCD=0;
trials=5000;
for i=1:trials
  %Sample the measurement distributions 50 times to simulate taking
  %measurements.
  nSamp=50;
  Xsamp = normrnd(X_trueVal,uX,nSamp,1); Ysamp = normrnd(Y_trueVal,uY,nSamp,1);
  %Compute the means and the standard error of the mean
  mX = mean(Xsamp); mY=mean(Ysamp);
  seomX=std(Xsamp)/sqrt(nSamp); seomY=std(Ysamp)/sqrt(nSamp);
  
  [uncertCD,valCD]=propUncertCD(f,[mX mY],[seomX seomY]);
  [CI,valMC]=propUncertMC(f,{{mX seomX};{mY seomY}},100000,'CI',0.9545);
  %Keep track of how many times each confidence interval captures the true value
  if trueVal>CI(1) && trueVal<CI(2)
    countMC = countMC+1;
  end
  if trueVal>valCD-uncertCD*2 && trueVal<valCD+uncertCD*2
    countCD=countCD+1;
  end
  
end
disp('The interval should contain the true value about 95% of the time.')
ratioMC = countMC/trials
ratioCD = countCD/trials


return
% Example 8
%Run a simlulation to show that using uniform distributions like in Example 
%5 may be neccesary for good accuracy if one or more of the measurement 
%distributions is non-normal. 
%Use a one sigma CI.

fprintf('\nExample 8: Simulation to Show Accuracy For Non-Normal Distributions\n')
%Each time we measure X we get a reading of 5.1 so assume a uniform distribution
%from 5.05 to 5.15.
X_low=5.05; X_high=5.15; 
X_center=(X_high+X_low)/2; uX=(X_high-X_low)/sqrt(12);

%Unknown true params for the distribution of Y.
Y_trueVal=4.1; uY=0.2;

f=@(x,y)5*x+y./x.^2;

countMCuni=0; countMCnorm=0; countCD=0;
nYsamp=50;
trials=5000;
for i=1:trials
%X has one true value which lies within the uniform distribution.
Xsamp = unifrnd(X_low,X_high,1,1);

%Sample Y to estimate the mean and the standard error of the mean.
Ysamp = normrnd(Y_trueVal,uY,nYsamp,1);
Ymean=mean(Ysamp);
Yseom=std(Ysamp)/sqrt(nYsamp);

%Use a uniform distribution for X
distsUni= {{'uniform',X_low,X_high};
    {Ymean,Yseom}};

%Use a normal distribution for X
distsNorm= {{X_center,uX};
    {Ymean,Yseom}};

n=100000;    
[uci,uv] = propUncertMC(f,distsUni,n);
[nci,nv] = propUncertMC(f,distsNorm,n);
[uCD,vCD]=propUncertCD(f,[X_center Ymean], [uX Yseom]);

%Keep track of how many times each interval captures the true value.
trueVal = f(Xsamp,Y_trueVal);
if uci(1)<trueVal && uci(2)>trueVal
    countMCuni=countMCuni+1;
end
if nci(1)<trueVal &&nci(2)>trueVal
    countMCnorm=countMCnorm+1;
end
if vCD-uCD<trueVal && vCD+uCD>trueVal
  countCD=countCD+1;
end
end

disp('The interval should capture the true value around 68% of the time.')
ratioMCuni=countMCuni/trials
ratioMCnorm=countMCnorm/trials
ratioCD=countCD/trials
