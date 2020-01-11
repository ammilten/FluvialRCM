function BW = colorbinarize(path_to_image)

%im = cropFlume(path_to_image);
im = imread(path_to_image);
%class = reduceColors(Acrop);
BW = binarizeColors2(im);