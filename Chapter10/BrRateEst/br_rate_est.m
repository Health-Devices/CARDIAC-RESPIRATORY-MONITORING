function [breathing_rate_peaks] = br_rate_est(sig,fs)
[m1,j1]=findpeaks(rescale1(medfilt1(sig,5)), 'MinPeakProminence',0.1,'MinPeakDistance',floor(fs/0.6), 'MinPeakWidth', floor(fs/2));
[m2,j2]=findpeaks(rescale1(-medfilt1(sig,5)), 'MinPeakProminence',0.1,'MinPeakDistance',floor(fs/0.6),  'MinPeakWidth', floor(fs/2));
%breathing_rate_peaks=60*(0.5*(legth(j1)+legth(j2)))/segment_length;
if length(j1)>1 & length(j2)>1 
     breathing_rate_peaks=2*(60*fs/(mean(diff(j1))+mean(diff(j2)))); %0.5*(length(j1)+length(j2))*60/(length(c3)/fs); 2*(60*17/(mean(diff(j1))+mean(diff(j2)))); % 0.5*(60*17/mean(diff(j1))+60*17/mean(diff(j2)));
elseif length(j1)>1
     breathing_rate_peaks=2*(60*fs/(mean(diff(j1)))) ;
elseif length(j2)>1
     breathing_rate_peaks=2*(60*fs/(mean(diff(j2)))) ;
else
     breathing_rate_peaks=0;
end
end

function [Y] = rescale1(X)
% function [Y] = rescale(X)
% Rescales values of X between having each column values between [0, 1]
%
% Input arguments:
% X  : matrix of size [nsamples, ncols] containing values to rescale
%
% Output arguments:
% Y  : result matrix
%
% Developed by: 
% Mario Castro Gama
% PhD researcher
% 2015-10-01
% 
% Example:
% X = rand(100,4);
% Y = rescale(X);
% disp(min(Y));
% disp(max(Y));
%

  if isempty(X)
    error('X is empty');
  end

  [n,m] = size(X);
  Y = zeros(n,m);
  xmin = min(X);
  xmax = max(X);
  for jj = 1:m;
    Y(:,jj) = (X(:,jj) - xmin(jj)) / (xmax(jj)-xmin(jj));
  end
end