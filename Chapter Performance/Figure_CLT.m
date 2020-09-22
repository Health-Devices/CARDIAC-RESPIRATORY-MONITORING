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

close all
clear all

% Plot hystogram for n=1
n1=rand(1,2000);
figure
histogram(n1, 'Normalization','probability')
ylabel('X=X1')
xlabel('x')

% Plot hystogram for n=2
n2=rand(2,2000);
m=mean(n2);
figure
histogram(m, 'Normalization','probability')
ylabel('X=X_1+X_2')
xlabel('x')

% Plot hystogram for n=20
n2=rand(20,2000);
m=mean(n2);
figure
histogram(m, 'Normalization','probability')
ylabel('X=X_1+...+X_{20}')
xlabel('x')