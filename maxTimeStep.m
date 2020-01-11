function dtMax_hours = maxTimeStep(SETUP, VARS)


W               = SETUP.W;
W_m             = SETUP.W_m; %2.8*sqrt(2)
dt              = SETUP.dt; %1


water_supply    = VARS.water_supply; %1.72e-4
sed_supply      = VARS.sed_supply; %3.91e-4
sed_density     = VARS.sed_density; %2.648e3
N0              = round(VARS.N0); %3
h0              = VARS.h0; %.2


dx = W_m/W; % (m) not sure the effect
u0 = water_supply/h0/N0/dx; % (m/s) - characteristic flow velocity (also used as inlet channel velocity)
%S0 = 0.0003*f_bedload+0.0001*(1-f_bedload); % characteristic topographic slope

V0 = h0*(dx*dx); % (m^3) reference volume (the volume to fill up a cell to characteristic flow depth
dVs = 0.1*N0*3*V0;

Qw0 = u0*h0*N0*dx;
Qs0 = min(sed_supply ./ sed_density); %m^3/s

% ------------Time Step-----------------
dt = dt * 3600; %Hours to seconds
dtMax_seconds = dVs/Qs0; % time step size (s) %Default mode
dtMax_hours = dtMax_seconds / 3600;
% --------------------------------------
