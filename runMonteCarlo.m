function runMonteCarlo(SETUP, PRIOR, NAME, n)

VLIST = samplePrior(PRIOR,n);

%%
mkdir(NAME)
save([NAME,'/mcparams.mat']);

warning('off','all')
messages = cell(n,1);
tic
for i=1:n
    disp(['Starting sim',num2str(i)])
    try
        VARS = VLIST{i};
        sim = struct('SETUP',SETUP,'VARS',VARS);
        simname = [NAME,'/sim',num2str(i)];
        t = FluvRCM(sim,simname);
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
