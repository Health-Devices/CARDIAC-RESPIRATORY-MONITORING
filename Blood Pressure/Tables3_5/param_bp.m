function [alpha, beta, gamma, c_sbp, c_dbp]=param_bp(cp, MAP, omwe, peak_ind, SBP, DBP);
[gamma, i]=max(omwe);
   
i1=find(gamma*0.5<omwe);
BP(1)=cp(peak_ind(i1(1)));
alpha=-MAP+BP(1);
i2=find(gamma*0.5<omwe);
BP(2)=cp(peak_ind(i2(end)));
beta=MAP-BP(2);
i3=find(cp(peak_ind)<SBP);
c_sbp=omwe(i3(1))/gamma;
i4=find(cp(peak_ind)<DBP);
c_dbp=omwe(i4(1))/gamma;