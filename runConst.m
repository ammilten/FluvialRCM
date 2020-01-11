function runConst(NAME, n)
%Runs Monte Carlo Simulation
%Must have PRIOR and SETUP already defined
%Samples prior and runs all simulations
%n=2;
%NAME = 'N0_test';
run('prioruncertainty.m')
VLIST = samplePrior(PRIOR,n);


SETUP = struct(                         ...
    'L',            100,                 ...
    'W',            200,                ...
    'W_m',          10000,        ...
    'totaltime',    5
    'saveInterval', 100,                  ...
    'showPlot',     false                ...
    ); 

%%
mkdir(NAME)
save([NAME,'/mcparams.mat']);

warning('off','all')
messages = cell(n,1);
tic
parfor i=1:n
    disp(['Starting sim',num2str(i)])
    try
        VARS = VLIST{i};
        sim = struct('SETUP',SETUP,'VARS',VARS);
        simname = [NAME,'/sim',num2str(i)];
        t = DRCMtv(sim,simname);
        m = ['Time for sim',num2str(i),': ',num2str(t),' seconds'];
        disp(m)
    catch E
        disp(['Failed: sim',num2str(i)])
        m = E;
    end
    messages{i} = m;
end
totalsimtime = toc

save([NAME,'/mcparams.mat']);

%%
%Save data to one folder
