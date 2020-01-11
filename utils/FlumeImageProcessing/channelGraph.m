function G = channelGraph(path,savepath, name)
tosave = 1;

p = '/home/ammilten/Programs/DeltaRCM-master/MonteCarlo/SensitivityAnalysis/Distances/metrics/mapper';
addpath(p)

nV = 10;

A=imread(path);
BW = A < 100;
G = topoMapper3D(BW,[],nV,tosave);

impath = [savepath,'/',name(1:end-4),'.jpg'];
saveas(gcf,impath,'jpg');

matpath = [savepath,'/',name(1:end-4),'.mat'];
save(matpath,'G');

close all