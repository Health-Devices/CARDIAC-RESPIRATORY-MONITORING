function BP = bp_est(cp, omw, coef, fs)
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
% Computing the omwe based on the peak-to-peak amplitudes of the pulses
%         omwe = omw(peak_ind)-omw(trough_ind);
%         omwe_ind = round((trough_ind+peak_ind)/2);
        omwe = omw(peak_ind);
        omwe_ind = peak_ind;
        figure, plot(cp, omw, cp(peak_ind), omw(peak_ind), '^', cp(trough_ind), omw(trough_ind), 'o', cp(peak_ind), omwe, 'DisplayName','Peaks')

        [m,ind]=max(omwe);
        MAP=cp(peak_ind(ind));
        i1=find(m*coef(1)<omwe);
        BP(1)=cp(peak_ind(i1(1)));
        i2=find(m*coef(2)<omwe);
        BP(2)=cp(peak_ind(i2(end)));

           
%         omw_interpolate1 = interp1(cp(peak_ind(1:end)), omwe, cp);
%         i1=find(m*coef(1)<omw_interpolate1);
%         BP(1)=cp(i1(1));
%         i2=find(m*coef(2)<omw_interpolate1);
%         BP(2)=cp(i2(end));
        
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

%          figure
% 
%          a1=plot(cp(peak_ind),omwe*20, 'b')
%          hold on
%          a2=plot(cp(peak_ind),cp(peak_ind), 'r')
%         a3=plot([0 cp(peak_ind(ind))],[MAP MAP], 'c')
%         plot([cp(peak_ind(ind))  cp(peak_ind(ind))],[omwe(ind)*20 MAP], 'c')
%          
%         a4=plot([0 cp(peak_ind(i1(1)))],[BP(1) BP(1)], 'm')
%          plot([cp(peak_ind(i1(1))) cp(peak_ind(i1(1)))],[omwe(i1(1))*20 BP(1)], 'm')
%          
%         a5=plot([0 cp(peak_ind(i2(end)))],[BP(2) BP(2)], 'k')
%         plot([cp(peak_ind(i2(end))) cp(peak_ind(i2(end)))],[omwe(i2(end))*20 BP(2)], 'k')
%         
%%