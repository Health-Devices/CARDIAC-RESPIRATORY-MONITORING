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
function [BP, MAP, omwe, peak_ind] = bp_est_MAA(cp, omw, coef, fs, plotting)

% Setting parameters of the algorithms and parameters for protting
ENV_from_maxs=1 % 1 for envelope formed from maximumxs of oscilometric pulses
% 0 for envelope formed from peak-to-peaks of oscilometric pulses
Plot_vs_time =1 % 0 is protting vs pressure
Envelope_smooting= 1; % needed for noisy enveloped
Plot_envelope_smoothing =1;

clear trough_ind start_ind;
%find OMW troughs
[peak_amp, peak_ind,~,~] = findpeaks(smooth(omw), 'MinPeakDistance', fs/(1.4), 'MinPeakHeight',0.1);
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
if ENV_from_maxs ==1
    omwe = omw(peak_ind);
    if Envelope_smooting ==1
        omwe1=omwe; % if needed for plotting
        omwe=smooth(medfilt1(omwe,7));
    end
    omwe_ind = peak_ind;
else
    omwe = omw(peak_ind)-omw(trough_ind); %omw1(peak_ind)-omw1(trough_ind);
    if Envelope_smooting ==1
        omwe=smooth(medfilt1(omwe,7));
    end
    omwe_ind = round((trough_ind+peak_ind)/2);
end
% Plot effects of envelope smoothing
if plotting ==1 & Plot_envelope_smoothing==1
    %Plot Fig 14
    figure
    tspan = 1/fs:1/fs:length(cp)/fs;
    plot(tspan(peak_ind),omwe1)
    xlabel('Time (s)')
    ylabel('Oscillometric pressure waveform (mmHg)')
    hold on
    plot(tspan(peak_ind),omwe)
    legend('Oscilometric envelope with noise and artifacts', 'Cleaned oscilometric envelope')
    ylim([0,8])
end


[m,ind]=max(omwe);
MAP=cp(peak_ind(ind));
i1=find(m*coef(1)<omwe);
BP(1)=cp(peak_ind(i1(1)));
i2=find(m*coef(2)<omwe);
BP(2)=cp(peak_ind(i2(end)));
if plotting ==1
    if Plot_vs_time ==1
    
        figure, plot(cp, omw, cp(peak_ind), omw(peak_ind), '^', cp(trough_ind), omw(trough_ind), 'o', cp(peak_ind), omwe, 'DisplayName','Peaks')
        
        figure
        tspan = 1/fs:1/fs:length(cp)/fs;
        a1=plot(tspan(peak_ind),omwe*20, 'b')
        hold on
        a2=plot(tspan(peak_ind),cp(peak_ind), 'r')
        a3=plot([0 tspan(peak_ind(ind))],[MAP MAP], 'c')
        plot([tspan(peak_ind(ind)) tspan(peak_ind(ind))],[omwe(ind)*20 MAP], 'c')
        
        a4=plot([0 tspan(peak_ind(i1(1)))],[BP(1) BP(1)], 'm')
        plot([tspan(peak_ind(i1(1))) tspan(peak_ind(i1(1)))],[omwe(i1(1))*20 BP(1)], 'm')
        
        a5=plot([0 tspan(peak_ind(i2(end)))],[BP(2) BP(2)], 'k')
        plot([tspan(peak_ind(i2(end))) tspan(peak_ind(i2(end)))],[omwe(i2(end))*20 BP(2)], 'k')
        xlabel('Time (s)')
        ylabel('Pressure (mmHg)')
        legend('Oscilometric envelope', 'Cuff pressure')
    else % plotting against pressure
        omw_interpolate1 = interp1(cp(peak_ind(1:end)), omwe, cp);
        i1=find(m*coef(1)<omw_interpolate1);
        BP(1)=cp(i1(1));
        i2=find(m*coef(2)<omw_interpolate1);
        BP(2)=cp(i2(end));
        figure
        
        a1=plot(cp(peak_ind),omwe, 'b')
        hold on
        %a3=plot([0 cp(peak_ind(ind))],[MAP MAP], 'c')
        plot([cp(peak_ind(ind))  cp(peak_ind(ind))],[0 omwe(ind)], 'c')
        
        %a4=plot([0 cp(peak_ind(i1(1)))],[BP(1) BP(1)], 'm')
        pk_ind=find(peak_ind<i1(1));
        plot([cp((i1(1))) cp((i1(1)))],[0 omwe(pk_ind(end))], 'm')
        
        % a5=plot([0 cp(peak_ind(i2(end)))],[BP(2) BP(2)], 'k')
        pk_ind=find(peak_ind>i2(end));
        plot([cp((i2(end))) cp((i2(end)))],[0 omwe(pk_ind(1))], 'k')
    end
end
%%