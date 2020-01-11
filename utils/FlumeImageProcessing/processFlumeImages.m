p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images';
target = [p, '/bw_topoclip'];
mkdir(target)

load('flumecrop.mat')
f = dir([p,'/topoclip/*.jpg']);

for i = 1:length(f)
    path = [f(i).folder,'/',f(i).name];
    try
        comp = colorbinarize(path);
        imwrite(comp,[target,'/',f(i).name]);
    catch
        disp(['Could not process ', f(i).name]);
    end
end


