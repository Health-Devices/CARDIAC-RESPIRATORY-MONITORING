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

function [P, Pa]=model1 (a,b,SBP, DBP, fs, plotting)
% This implementation follows closely the paper:
% Oscillometric measurement of systolic and diastolic blood pressures validated in a physiologic mathematical model
% by Charles F BabbsEmail author
% published in BioMedical Engineering OnLine, 2012, 11:56
% https://biomedical-engineering-online.biomedcentral.com/articles/10.1186/1475-925X-11-56


%Blood pressure to be simulated - please change systolic in the rangge 110
%to 140 and dia between 60 and 90

%%

r=0.12; % radius of the artery in cm
L=10;    % length of the artery covered by the cuff in cm
V0=200; % Volume of the cuff at the beginning in ml
delta_r=0.05; %  the brachial artery strain (?r/r) during a normal pulse is 4 percent for a blood pressure of 130/70 mmHg

%%
%Computing the parameters
PP= SBP-DBP; % pulse pressure
Pmid=0.5*(SBP+DBP); % mid pressure
P0=SBP+30; % start of cuff deflation

%a = 0.076; %log(0.1)/(-20); % stiffness coefficient change to 0.075 or 0.11 for very stiff arteries
rate=2.5; %rate of the cuff defflation
heart_rate=1; % in Hz
delta_Va=2*3.14*(r)*(delta_r*r)*L; %2*pi*r*delta_r*L change in volume

Cn= delta_Va/PP; % The normal pressure compliance for the artery segment is the volume change divided by pulse pressure

Va0=3.14*(r)^2*L; %The resting artery volume

%b=-log(Cn/(a*Va0))/Pmid; % another stiffness coefficient - equation (3) from the paper
%b=0.021;
% Model of the arterial pulse and its derivative
delta_T=1/fs;
t=0:delta_T:55;
omega=2*pi*heart_rate;
Pa=DBP+0.5*PP+0.36*PP*(sin(omega*t)+0.5*sin(2*omega*t)+0.25*sin(3*omega*t));
dP_dt=0.36*PP*omega*(cos(omega*t)+cos(2*omega*t)+0.75*cos(3*omega*t));
%%
% Volume vs transmural pressure - equation (4) from the paper
for i=1:length(t)
    Pt(i)=Pa(i)-P0+rate*t(i);
    if Pt(i)<0
        Va(i)=Va0*exp(a*Pt(i));
    else
        Va(i)=Va0*(1+(1-exp(-b*Pt(i)))*a/b);
    end
end
if plotting ==1
    figure(1); hold on, plot(Pt,Va)
    %legend('Volume(ml) vs Transmural pressure')
    ylabel('Volume(ml)')
    xlabel('Transmural pressure (mmHg)')
    
    figure
    plot(t, Pt)
    xlabel('Time (s)')
    ylabel('Transmural pressure (mmHg)')
    
    figure
    plot(t, Va)
    xlabel('Time (s)')
    ylabel('Volume (mL)')
end
%%
% dVa_dt - equation (6)
for i=1:length(t)
    Pt(i)=Pa(i)-P0+rate*t(i); % transmural pressure
    if Pt(i)<0
        dVa_dt(i)=a*Va0*exp(a*Pt(i))*(dP_dt(i)+rate);
    else
        dVa_dt(i)=a*Va0*exp(-b*Pt(i))*(dP_dt(i)+rate);
    end
end
if plotting ==1
    figure; plot(P0-rate*t,dVa_dt) %plot(t,dVa_dt,'o-')
    legend('dVa/dt vs time')
end

%%
% Obtaining cuff pressure with the arterial pulse - equation (1a)
P(1)=P0;
Int_Va(1)=0;
%{
for i=2:length(t)
    Int_Va(i)=Int_Va(i-1)+delta_T*(dVa_dt(i)*(t(i))-dVa_dt(i-1)*(t(i-1)));
    C(i)=Va(i)*(P0-760)/V0-(rate/V0)*Int_Va(i);
    P(i)=P0-rate*t(i)+C(i);
end
%}
for i=2:length(t)
    
    P(i)=P(i-1)-rate*delta_T+delta_T*(dVa_dt(i)*(P0+760-rate*t(i))/V0);
end
tspan = 0:delta_T:t(end);
if plotting ==1
    figure,
    plot(t,P) % and another way is manual integration
    legend('Total pressure vs time')
    ylabel('Pressure (mmHg)')
    xlabel('Time (s)')
end

end
%% 

