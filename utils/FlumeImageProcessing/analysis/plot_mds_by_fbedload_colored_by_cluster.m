clear; close all
p = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/tdb_big/GraphTS_L1.mat';
psa = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/tdb_big/GraphTS_SA.mat';
pf = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/utils/FlumeImageProcessing/analysis/ev2vals.mat';

load(p)
load(pf)
load(psa)


%%

[DL1, LL1] = LaplacianEV2Dist(stats,'L1');
[DL2, LL2] = LaplacianEV2Dist(stats,'L2');

[s1,p1] = cmdscale(DL1);
[s2,p2] = cmdscale(DL2);

p1 = p1 / sum(p1) * 100;
p2 = p2 / sum(p2) * 100;

%%
parameter = 'gamma';

Index = find(contains(GTS.ParametersNames,parameter));
vals = GTS.ParametersValues(:,Index);

s = s1;
cluster1 = s(GTS.Clustering.T == 1,:);
cluster2 = s(GTS.Clustering.T == 2,:);
cluster3 = s(GTS.Clustering.T == 3,:);

v1 = vals(GTS.Clustering.T == 1);
v2 = vals(GTS.Clustering.T == 2);
v3 = vals(GTS.Clustering.T == 3);

%%

figure; 

hold on
[x1,f1] = ksdensity(v1);
[x2,f2] = ksdensity(v2);
[x3,f3] = ksdensity(v3);
plot(f1,x1,'r','Linewidth',4)
plot(f2,x2,'b','Linewidth',4)
plot(f3,x3,'g','Linewidth',4)


title(['Prior Distribution of ',parameter,' by Cluster'])
%legend('Cluster 1','Cluster 2', 'Cluster 3', 'Flume')
legend('Cluster 1','Cluster 2', 'Cluster 3')
xlabel(parameter)
ylabel('PDF')


