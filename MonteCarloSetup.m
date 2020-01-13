%%
run('prioruncertainty.m')

totaltime = 15e3*50; %  1000 time steps 

SETUP = struct(                         ... 
    'L',            50,                 ...
    'W',            50,                ...
    'W_m',          5e3,        ...
    'dt',           15e3,                  ...
    't1',           totaltime*.25,                ...
    't2',           totaltime*.50,            ... 
    't3',           totaltime*.75,             ... 
    't4',           totaltime,            ... 
    'saveInterval', 1,                  ...
    'showPlot',     false                ...
    ); 

dtMax = maxTimeStep(SETUP,PRIOR);
disp(['Max time step: ',num2str(dtMax)])
disp(['Used time step: ',num2str(SETUP.dt)])

%%
alpha_qw = 0.05; %variation around skinnytestskinnytestQw
alpha_qs = 0.05; %variation around Qs
alpha_SLR = 0.05; %variation around SLR

n_qw = 1/2; %Number of cycles for Qw
n_qs = 1/2; %Number of cycles for Qs
n_SLR = 1/2; %Number of cycles for SLR

beta_qw = 0; %Phase offset for Qw
beta_qs = pi; %Phase offset for Qs
beta_SLR = pi/2; %Phase offset for SLR

time = 0:SETUP.dt:totaltime;

Qw = PRIOR.water_supply * (1 + alpha_qw * sin(2*pi*n_qw/totaltime * time + beta_qw));
Qs = PRIOR.sed_supply * (1 + alpha_qs * sin(2*pi*n_qs/totaltime * time + beta_qs));
SLR = PRIOR.SLR * sin(2*pi*n_SLR/totaltime * time + beta_SLR);

% figure;
% plot(time, Qw)
% xlabel('Time (s)')
% ylabel('Water Supply (m^3/s)')
% figure;
% plot(time,Qs)
% xlabel('Time (s)')
% ylabel('Sediment Supply (m^3/s)')
% figure;
% plot(time,SLR)
% xlabel('Time (s)')
% ylabel('Sea Level Rise (m/hr???)')
%%
PRIOR.water_supply = Qw;
PRIOR.sed_supply = Qs;
PRIOR.SLR = SLR;

NAME = 'Data/slopetest';
runMonteCarlo(SETUP, PRIOR, NAME, 1)








