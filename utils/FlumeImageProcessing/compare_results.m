p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images';
O = 'original';

f = dir([p,'/',O,'/*.jpg']);

set(0,'DefaultFigureWindowStyle','docked')

val = nan(length(f),1);
for i = 1:length(f)
    
    fg = figure;
    try
        subplot(2,1,1)
        plotGraphOnOriginal(f(i).name)
        subplot(2,1,2)
        A = imread([p,'/',gr,'/',f(i).name]);
        imshow(A)

        pause(0.001)

        val(i) = input('1 for good, 0 for bad: ');
    catch
        val(i) = 0;
    end
    close(fg)
        
end

set(0,'DefaultFigureWindowStyle','normal')

