clear; close all
p = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/tdb_big/GraphTS_L1.mat';
psa = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/tdb_big/GraphTS_SA.mat';
pf = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/utils/FlumeImageProcessing/analysis/ev2vals.mat';

flumepx = 2.15 / 666; %m/px
simpx = 2.8*sqrt(2) / 101; %m/px
scale = simpx / flumepx;

load(p)
load(pf)
load(psa)

c = {'-r','-g','-b'};
leglbls = [];
figure; 
hold on
for i = 1:length(GTS.Clustering.T)
    sim = GTS.Clustering.labels{i};
    foundmet = false;
    k = 1;
    while ~foundmet
        if strcmp(stats.labels{k},sim)
            foundmet = true;
            met = stats.metrics{k};
        else
            k = k+1;
        end
    end
    leglbls(GTS.Clustering.T(i)) = plot(met,linspace(0,1,length(met)), c{GTS.Clustering.T(i)});
end

leglbls(4) = plot(scale * ev, linspace(0,1,length(ev)), '--k','Linewidth',3);
xlabel('Eigenvalue')
ylabel('CDF')
title('Fiedler Value CDFs')
legend(leglbls,{'Cluster 1','Cluster 2','Cluster 3','Flume'},'Location','Southeast')