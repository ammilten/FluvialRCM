function class = binarizeColors2(Acrop)

s = size(Acrop);

Acrop2 = reshape(Acrop,s(1)*s(2),3);
outside = sum(Acrop2,2)==0;
Ainside = Acrop2(~outside,:);

[idx, c] = kmeans(double(Ainside),2);

bl = [255-c(:,1),c(:,3)];
bl = vecnorm(bl,2,2);
[~,blueidx] = min(bl);

% cluster = zeros(length(Acrop2),1);
% clusterInside = zeros(length(Ainside),1);
% clusterInside(idx == blueidx) = 1;
% clusterInside(idx ~= blueidx) = 2;
% cluster(~outside) = clusterInside;
% cluster = reshape(cluster,s(1),s(2));


BW = zeros(length(Acrop2),1);
BWinside = idx == blueidx;
BW(~outside) = BWinside;
BW(outside) = 1;

class = reshape(BW,s(1),s(2));