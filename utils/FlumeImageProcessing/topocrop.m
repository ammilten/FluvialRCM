function [cropped, original, mask] = topocrop(z, hr)


zend = reshape(z(900,:,:),size(z,2),size(z,3));
zin = zend==0;
%% 
SL = (hr-1)*.25;
z2 = reshape(z(hr,:,:),size(z,2),size(z,3));
z2(zin)=nan;
z2 = z2';

%%
num = (hr-1) + 385;
tag = ['TDB_12_1_',pad(num2str(num),4,'left','0'),'00.jpg'];
base = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images/original/';
p2 = [base,tag];
original = imread(p2);


%%
%Stretch to match up corners
stretch = 240/168;
z3 = imresize(z2,[round(size(z2,1) * stretch), round(size(z2,2)*stretch)]);

%Pad top and left sides
tpad = 45;
lpad = 45;
z3 = [nan(tpad,size(z3,2));z3];
z3 = [nan(size(z3,1),lpad),z3];

%Trim image to match z3
cropped = double(original(1:size(z3,1),1:size(z3,2),:));

mask = z3 > SL;
for i = 1:3
    cropped(:,:,i) = mask.* cropped(:,:,i);
end

cropped = [uint8(cropped);zeros(size(original,1)-size(cropped,1),size(cropped,2),3)];
mask = [mask;zeros(size(original,1)-size(mask,1),size(mask,2))];

