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
% PERVASIVE CARDIAC AND RESPIRATORY MONITORING DEVICES Chapter 4

% Obtaining omw from P

function [cp,omw] = extract_omw(P, fs)


        %find OMW peaks
        %cutoff =0.1;
        %cp = lowpass(P, cutoff, fs);
        i=1:length(P)
        f=fit(i',P','poly3');
        cp=f(i);
        %OMW
        omw1 = P - cp';
        cutoff = 10;
        omw = lowpass(omw1, cutoff, fs);

%%