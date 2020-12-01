function BP = bp_est(cp, omw, coef, fs, plotting)
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

           
      if plotting == 1
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
      end
        
%          omw_interpolate1 = interp1(cp(peak_ind(1:end)), omwe, cp);
%         omwe_diff1=[0; diff(omw_interpolate1)];
%         [m1, i1]=max(omwe_diff1(1:ind));
%         BP(1)=cp(peak_ind(i1));
%         [m2, i2]=min(omwe_diff1(ind:end));
%         BP(2)=cp(peak_ind(i2+ind-1));         
%         i1=find(m*coef(1)<omw_interpolate1);
%         BP(1)=cp(i1(1));
%         i2=find(m*coef(2)<omw_interpolate1);
%         BP(2)=cp(i2(end));
%                  figure
% 
%          a1=plot(cp(peak_ind),omwe, 'b')
%          hold on
%         %a3=plot([0 cp(peak_ind(ind))],[MAP MAP], 'c')
%         plot([cp(peak_ind(ind))  cp(peak_ind(ind))],[0 omwe(ind)], 'c')
%          
%         %a4=plot([0 cp(peak_ind(i1(1)))],[BP(1) BP(1)], 'm')
%         pk_ind=find(peak_ind<i1(1));
%         plot([cp((i1(1))) cp((i1(1)))],[0 omwe(pk_ind(end))], 'm')
%          
%         % a5=plot([0 cp(peak_ind(i2(end)))],[BP(2) BP(2)], 'k')
%         pk_ind=find(peak_ind>i2(end));
%         plot([cp((i2(end))) cp((i2(end)))],[0 omwe(pk_ind(1))], 'k')
        
%%