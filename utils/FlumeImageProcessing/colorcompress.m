function class = colorcompress(path_to_image)

Acrop = cropFlume(path_to_image);

class = reduceColors(Acrop);
%class = binarizeColors(Acrop);