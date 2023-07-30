figure
a1=plot(in)
hold on
a2=plot(out)
ylabel('Voltage (V)', 'FontSize', 10)
xlabel('Time (s)', 'FontSize', 10)
legend([a1,a2],["Input signal at 60 Hz","Filtered signal"])
xlim([0 0.1])

