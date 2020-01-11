p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images';
target = [p,'/graph_topoclip'];
mkdir(target);

f = dir([p,'/bw_topoclip/*.jpg']);

for i = 1:length(f)
    try
        path = [f(i).folder,'/',f(i).name];
        G = channelGraph(path,target,f(i).name);
    catch
        disp(['Could not compute graph for ',f(i).name])
    end
end

