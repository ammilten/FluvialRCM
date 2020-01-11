function Acrop = cropFlume(path_to_image)
%This function loads the preset cropping and uses it to remove the
%boundaries of the specified flume image

load('flumecrop.mat','cropfilter')

A = imread(path_to_image);
s = size(A);

Acrop = double(A).*repmat(cropfilter,1,1,3);

