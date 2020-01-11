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

parameter = 'h0';

Index = find(contains(GTS.ParametersNames,parameter));
vals = GTS.ParametersValues(:,Index);


figure; 
subplot(1,2,1)
hold on
scatter(s1(1:end-1,1),s1(1:end-1,2),10,vals);
scatter(s1(end,1),s1(end,2),500,'rx');
cb1 = colorbar();
ylabel(cb1,parameter)
title('L1 Norm')
subplot(1,2,2)
hold on
scatter(s2(1:end-1,1),s2(1:end-1,2),10,vals);
scatter(s2(end,1),s2(end,2),200,'rx');
title('L2 Norm')
cb2 = colorbar();
ylabel(cb2,parameter)

%%
parameter = 'fbedload';
Index = find(contains(GTS.ParametersNames,parameter));
vals = GTS.ParametersValues(:,Index);

s = s1;
cluster1 = s(GTS.Clustering.T == 1,:);
cluster2 = s(GTS.Clustering.T == 2,:);
cluster3 = s(GTS.Clustering.T == 3,:);

v1 = vals(GTS.Clustering.T == 1);
v2 = vals(GTS.Clustering.T == 2);
v3 = vals(GTS.Clustering.T == 3);

figure; 
subplot(1,2,1)

hold on
scatter(cluster1(:,1), cluster1(:,2), 50,v1,'^');
scatter(cluster2(:,1), cluster2(:,2), 50,v2,'o');
scatter(cluster3(:,1), cluster3(:,2), 50,v3,'square');
scatter(s1(end,1),s1(end,2),500,'rx');

cb1 = colorbar();
ylabel(cb1,parameter)
title('L1 Norm')
legend('Cluster 1','Cluster 2', 'Cluster 3', 'Flume')
xlabel(['Dimension 1 (',num2str(round(p1(1),0)),'%)'])
ylabel(['Dimension 2 (',num2str(round(p1(2),0)),'%)'])


subplot(1,2,2)
s = s2;
cluster1 = s(GTS.Clustering.T == 1,:);
cluster2 = s(GTS.Clustering.T == 2,:);
cluster3 = s(GTS.Clustering.T == 3,:);

hold on
scatter(cluster1(:,1), cluster1(:,2), 50,v1,'^');
scatter(cluster2(:,1), cluster2(:,2), 50,v2,'o');
scatter(cluster3(:,1), cluster3(:,2), 50,v3,'square');
scatter(s2(end,1),s2(end,2),200,'rx');
legend('Cluster 1','Cluster 2', 'Cluster 3', 'Flume')
title('L2 Norm')
cb2 = colorbar();
ylabel(cb2,parameter)
xlabel(['Dimension 1 (',num2str(round(p2(1),0)),'%)'])
ylabel(['Dimension 2 (',num2str(round(p2(2),0)),'%)'])

%%

parameter = 'h0';

Index = find(contains(GTS.ParametersNames,parameter));
vals = GTS.ParametersValues(:,Index);

s = s1;
cluster1 = s(GTS.Clustering.T == 1,:);
cluster2 = s(GTS.Clustering.T == 2,:);
cluster3 = s(GTS.Clustering.T == 3,:);

v1 = vals(GTS.Clustering.T == 1);
v2 = vals(GTS.Clustering.T == 2);
v3 = vals(GTS.Clustering.T == 3);

figure; 

hold on
scatter(cluster1(:,2), cluster1(:,1), 50,v1,'^');
scatter(cluster2(:,2), cluster2(:,1), 50,v2,'o');
scatter(cluster3(:,2), cluster3(:,1), 50,v3,'square');
%scatter(s1(end,1),s1(end,2),500,'rx');

colormap('hot')
cb1 = colorbar();
ylabel(cb1,parameter)
title(['Effect of ',parameter, ' on Clustering'])
%legend('Cluster 1','Cluster 2', 'Cluster 3', 'Flume')
legend('Cluster 1','Cluster 2', 'Cluster 3')
ylabel(['Dimension 1 (',num2str(round(p1(1),0)),'%)'])
xlabel(['Dimension 2 (',num2str(round(p1(2),0)),'%)'])

%%
figure; 
cluster1 = s1(GTS.Clustering.T == 1,:);
cluster2 = s1(GTS.Clustering.T == 2,:);
cluster3 = s1(GTS.Clustering.T == 3,:);

hold on
scatter(cluster1(:,2), cluster1(:,1), 50,'r^');
scatter(cluster2(:,2), cluster2(:,1), 50,'go');
scatter(cluster3(:,2), cluster3(:,1), 50,'bs');

legend('Cluster 1','Cluster 2', 'Cluster 3')
ylabel(['Dimension 1 (',num2str(round(p1(1),0)),'%)'])
xlabel(['Dimension 2 (',num2str(round(p1(2),0)),'%)'])
