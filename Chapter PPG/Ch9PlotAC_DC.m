load('plethy1.mat')
figure
legend("940nm");
plot(t,(100-b1)/100)
ylabel('Normalized signal obtained at the photodetector (%)', 'FontSize', 10)
xlabel('Time (sec)', 'FontSize', 10)
ylim([0.9,1.02])
a3=line([0.4 0.4],[0.9 0.9902],'Color','magenta','LineStyle','-.')
a2=line([0.4 0.4],[0.9902 1],'Color','red','LineStyle','--')
%text(0.4,0.945,'\leftarrow DC component')
text(0.4,0.945,{'\leftarrow DC component', '    Non-pulsatile blood', '    De-oxygenated blood', '    Other tissue'})
text(0.4,0.996,'\leftarrow AC component')