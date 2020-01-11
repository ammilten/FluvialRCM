clear; close all
pf = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/utils/FlumeImageProcessing/analysis/ev2vals.mat';

flumepx = 2.15 / 666; %m/px
simpx = 2.8*sqrt(2) / 101; %m/px
scale = simpx / flumepx;

load(pf)

figure;
plot(ev * scale, linspace(0,1,length(ev)),'-k','Linewidth',4)
set(gca,'linewidth',2)
set(gca,'fontweight','bold')
xlabel('Eigenvalue')
ylabel('CDF')
title('Fielder Value CDF')

