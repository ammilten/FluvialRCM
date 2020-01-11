clear; close all

p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images/bw2/TDB_12_1_001300.jpg';
tic
[A, im] = findShoreline(p);
t = toc
figure; 
subplot(1,2,1)
imagesc(A)
subplot(1,2,2)
imagesc(im)

%%

