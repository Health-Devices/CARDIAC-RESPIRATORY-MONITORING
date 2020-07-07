% clear all
% Irr1(:,1)=0:0.001:10; %time
% Irr1(:,2)=0:0.01/50:0.2; % irradiance
% simOut = sim('photodiode1', 'CaptureErrors', 'on');
% figure
% plot(simOut.v_out.Time, simOut.v_out.Data)
% plot(simOut.v_out.Time, simOut.i_out.Data)

clear all
load('plethy.mat');
a1=rescale1([a;a;a;a;a;a;a;a;a;a]);
a2=0.05*(1-0.01*a1);
T=0.0001;
len=10*1/T+1;
a2q=zeros(1,len);
step=floor((1/T)/1000); %1kHz
%a2q(1:step:step*length(a2))=a2;
a2q1 = interp1(1/77:1/77:10,a2,0:T:10, 'linear','extrap');
a2q(1:step:length(a2q))= a2q1(1:step:length(a2q));
a2q(2:step:length(a2q))= a2q1(2:step:length(a2q));
a2q(3:step:length(a2q))= a2q1(3:step:length(a2q));
Irr1(:,1)=0:T:10; %time
Irr1(:,2)=a2q'; % irradiance
simOut = sim('ppg2', 'CaptureErrors', 'on');

blockNames = find_system( 'ppg2' , 'Type' , 'Block' );
for k = 1 : length( blockNames )
    set_param( blockNames{k} , 'ShowName' , 'on' );
end;
% set_param('ppg2/GND2' , 'ShowName' , 'off' );
% set_param('ppg2/GND3' , 'ShowName' , 'off' );
% set_param('ppg2/GND4' , 'ShowName' , 'off' );
% set_param('ppg2/GND5' , 'ShowName' , 'off' );
% set_param( 'ppg2/VCC//1', 'ShowName' , 'off' );
% set_param( 'ppg2/VCC//2', 'ShowName' , 'off' );
figure
% plot(-simOut.diode_out.Data,-simOut.current_out.Data*1e6)
% xlabel(' Reverse Voltage (V)', 'FontSize', 10)
% ylabel('Reverse Light Current (µA)', 'FontSize', 10)
plot(simOut.v_out.Time, simOut.v_out.Data)
%plot(simOut.v_out.Time, simOut.i_out.Data)
figure,plot(simOut.v_out.Time*1e3, -simOut.i_out.Data*1e6)
xlim([0,15])
xlabel('Time (ms)', 'FontSize', 10)
ylabel('Current (µA)', 'FontSize', 10)
figure,plot(simOut.v_out.Time, simOut.v_out.Data)
 xlabel('Time (s)', 'FontSize', 10)
 ylabel('Voltage at point V2 (V)', 'FontSize', 10)
 xlim([5,10])
 figure,plot(simOut.v_out.Time, simOut.v_out2.Data)
xlabel('Time (s)', 'FontSize', 10)
ylabel('Voltage at point Vout (V)', 'FontSize', 10)
xlim([5,10])
tst=1;
