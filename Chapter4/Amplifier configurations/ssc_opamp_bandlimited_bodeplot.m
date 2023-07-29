%% Linearize a Circuit to View Frequency Response
% This example script shows how you can view the small-signal frequency
% response of a Simscape(TM) model by using linearization. It uses example
% model ssc_opamp_bandlimited.
%
% An alternative and recommended way to linearize Simulink(R) and Simscape
% models is to use Simulink Control Design(TM). Simulink Control Design has
% tools that help you find operating points and returns a state-space model
% object that defines state names. If you have Simulink Control Design,
% open the model ssc_opamp_bandlimited. On the Apps tab, under Control
% Systems, click Model Linearizer. In the Linear Analysis Tool, on the
% Linear Analysis tab, in the Linearize section, click Bode.

% Copyright 2012-2019 The MathWorks, Inc.



%% Generate data for Bode plot
c = -c; d = -d; % Negative feedback convention
npts = 100; f = logspace(-2,10,npts); G = zeros(1,npts);
for i=1:npts                                                       
    G(i) = c*(2*pi*1i*f(i)*eye(size(a))-a)^-1*b +d;                      
end

% Create Bode plot
ah(1) = subplot(2,1,1);
temp_magline_h=semilogx(f,20*log10(abs(G)));
grid on                                                             
ylabel('Magnitude (dB)');
title('Frequency Response (Band-Limited Op-Amp)');
ah(2) = subplot(2,1,2);
temp_phsline_h=semilogx(f,180/pi*unwrap(angle(G)));
set([temp_magline_h,temp_phsline_h],'LineWidth',2);
ylabel('Phase (deg)');
xlabel('Frequency (Hz)'); 
grid on

linkaxes(ah,'x');

% Remove temporary variables
clear a b c d npts f G temp_magline_h temp_phsline_h

