%This script takes the imagesc and isolates only the channel networks for
%construction of graphs


clear; close all
p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images';
im = '/TDB_12_1_013125.jpg';

A1 = imread([p,'/bw',im]);
A2 = imread([p,'/bw2',im]);

B1 = A1 > 100;
B2 = A2 < 100;
D = (A1 < 100) -(A2 > 100);

figure;
subplot(1,3,1)
imagesc(B1)
subplot(1,3,2)
imagesc(B2)
subplot(1,3,3)
imagesc(~or(and(~B1,~B2),B2))
