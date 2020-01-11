function [BWclipped, im] = findShoreline(path)


A = imread(path);

[cA,~,~,~] = dwt2(A>100,'sym4','mode','per');

BW1 = cA > 1;
BWsmooth = imgaussfilt(double(BW1),5);
BW2 = BWsmooth > .5;
BW = bwareaopen(~BW2,250);

[sm, im] = flumeShore(~BW);

mask = imfill(sm)-sm;

BWclipped = ~BW .* mask;

