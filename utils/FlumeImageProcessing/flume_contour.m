clear; close all
target = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images/bw_topoclip';

p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/TDB_12_Dry_z.mat';

load(p)
mkdir(target);
for i=1:900
    tag = ['TDB_12_1_',pad(num2str(i+385),4,'left','0'),'00.jpg'];
    try
        [crop, ~, mask] = topocrop(z,i);
        BW = binarizeColors2(crop);
        imwrite(BW,[target,'/',tag]);
    catch
        disp(['Could not clip ',tag])
    end
end
    
