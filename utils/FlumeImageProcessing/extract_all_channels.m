p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images';
target = [p, '/chan'];
mkdir(target)

load('flumecrop.mat')
f = dir([p,'/bw2/*.jpg']);

for i = 1:length(f)
    path = [f(i).folder,'/',f(i).name];
    [A,~] = findShoreline(path);
    imwrite(A,[target,'/',f(i).name]);
end

