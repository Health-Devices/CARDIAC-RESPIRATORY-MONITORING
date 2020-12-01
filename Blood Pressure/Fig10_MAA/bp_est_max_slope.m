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

% Maximum slope algorithm

function BP = bp_est(cp, omw, fs, plotting)
% Obtaining omw from P
        clear trough_ind start_ind; 
        %find OMW troughs
        [peak_amp, peak_ind,~,~] = findpeaks(omw, 'MinPeakDistance', fs/(1.4), 'MinPeakHeight',0.2); 
        peak_distance = diff(peak_ind(1:end));
        start_ind=peak_ind(1:end-1);
        %end_ind=peak_ind(2:end-1)+round(peak_distance/3);
        end_ind=peak_ind(2:end);
        
        for i =1:length(start_ind)
            [~, ind] = min(omw(start_ind(i):end_ind(i)));
            trough_ind(i,:) = ind + start_ind(i) - 1;
        end
        peak_ind(1) = [];
        trough_ind(1)=[];
        %fix lengths and outliers
        peak_ind(end) = [];
        
        %OMWE
%         omwe = omw(peak_ind)-omw(trough_ind); %omw1(peak_ind)-omw1(trough_ind);
%         omwe_ind = round((trough_ind+peak_ind)/2);
        omwe = omw(peak_ind);
        omwe=smooth(medfilt1(omwe,7));
        omwe_ind = peak_ind;
 
        [m,ind]=max(omwe);
        MAP=cp(peak_ind(ind));
        omwe_sm=smooth(omwe);
        omwe_diff=[0; diff(omwe_sm)];
        [m1, i1]=max(omwe_diff(1:ind));
        BP(1)=cp(peak_ind(i1));
        [m2, i2]=min(omwe_diff(ind:end));
        BP(2)=cp(peak_ind(i2+ind-1));

%%