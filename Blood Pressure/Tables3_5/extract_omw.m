function [cp,omw] = extract_omw(P, fs)
% Obtaining omw from P

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