function [pensavg, penssd, quality1, r2]=ens_averaging(sig, fs, peak_positions, plotting)
% This code is based on ensemble averaging code from A practical guide to 
% wave intensity analysis by Kim H. Parker at https://kparker.bg-research.cc.ic.ac.uk/guide_to_wia/03_ensemble_average.html

% Inputs:
% sig: input signal - for example ECG or PPG
% fs: sampling frequncy
% peak_positions: R peaks time samples or maximums/minimums of PPG pulses
% plotting = 1 plot the results

% Outputs
% pensavg: averaged template waveform
% penssd: std of each sample in the template waveform
% quality1: tSQI of each beat
% r2 - corelation coefficient per each beat

% PPG: [pensavg, penssd, quality]=ens_averaging(sigs.filt, sigs.fs, E.R_w(:,1), 0, pulses.quality)
% ECG: [pensavg, penssd, quality]=ens_averaging(sigs.filt, sigs.fs, E.R_w(:,1), 0)
 
nb=peak_positions;
Nb=length(peak_positions);                 % the number of beats detected
quality=ones(1, Nb-1);
quality1=ones(1, Nb-1);

nperiod=mean(diff(nb));        % find the average cardiac period
nint=round(1.05*nperiod);       % chose a beat interval slightly longer than nperiod
tens=(0:nint-1)/fs;
pens=zeros(Nb-1,nint);
for n=1:Nb-1
    pens(n,:)=sig(nb(n)-floor(fs/4):nb(n)+nint-1-floor(fs/4));
    %uens(n,:)=us(nb(n):nb(n)+nint-1);
end
ind=find(quality==1);
pensavg=mean(pens(ind,:));      % ensemble average pressure
penssd=std(pens(ind,:));        %    and standard deviation
%uensavg=mean(uens);      % ensemble average velocity
%uenssd=std(uens);        %    and standard deviation
r2 = nan(length(ind),1);
for k = 1:length(ind)
    r2(k) = corr2(pensavg,pens(ind(k),:));
end
high_quality_beats = r2 > 0.9;
quality1 = false(length(quality),1);
quality1(ind(high_quality_beats)) = true;

if plotting ==1
    figure, grid on, hold on;
    if nargin == 4
        plot(tens,pens');
    else
        plot(tens,pens(ind(high_quality_beats),:)');
    end
    plot(tens,pensavg,'k',tens,pensavg+2*penssd,'k:',tens,pensavg-2*penssd,'k:','LineWidth',2);
    axis tight;
    ylabel 'P-Pd';
    xlabel 't (s)';

    % figure, grid on, hold on;
    % plot(tens,uens');
    % plot(tens,uensavg,'k',tens,uensavg+uenssd,'k:',tens,uensavg-uenssd,'k:','LineWidth',2);
    axis tight;
    ylabel 'Amplitude (mv)';
    xlabel 'Time (s)';
end
