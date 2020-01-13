function f = viewSimulation(mcfolder,simnum,option, varargin)
%simFolder = 'sim8/';

% options: bed_elevation, water_depth, discharge, velocity

simFolder = [mcfolder,'sim',num2str(simnum),'/'];

%% Note that these are hardcoded, it would be better to access these from mcparams.mat
load([mcfolder,'mcparams.mat'])
W_m = SETUP.W_m;
dx = SETUP.W_m/SETUP.W;
L_m = SETUP.L*dx;
dt = SETUP.dt;

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
