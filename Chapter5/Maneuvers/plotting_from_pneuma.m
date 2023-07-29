function plotting_from_pneuma ()
% This function plots the signal from the pneuma simulator stored in the
% file CARDIORESPIRATORY1.mat. The variables include: Time, State Drive SI, HR, ABP, Ppl, PaCO2,
% SaO2, Breathing Frequency BF, Tidal Volume Vt,
% Total Ventilatory Drive DTotal

load('CARDIORESPIRATORY1.mat', 'CARDIORESPIRATORY')
plot(CARDIORESPIRATORY(1,:),CARDIORESPIRATORY(9,:))
xlabel('Time (s)')
ylabel('Tidal Volume (l)')
title('Tidal volume during Valsalva and Mueller maneuvers')
plot(CARDIORESPIRATORY(1,:),CARDIORESPIRATORY(4,:))
xlabel('Time (s)')
ylabel('Arterial blood pressure (mmHg)')
title('ABP during Valsalva and Mueller maneuvers')
plot(CARDIORESPIRATORY(1,:),CARDIORESPIRATORY(3,:))
xlabel('Time (s)')
ylabel('Heart rate (bpm)')
title('Heart rate during Valsalva and Mueller maneuvers')
plot(CARDIORESPIRATORY(1,:),CARDIORESPIRATORY(5,:))
xlabel('Time (s)')
ylabel('Ppl (mmHg)')
title('Pleural Pressure during Valsalva and Mueller maneuvers')
plot(CARDIORESPIRATORY(1,:),CARDIORESPIRATORY(6,:))
xlabel('Time (s)')
ylabel('PaCO_2 (mmHg)')
title('PaCO_2 during Valsalva and Mueller maneuvers')
plot(CARDIORESPIRATORY(1,:),CARDIORESPIRATORY(7,:))
xlabel('Time (s)')
ylabel('SaO_2 (%)')
title('SaO_2 during Valsalva and Mueller maneuvers')

% CARDIO#.mat Cardiovascular System Outputs: Time, Heart Period HP,
% Stroke Volume SV, Cardiac Output CO, TPR and ABP
load('CARDIO1.mat')
xlabel('Time (s)')
ylabel('CO (l/min)')
title('Cardiac Output during Valsalva and Mueller maneuvers')