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