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
% Dependencies include files rescale1.m, plethy.mat and ppg2.slx

% Generate Data
clear all
load('plethy.mat');
a1=rescale1([a;a;a;a;a;a;a;a;a;a]);
a2=0.05*(1-0.01*a1);
T=0.0001;
len=10*1/T+1;
a2q=zeros(1,len);
step=floor((1/T)/1000); %1kHz
%a2q(1:step:step*length(a2))=a2;
a2q1 = interp1(1/length(a):1/length(a):10,a2,0:T:10, 'linear','extrap');
a2q(1:step:length(a2q))= a2q1(1:step:length(a2q));
a2q(2:step:length(a2q))= a2q1(2:step:length(a2q));
a2q(3:step:length(a2q))= a2q1(3:step:length(a2q));
Irr1(:,1)=0:T:10; %time
Irr1(:,2)=a2q'; % irradiance

% Running simulation
simOut = sim('ppg2', 'CaptureErrors', 'on');
% Setting parameters
SETTING_PARAM=0;
if SETTING_PARAM
    blockNames = find_system( 'ppg2' , 'Type' , 'Block' );
    for k = 1 : length( blockNames )
        set_param( blockNames{k} , 'ShowName' , 'on' );
    end;
    set_param('ppg2/GND2' , 'ShowName' , 'off' );
    set_param('ppg2/GND3' , 'ShowName' , 'off' );
    set_param('ppg2/GND4' , 'ShowName' , 'off' );
    set_param('ppg2/GND5' , 'ShowName' , 'off' );
    set_param( 'ppg2/VCC//1', 'ShowName' , 'off' );
    set_param( 'ppg2/VCC//2', 'ShowName' , 'off' );
end

figure
plot(simOut.v_out.Time, simOut.v_out.Data)
figure,plot(simOut.v_out.Time*1e3, -simOut.i_out.Data*1e6)
xlim([0,15])
xlabel('Time (ms)', 'FontSize', 10)
ylabel('Current (µA)', 'FontSize', 10)

figure,plot(simOut.v_out.Time, simOut.v_out.Data)
xlabel('Time (s)', 'FontSize', 10)
ylabel('Voltage at point V1 (V)', 'FontSize', 10)
xlim([5,10])

figure,plot(simOut.v_out.Time, simOut.v_out1.Data)
xlabel('Time (s)', 'FontSize', 10)
ylabel('Voltage at point V2 (V)', 'FontSize', 10)
xlim([5,10])

figure,plot(simOut.v_out.Time, simOut.v_out2.Data)
xlabel('Time (s)', 'FontSize', 10)
ylabel('Voltage at point Vout (V)', 'FontSize', 10)
xlim([5,10])

