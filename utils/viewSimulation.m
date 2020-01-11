function f = viewSimulation(simFolder,option, varargin)
%simFolder = 'sim8/';

% options: bed_elevation, water_depth, discharge, velocity

%% Note that these are hardcoded, it would be better to access these from mcparams.mat
W_m = 2.6;
L_m = 1.3;
dt = 1/4;

%% Movie with stratigraphy evolution
files = dir([simFolder,'*.mat']);

f=figure;
for i=1:length(files)
    load([simFolder, '/', files(i).name])
    s=size(data.strata);
    
    if isempty(varargin)
        yConst = round(s(1) / 2);
    else
        yConst = varargin{1};
    end
    
    plotData(data,option,yConst, 0:W_m/(s(2)-1):W_m, 0:L_m/(s(1)-1):L_m);
    %plotData(data,option,yConst);
    time = round(name2num(files(i).name) * dt);
    title(['t = ',num2str(time), ' hours'])
    %caxis([-0.15,0.3])
    pause(.001)

end

end
