function combineSims(mcfolderlist, targetname)

%check that all MCParams have the same SETUP, PRIOR
nsims = zeros(length(mcfolderlist),1);
%simtimes = zeros(length(mcfolderlist),1);
%msgs = cell(length(mcfolderlist),1);
VARLIST = cell(length(mcfolderlist),1);

load([mcfolderlist{1},'/mcparams.mat'])
SETUP1 = SETUP;
PRIOR1 = PRIOR;

nsims(1) = n;
%simtimes(1) = totalsimtime;
%msgs{1} = messages;
VARLIST{1} = VLIST;

for i=2:length(mcfolderlist)
    load([mcfolderlist{i},'/mcparams.mat'])
    
    if ~ (isSameSetup(SETUP1,SETUP) && isSamePrior(PRIOR1,PRIOR))
        error('Simulation folders cannot be combined because the SETUP or PRIOR structs are not consistent')
    end
    
    nsims(i) = n;
%     simtimes(i) = totalsimtime;
%     msgs{i} = messages;
    VARLIST{i} = VLIST;
end


%If it's made it this far then the PRIOR and SETUP structs match for all
%listed simulations

%Concatenate to get new mcparams.mat
PRIOR = PRIOR1;
SETUP = SETUP1;
clear PRIOR1 SETUP1 messages n t1 totalsimtime VLIST NAME

n = sum(nsims);
NAME = targetname;
% totalsimtime = sum(simtimes);

messages = cell(n,1);
VLIST = cell(n,1);
st = 0;
for i=1:length(nsims)
    for j=1:nsims(i)
%         messages{j+st} = msgs{i}{j};
        VLIST{j+st} = VARLIST{i}{j};
    end
    st = st + nsims(i);
end

% Copy files over to big folder
mkdir(targetname)

if targetname(end) ~= '/'
    targetname = [targetname,'/'];
end

add = 0;
for i=1:length(nsims)
    simfolders = dir([mcfolderlist{i},'/sim*']);
    simfoldernums = zeros(length(simfolders),1);
    for j=1:length(simfolders)
        simfoldernums(j) = name2num(simfolders(j).name);
    end
    simfoldernums = simfoldernums + add;
    add = add + nsims(i);
    
    for j=1:length(simfolders)
        f_old = [simfolders(j).folder,'/',simfolders(j).name];
        f_new = [targetname,'sim',num2str(simfoldernums(j))];
        copyfile(f_old,f_new)
    end
end

save([targetname,'mcparams.mat'],...
    'n',...
    'PRIOR',...
    'SETUP',...
    'VLIST',...
    'NAME'...
    );
    



