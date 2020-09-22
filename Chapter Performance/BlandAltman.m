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


clear all
% Rearing data. Data is from https://www-users.york.ac.uk/~mb55/datasets/bp.dct
%dictionary{
%sub  "Subject"
%j1   "Observer J measurement 1"
%j2   "Observer J measurement 2"
%j3   "Observer J measurement 3"
%r1   "Observer R measurement 1"
%r2   "Observer R measurement 2"
%r3   "Observer R measurement 3"
%s1   "Machine  measurement 1"
%s2   "Machine  measurement 2"
%s3   "Machine  measurement 3"
%}
% We are using only j1 and s1 which are columns 2 and 8
a=load("BlandAltmanBPData.txt");
method1=a(:,8)';
method2=a(:,2)';
x = min(method1):1:max(method1);

% Finding mean and difference
meanArray = mean([method1;method2]);
diffArray = method1-method2;
meanOfDiffs = mean(diffArray);
stdOfDiffs = std(diffArray);
confRange = [meanOfDiffs + 2.0 * stdOfDiffs, meanOfDiffs - 2.0 * stdOfDiffs];
    
% Plotting scatter plot
figure
[p,S] = polyfit(method1, method2, 1);
[yfit,delta] = polyval(p, method1, S); 
plot(method1, method2, 'bo'); 
hold on;
plot(method1, yfit,'r-');
plot(x,x)
legend('Data','Linear-Fit','Equality line'); grid; 
xlabel('Method-1'); ylabel('Method-2');

% Plotting BlandAltman plots
figure
plot(meanArray,diffArray,'o'); 
hold on;
line([min(meanArray) max(meanArray)],[confRange(1) confRange(1)],'Color','red','LineStyle','-.');
line([min(meanArray) max(meanArray)],[confRange(2) confRange(2)],'Color','red','LineStyle','-.');
line([min(meanArray) max(meanArray)],[meanOfDiffs meanOfDiffs],'Color','black','LineStyle','-.');
grid; ylabel('Differences'); xlabel('Means');
text(220,60,{'\downarrow \mu+2\sigma'})
text(220,21,{'\downarrow \mu'})
text(220,-18,{'\downarrow \mu-2\sigma'})
hold off;

