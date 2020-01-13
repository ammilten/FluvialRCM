function simulationTime = FluvRCM(PARAMETERS,simName)
% PARAMETERS: Struct with following properties
%     SETUP:
%         L             Length (y-axis) in grid cells
%         W             Width (x-axis) in grid cells
%         W_m           Total length in x-direction in meters
%         dt            Time step size in hours (or 'default' for 
%                         automatic computation)
%         totaltime     Length of simulation in hours (or timesteps if
%                         dt='default')
%         simName       Name of simulation. A folder with this name will be
%                         created to store results.
%         saveInterval  How many timesteps between saving data
%         showPlot      True or false, whether or not to plot results each
%                         time it's saved
%         
%     VARS:
%         water_supply  Quantity of water at inlet (m^3/s)
%         sed_supply    Quantity of sediment at inlet (kg/s)
%         sed_density   Density of inlet sediment (kg/m^3)
%         SLR           Sea level rise rate (mm/hr)
%         N0            Number of cells at inlet     
%         h0            Height of inlet (m)
%         Np_water      Number of parcels of water
%         Np_sed        Number of parcels of sediment
%         u_max_coef    Coefficient to determine u_max (u_max=u_max_coef*u0)         
%         hB_coef       Factor to determine basin depth from h0. Default 1
%                         (hB=hB_coef*h0)
%         theta_water   Depth depedence (power of h) in routing water parcels
%         theta_sand_c  Factor for depth dependence in routing sand parcels
%         theta_mud_c   Factor for depth dependence in routing mud parcels
%         fsand         Initial fraction of sand?
%         fbedload      Fraction of sediment transported as bedload?
%         beta          Non-linear exponent of sediment flux to flow velocity
%         lambda        "Sedimentation lag" - 1.0 means no lag
%         udm_coef      Factor for mud deposition velocity
%         uds_coef      Factor for sand deposition velocity
%         uem_coef      Factor for mud erosion velocity
%         ues_coef      Factor for sand erosion velocity
%         alpha         Topo diffusion coefficient
%         Nsmooth       Iteration of surface smoothing per time step
%         Csmooth       Center-weighted surface smoothing
%         omega_sfc     Under-relaxation coef for water surface
%         omega_flow    Under-relaxation coef for water flow
%         itermax       Not sure
%         H_SL          Sea-level elevation (m) (downstream boundary condition)
%         gamma         Not sure

%%Properties that vary with time
% SLR is a vector with number of timesteps
% Sed Supply is a vector
% Water supply is a vector
% S0 (maybe) is a vector

plotinterval    = PARAMETERS.SETUP.saveInterval;
showPlot        = PARAMETERS.SETUP.showPlot;
L               = PARAMETERS.SETUP.L;
W               = PARAMETERS.SETUP.W;
W_m             = PARAMETERS.SETUP.W_m; %2.8*sqrt(2)
dt              = PARAMETERS.SETUP.dt; %1
t1              = PARAMETERS.SETUP.t1; %hours
t2              = PARAMETERS.SETUP.t2; %hours
t3              = PARAMETERS.SETUP.t3; %hours
totaltime       = PARAMETERS.SETUP.t4; %hours

water_supply    = PARAMETERS.VARS.water_supply; %1.72e-4
sed_supply      = PARAMETERS.VARS.sed_supply; %3.91e-4
sed_density     = PARAMETERS.VARS.sed_density; %2.648e3
SLR_tv          = PARAMETERS.VARS.SLR; %0 
N0              = round(PARAMETERS.VARS.N0); %3
h0              = PARAMETERS.VARS.h0; %.2
Np_water        = round(PARAMETERS.VARS.Np_water); %2000
Np_sed          = round(PARAMETERS.VARS.Np_sed); %2000
u_max_coef      = PARAMETERS.VARS.u_max_coef; %2.0
hB_coef         = PARAMETERS.VARS.hB_coef; %1.0
hB              = PARAMETERS.VARS.hB;
theta_water     = PARAMETERS.VARS.theta_water; %1
theta_sand      = PARAMETERS.VARS.theta_sand; %2
theta_mud       = PARAMETERS.VARS.theta_mud; %1
f_bedload       = PARAMETERS.VARS.fbedload; %.25
beta            = PARAMETERS.VARS.beta; %3
lambda          = PARAMETERS.VARS.lambda; %1
udm_coef        = PARAMETERS.VARS.udm_coef; %.3
uem_coef        = PARAMETERS.VARS.uem_coef; %1.5
ues_coef        = PARAMETERS.VARS.ues_coef; %1.05
alpha           = PARAMETERS.VARS.alpha; %0.01
Nsmooth         = round(PARAMETERS.VARS.Nsmooth); %10
Csmooth         = PARAMETERS.VARS.Csmooth; %0.9
omega_sfc       = PARAMETERS.VARS.omega_sfc; %0.1
omega_flow      = PARAMETERS.VARS.omega_flow; %0.9
itermax         = round(PARAMETERS.VARS.itermax); %5
H_SL            = PARAMETERS.VARS.H_SL; %0
gamma           = PARAMETERS.VARS.gamma;
S0              = PARAMETERS.VARS.S0;
grade           = PARAMETERS.VARS.grade;

addpath('BasinGeometries/')
[~,msg,~] = mkdir(simName);
% if strcmp(msg,'Directory already exists.')
%     error(msg)
% end

%BEGIN SIMULATION

VER_MATLAB = 1; % 0-old, 1-new
omega_flow_iter = 2*1/itermax;

CTR = floor(W/2);
dx = W_m/W; % (m) not sure the effect
u0 = water_supply/h0/N0/dx; % (m/s) - characteristic flow velocity (also used as inlet channel velocity)
%S0 = 0.0003*f_bedload+0.0001*(1-f_bedload); % characteristic topographic slope

V0 = h0*(dx*dx); % (m^3) reference volume (the volume to fill up a cell to characteristic flow depth
dVs = 0.1*N0*3*V0;

Qw0 = u0*h0*N0*dx;
Qs0 = min(sed_supply ./ sed_density); %m^3/s

qw0 = Qw0/N0/dx; % water unit input discharge
qs0 = Qs0/N0/dx; %m^3/s
Qp_water = Qw0/Np_water; % volume of each water parcel
Vp_sed = dVs/Np_sed; % volume of each sediment parcel

% ------------Time Step-----------------
dt = dt * 3600; %Hours to seconds
dtMax = dVs/Qs0; % time step size (s) %Default mode
if dt > dtMax
    warning(['Time step is larger than recommended. Max time step: ',num2str(dtMax),...
        ' Your time step: ',num2str(dt)])
end
% --------------------------------------

totaltimestep = round(totaltime * 3600 / dt);
t1s = t1 * 3600 / dt;
t2s = t2 * 3600 / dt;
t3s = t3 * 3600 / dt;

GRAVITY = 9.81;
u_max = u_max_coef*u0;
% hB = hB_coef*h0; % (m) basin depth
dry_depth = min(0.1,0.1*h0); % (m) critial depth to switch to "dry" node

% gamma = 0.05;
%gamma = GRAVITY*S0*dx/u0/u0;

% parameters for random walk probability calculation
%theta_sand = theta_sand_c*theta_water; % depth depedence (power of h) in routing sand parcels
%theta_mud = theta_mud_c*theta_water; % depth depedence (power of h) in routing mud parcels

% sediment deposition/erosion related parameters
U_dep_mud = udm_coef*u0;
U_ero_sand = ues_coef*u0;
U_ero_mud = uem_coef*u0;

% topographical diffusion related parameters
N_crossdiff = round(dVs/V0);


% --- storage preparation
eta = zeros(L,W); % bed elevation
H = zeros(L,W); % free surface elevation
h = zeros(L,W); % depth of water
qx = zeros(L,W); % unit discharge vec(x-comp)
qy = zeros(L,W); % unit discharge vec (y-comp)
qw = zeros(L,W); % unit discharge magnitude
ux = zeros(L,W); % velocity vec (x-comp)
uy = zeros(L,W); % velocity vec (y-comp)
uw = zeros(L,W); % velocity magnitude

% --- value definition
SQ05 = sqrt(0.5);
SQ2 = sqrt(2);
dxn_ivec = [1,SQ05,0,-SQ05,-1,-SQ05,0,SQ05]; % E --> clockwise
dxn_jvec = [0,SQ05,1,SQ05,0,-SQ05,-1,-SQ05]; % E --> clockwise
dxn_iwalk = [1,1,0,-1,-1,-1,0,1]; % E --> clockwise
dxn_jwalk = [0,1,1,1,0,-1,-1,-1]; % E --> clockwise
dxn_dist = [1,SQ2,1,SQ2,1,SQ2,1,SQ2];  % E --> clockwise

TRUE = 1;
FALSE = 0;

sfc_visit  = zeros(L,W);
sfc_sum = zeros(L,W);
wall_flag = zeros(L,W);
boundflag = zeros(L,W);
boundflag(L-3:end,:) = 1;
% for i = 1:L
%     for j = 1:W
%         if sqrt((i-3)^2+(j-CTR)^2) > L-5
%             boundflag(i,j) = 1;
%         end
%     end
% end


% --- initial setup
L0 = 3;
type = simpleWall(L,W,N0,L0);
% type = TDB(L,W,N0,L0);

for i = 1:L
    for j = 1:W
        if type(i,j) > 1
            wall_flag(i,j) = TRUE;
        end
    end
end
% --- topo setup
for i = 1:L
    for j = 1:W
        if type(i,j) == 0 % ocean
%             H(i,j) = 0;
            H(i,j) = grade * (L-i) * dx;
%             h(i,j) = hB;
%             h(i,j) = 0;
            h(i,j) = 0;
            
        else
%             H(i,j) = max(0,L0-i)*dx*S0; % wall and channel both
            H(i,j) = max(0,L0-i)*dx*S0 + grade * (L-i) * dx;
            if type(i,j) == 1 % channel
                h(i,j) = h0;
%                 h(i,j) = -grade * (L-i) * dx;
            else
                h(i,j) = 0;
            end
        end
    end
end
eta = H-h;
% --- flow setup
% flow doesn't satisfy mass conservation
for i = 1:L
    for j = 1:W
        if type(i,j) == 1 % channel
            % assuming normal flow in initial channel
            qx(i,j) = qw0(1);
            qy(i,j) = 0;
            qw(i,j) = sqrt(qx(i,j)^2+qy(i,j)^2);
            ux(i,j) = qx(i,j)/h(i,j);
            uy(i,j) = qy(i,j)/h(i,j);
            uw(i,j) = qw(i,j)/h(i,j);
        elseif type(i,j) == 0 % ocean
            % in the ocean only gives flow direction
            % by giving a "false" flow rate at a magnitude smaller than channel
            % to indicate dominant flow direction for weight-by-direction calculation
            qx(i,j) = qw0(1)/5;
            qy(i,j) = 0;
            qw(i,j) = sqrt(qx(i,j)^2+qy(i,j)^2);
            ux(i,j) = qx(i,j)/h(i,j);
            uy(i,j) = qy(i,j)/h(i,j);
            uw(i,j) = qw(i,j)/h(i,j);
        end
    end
end
% --- direction setup
% Nnbr(i,j) and nbr(i,j,k)
Nnbr = zeros(L,W);
nbr = zeros(L,W,8);
% center nodes
for i=2:L-1
    for j=2:W-1
        Nnbr(i,j) = 8;
        for k=1:8
            nbr(i,j,k) = k;
        end
    end
end
% left side
i = 1;
for j=2:W-1
    Nnbr(i,j) = 5;
    for k=1:5
        nbr(i,j,k) = mod(6+k,8);
        if nbr(i,j,k) == 0
            nbr(i,j,k) = 8;
        end
    end
end
% upper side
j = W;
for i=2:L-1
    Nnbr(i,j) = 5;
    for k=1:5
        nbr(i,j,k) = mod(4+k,8);
        if nbr(i,j,k) == 0
            nbr(i,j,k) = 8;
        end
    end
end
% lower side
j = 1;
for i=2:L-1
    Nnbr(i,j) = 5;
    for k=1:5
        nbr(i,j,k) = mod(k,8);
        if nbr(i,j,k) == 0
            nbr(i,j,k) = 8;
        end
    end
end
% lower-left corner
i=1;j=1;
Nnbr(i,j) = 3;
for k=1:3
    nbr(i,j,k) = mod(k,8);
    if nbr(i,j,k) == 0
        nbr(i,j,k) = 8;
    end
end
% upper-left corner
i=1;j=W;
Nnbr(i,j) = 3;
for k=1:3
    nbr(i,j,k) = mod(6+k,8);
    if nbr(i,j,k) == 0
        nbr(i,j,k) = 8;
    end
end

% ============= add subsidence pattern
sigma = zeros(L,W); 
% sigma = zeros(L,W);
% sigma_max = 0.00*h0/1000;
% sigma_min = -0.00*h0/1000;
% for i = L0+1:L
%     for j = 1:W
%         sigma(i,j) = j/W*(sigma_max-sigma_min)+sigma_min;
%     end
% end
% figure
% imagesc(sigma/h0*2000,[0,3])
% axis equal
% colorbar


% % =================== time steps =============================
wet_flag = zeros(L,W);
px_start = 1; % x-axis of inlet cells
py_start = [CTR-round(N0/2)+1:CTR-round(N0/2)+N0]; % y-axis of inlet cells
dxn_iwalk_inlet = dxn_iwalk(1); % x-component of inlet flow direction
dxn_jwalk_inlet = dxn_jwalk(1); % y-component of inlet flow direction
itmax = 2*(L+W);

Hnew = zeros(L,W);
qxn = zeros(L,W);
qyn = zeros(L,W);
qwn = zeros(L,W);
sfc_visit = zeros(L,W);
sfc_sum = zeros(L,W);
prepath_flag = zeros(L,W);

iseq = zeros(itmax,1);
jseq = zeros(itmax,1);

weight = zeros(8,1);
weight_int = zeros(8,1);
weight_sfc = zeros(8,1);
dxn = zeros(8,1);
weight_val = zeros(8,1);

qs_x = zeros(L,W);
qs_y = zeros(L,W);
qs = zeros(L,W);

timestep = 0;

% prepare for recording strata
z0 = H_SL-h0*2; % bottom layer ELEVATION
dz = 0.01*h0; % layer thickness
% totalSLR = max(SLR_tv) * totaltime / 1000;
totalSLR = max(cumsum(SLR_tv));
zmax = round((H_SL+totalSLR+S0*L/4*dx-z0)/dz); % max layer NUMBER
strata0 = -1; % default value in strata as "none"
strata = ones(L,W,zmax)*strata0; % initialize strata storage matrix
% initialize the surface layer NUMBER
topz = zeros(L,W);
for i = 1:L
    for j = 1:W
        zn = round((eta(i,j)-z0)/dz);
        zn = max(1,zn);
        topz(i,j) = zn;
        topz(i,j) = min(zmax,topz(i,j));
    end
end
strata_age = zeros(L,W);

sand_frac = 0.5+zeros(L,W);
Vp_dep_sand = zeros(L,W);
Vp_dep_mud = zeros(L,W);


tic
while timestep < totaltimestep

    timestep = timestep+1;
    u0 = water_supply(timestep)/h0/N0/dx; 
    qw0 = u0*h0;
    Qw0 = u0*h0*N0*dx;
    Qp_water = Qw0/Np_water; % volume of each water parcel
    u_max = u_max_coef*u0;
    U_dep_mud = udm_coef*u0;
    U_ero_sand = ues_coef*u0;
    U_ero_mud = uem_coef*u0;

    qs0 = sed_supply(timestep) / sed_density / N0 / dx;
    SLR = SLR_tv(timestep);
    
%     if timestep < t1s
%         qs0 = sed_supply(1) / sed_density / N0 / dx;
%         SLR = SLR_tv(1);
%     elseif timestep >= t1s && timestep < t2s
%         qs0 = sed_supply(2) / sed_density / N0 / dx;
%         SLR = SLR_tv(2);
%     elseif timestep >= t2s && timestep < t3s
%         qs0 = sed_supply(3) / sed_density / N0 / dx;
%         SLR = SLR_tv(3);
%     elseif timestep >= t3s
%         qs0 = sed_supply(4) / sed_density / N0 / dx;
%         SLR = SLR_tv(4);
%     end

    % ============= Water Routing & Free Surface =============
    for iter = 1:itermax
        % =========== water parcels ===========
        qxn = 0*qxn;
        qyn = 0*qyn;
        qwn = 0*qwn;

        wet_flag = 0*wet_flag;
        for i = 1:L
            for j = 1:W
                if h(i,j) >= dry_depth
                    wet_flag(i,j) = 1;
                end
            end
        end

        Hnew = 0*Hnew;
        sfc_visit = 0*sfc_visit;
        sfc_sum = 0*sfc_sum;

        for np = 1:Np_water
            prepath_flag = 0*prepath_flag; % "pre"-path refers to one parcel
            iseq = 0*iseq;
            jseq = 0*jseq;
            water_continue = TRUE;
            sfccredit = TRUE;

            if mod(np,100) == 0
                np;
            end

            px = px_start;
            if VER_MATLAB == 0
                py = py_start(randi(1,1,[1,length(py_start)]));
            else
                py = py_start(randi([1,length(py_start)],1,1)); % Draw random element from py_start
            end
            qxn(px,py) = qxn(px,py)+dxn_iwalk_inlet;
            qyn(px,py) = qyn(px,py)+dxn_jwalk_inlet;
            qwn(px,py) = qwn(px,py)+Qp_water/dx/2;
%             if px == 1 || px == L
%                 disp('issue with px')
%             elseif py == 1 || py == W
%                 disp('issue with py')
%             end

            it = 1;
            iseq(it) = px;
            jseq(it) = py;
            while water_continue == TRUE && it < itmax

                prepath_flag(px,py) = 1;
                it = it+1;

                % ========== calculate routing weights =========
                nk = Nnbr(px,py);
                weight = 0*weight;
                weight_int = 0*weight_int;
                weight_sfc = 0*weight_sfc;
                weight_val = 0*weight_val;
                for k = 1:nk
                    dxn(k) = nbr(px,py,k);
                end


                % calculate weight_int and weight_sfc
                for k = 1:nk
                    pxn = px+dxn_iwalk(dxn(k));
                    pyn = py+dxn_jwalk(dxn(k));
                    dist = dxn_dist(dxn(k));

                    if wet_flag(pxn,pyn) == 1 && wall_flag(pxn,pyn) == 0
                        weight_sfc(k) = max(0,H(px,py)-H(pxn,pyn))/dist;
                        weight_int(k) = max(0,qx(px,py)*dxn_ivec(dxn(k))+qy(px,py)*dxn_jvec(dxn(k)))/dist;
                    end
                end

                % normalize and calculate weight
                if sum(weight_sfc) ~= 0
                    % require that weightsfc >= 0
                    weight_sfc = weight_sfc/sum(weight_sfc);
                end
                if sum(weight_int) ~= 0
                    % require that weightint >= 0
                    weight_int = weight_int/sum(weight_int);
                end
                weight = gamma*weight_sfc + (1-gamma)*weight_int;
                for k = 1:nk
                    pxn = px+dxn_iwalk(dxn(k));
                    pyn = py+dxn_jwalk(dxn(k));
                    dist = dxn_dist(dxn(k));

                    if wet_flag(pxn,pyn) == 1 %&& wall_flag(pxn,pyn) == 0
                        weight(k) = h(pxn,pyn)^theta_water*weight(k);
                    end
                end                
                % if weight is not all zeros
                if sum(weight) > 0
                    weight = weight/sum(weight);
                    % choose target cell by probability
                    for k = 1:nk
                        weight_val(k) = sum(weight(1:k));
                    end
                    step_rand = rand();
                    for k = 1:nk
                        if step_rand < weight_val(k)
                            istep = dxn_iwalk(dxn(k));
                            jstep = dxn_jwalk(dxn(k));
                            break
                        end
                    end
                end
                % if weight is all zero, do a random walk
                % if weight is all zero, do a random walk
                if sum(weight) == 0
                    if VER_MATLAB == 0
                        pxn = px+randi(1,1,[-1,1]);
                        pyn = py+randi(1,1,[-1,1]);
                    else
                        pxn = px+randi([-1,1],1,1);
                        pyn = py+randi([-1,1],1,1);
                    end
                    
                    pxn = max(1,pxn);
                    pyn = max(1,pyn);
                    pxn = min(size(wet_flag,1),pxn);
                    pyn = min(size(wet_flag,2),pyn);
                    
                    ntry = 0;
                    while wet_flag(pxn,pyn) == 0 && ntry < 5
                        ntry = ntry+1;
                        if VER_MATLAB == 0
                            pxn = px+randi(1,1,[-1,1]);
                            pyn = py+randi(1,1,[-1,1]);
                            pxn = max(1,pxn);
                        else
                            pxn = px+randi([-1,1],1,1);
                            pyn = py+randi([-1,1],1,1);
                            pxn = max(1,pxn);
                        end
                        pxn = max(1,pxn);
                        pyn = max(1,pyn);
                        pxn = min(size(wet_flag,1),pxn);
                        pyn = min(size(wet_flag,2),pyn);
           
                    end
                    istep = pxn-px;
                    jstep = pyn-py;
                end
            % got istep, jstep
                pxn = px+istep;
                %pxn = max(1,pxn); %%%%HACK TO ENSURE NONZERO VALUE
                %pxn = min(L,pxn); %%%%HACK TO ENSURE WITHIN BOUNDS
                pyn = py+jstep;
                %pyn = max(1,pyn); %%%%HACK TO ENSURE NONZERO VALUE
                %pyn = min(W,pyn); %%%%HACK TO ENSURE WITHIN BOUNDS
                
                dist = sqrt(istep^2+jstep^2);
                if dist > 0
                    qxn(px,py) = qxn(px,py)+istep/dist;
                    qyn(px,py) = qyn(px,py)+jstep/dist;
                    qwn(px,py) = qwn(px,py)+Qp_water/dx/2;
                    qxn(pxn,pyn) = qxn(pxn,pyn)+istep/dist;
                    qyn(pxn,pyn) = qyn(pxn,pyn)+jstep/dist;
                    qwn(pxn,pyn) = qwn(pxn,pyn)+Qp_water/dx/2;
                end
                px = pxn;
                py = pyn;
                iseq(it) = px;
                jseq(it) = py;
                % deal with loops
                % deal with loops
                if prepath_flag(px,py) == TRUE && it > L0
                    sfccredit = FALSE;
                    Fx = px-1;
                    Fy = py-CTR;
                    Fw = sqrt(Fx.^2+Fy.^2);
                    px = px+round(Fx/Fw*5);
                    py = py+round(Fy/Fw*5);
                    px = max(px,L0+1); px = min(L-1,px);
                    py = max(2,py); py = min(W-1,py);
                end
                if boundflag(px,py) == TRUE
                    water_continue = FALSE;
                    itend = it;
                end
            end
            if dist > 0
                qxn(px,py) = qxn(px,py)+istep/dist;
                qyn(px,py) = qyn(px,py)+jstep/dist;
                qwn(pxn,pyn) = qwn(pxn,pyn)+Qp_water/dx/2;
            end

            % =========== calculate free surface =============
            % calcuate free surface along one water parcel path
            % not update yet
            itback = itend; %size(iseq,2);
            if boundflag(iseq(itback),jseq(itback)) == TRUE && sfccredit == TRUE
                Hnew(iseq(itback),jseq(itback)) = H_SL;
                it0 = 0;
                Ldist = 0;
                for it = itback-1:-1:1
                    i = iseq(it); 
                    ip = iseq(it+1);
                    j = jseq(it);
                    jp = jseq(it+1);
                    dist = ((ip-i)^2+(jp-j)^2)^0.5;

                    if dist > 0
                        if it0 == 0
                            if uw(i,j) > u0*0.5 || h(i,j) < 0.1*h0 %see if it is shoreline
                                it0 = it;
                            end
                            dH = 0;
                        else
                            if uw(i,j) == 0
                                dH = 0;
                            else
%                                 % if use backwater profile
%                                 Fr2 = uw(i,j)^2/GRAVITY/h(i,j);
%                                 if Fr2_loc < 0.7^2
%                                     dH = Cf/GRAVITY/h(i,j)*uw(i,j)*(ux(i,j)*(ip-i)*dx+uy(i,j)*(jp-j)*dx);
%                                     dH = Cf*Fr2*(ux(i,j)*(ip-i)*dx+uy(i,j)*(jp-j)*dx)/uw(i,j);
%                                     dH = dH+(eta(ip,jp)-eta(i,j));
%                                     dH = dH/(1-Fr2);
%                                     dH = dH+eta(i,j)-eta(ip,jp);
%                                 else
%                                     dH = Cf*Fr2*dx*(ux(i,j)*(ip-i)+uy(i,j)*(jp-j))/uw(i,j);
%                                 end
                                % if use constant slope
                                dH = S0*(ux(i,j)*(ip-i)*dx+uy(i,j)*(jp-j)*dx)/uw(i,j);
                            end
                        end
                    end
                    Hnew(i,j) = Hnew(ip,jp)+dH;
                    sfc_visit(i,j) = sfc_visit(i,j)+1;
                    sfc_sum(i,j) = sfc_sum(i,j)+Hnew(i,j);
                end
            end
        end % --- end of one individual water parcel, go to next parcel

        % ======= all water parcels are done, update surface
        % update free surface
        Hnew = eta+h;
        Hnew = max(Hnew,H_SL);
        for i = 1:L
            for j = 1:W
                if sfc_visit(i,j) > 0
                    Hnew(i,j) = sfc_sum(i,j)/sfc_visit(i,j);
                end
            end
        end
        Htemp = Hnew; % smoother is applied to newly calculated free surface Hnew
        for itsmooth = 1:Nsmooth
            Hsmth = Htemp;
            for i = 1:L
                for j = 1:W
                    if boundflag(i,j) ~= 1 %&& wet_flag(i,j) == 1
                        sumH = 0;
                        nbcount = 0;
                        for k = 1:Nnbr(i,j)
                            dxn(k) = nbr(i,j,k);
                            inbr = i+dxn_iwalk(dxn(k));
                            jnbr = j+dxn_jwalk(dxn(k));
                            if wall_flag(inbr,jnbr) == 0
                                sumH = sumH+Hsmth(inbr,jnbr);
                                nbcount = nbcount+1;
                            end
                        end
                        if nbcount == 0
        %                     sprintf('nbcount is zero @ (%d, %d)',i,j)
                        else
                            Htemp(i,j) = Csmooth*Hsmth(i,j)+(1-Csmooth)*sumH/nbcount;
                        end
                    end
                end
            end
        end
        Hsmth = Htemp;
        if timestep > 1
            H = (1-omega_sfc)*H+omega_sfc*Hsmth; 
        end

        %  flooding/dry-wet correction
        for i = 1:L
            for j = 1:W
                if wet_flag(i,j) == 0 % locate dry nodes
                    for k = 1:Nnbr(i,j)
                        dxn(k) = nbr(i,j,k);
                        inbr = i+dxn_iwalk(dxn(k));
                        jnbr = j+dxn_jwalk(dxn(k));
                        if wet_flag(inbr,jnbr) == 1 && H(inbr,jnbr)>eta(i,j)
                            H(i,j) = H(inbr,jnbr);
                        end
                    end
                end
            end
        end

        h = max(0,H-eta);

        % ======= update flow field and velocity field ======
        % update flow field
        for i = 1:L
            for j = 1:W
                dloc = sqrt(qxn(i,j)^2+qyn(i,j)^2);
                if dloc > 0
                    qxn(i,j) = qwn(i,j)*qxn(i,j)/dloc;
                    qyn(i,j) = qwn(i,j)*qyn(i,j)/dloc;
                end
            end
        end
        if timestep > 1
            if iter == 1
                qx = qxn*omega_flow+qx*(1-omega_flow);
                qy = qyn*omega_flow+qy*(1-omega_flow);
            else
                qx = qxn*omega_flow_iter+qx*(1-omega_flow_iter);
                qy = qyn*omega_flow_iter+qy*(1-omega_flow_iter);
            end    
        else
            qx = qxn;
            qy = qyn;
        end
        qw = (qx.^2+qy.^2).^0.5; 

        % apply upstream constant flux boundary condition
        qx(px_start,py_start) = qw0;
        qy(px_start,py_start) = 0;
        qw(px_start,py_start) = qw0;
        % update velocity field
        for i = 1:L
            for j = 1:W
                if h(i,j) > dry_depth && qw(i,j) > 0
                    uw(i,j) = min(u_max,qw(i,j)/h(i,j));
                    ux(i,j) = uw(i,j)*qx(i,j)/qw(i,j);
                    uy(i,j) = uw(i,j)*qy(i,j)/qw(i,j);
                else
                    ux(i,j) = 0;
                    uy(i,j) = 0;
                    uw(i,j) = 0;
                end
            end
        end

    end

    % ============== sediment transport ==============
    qs = 0*qs;
    Vp_dep_sand = 0*Vp_dep_sand;
    Vp_dep_mud = 0*Vp_dep_mud;
    
    for np_sed = 1:Np_sed*f_bedload
        Vp_res = Vp_sed;
        
        itmax = 2*(L+W);
        
        px = px_start;
        if VER_MATLAB == 0
            py = py_start(randi(1,1,[1,length(py_start)]));
        else
            py = py_start(randi([1,length(py_start)],1,1));
        end
        qs(px,py) = qs(px,py)+Vp_res/2/dt/dx;

        it = 1;
        iseq(it) = px;
        jseq(it) = py;
        sed_continue = TRUE;
        while sed_continue == TRUE && it < itmax
            clear weight
            it = it+1;
            
            % ======== decide the next step
            % get local out dxns 1:k
            nk = Nnbr(px,py);
            weight = zeros(nk,1);
            for k = 1:nk
                dxn(k) = nbr(px,py,k);
            end
           
            for k = 1:nk
                pxn = px+dxn_iwalk(dxn(k));
                pyn = py+dxn_jwalk(dxn(k));
                dist = dxn_dist(dxn(k));
                weight(k) = (max(0,qx(px,py)*dxn_ivec(dxn(k))+qy(px,py)*dxn_jvec(dxn(k))))^1.0*...
                    h(pxn,pyn)^theta_sand/dist;
                if wet_flag(pxn,pyn) ~= 1
                    weight(k) = 0; % doesn't allow dry nodes
                end
                if wall_flag(pxn,pyn) ~= 0
                    weight(k) = 0; % doesn't allow wall nodes
                end
            end
            if sum(weight) == 0 
                for k = 1:nk
                    pxn = px+dxn_iwalk(dxn(k));
                    pyn = py+dxn_jwalk(dxn(k));
                    dist = dxn_dist(dxn(k));

                    weight(k) = 1/dist;
                    if wall_flag(pxn,pyn) == TRUE
                        weight(k) = 0;
                    end
                end
            end

            weight = weight/sum(weight);
            
            for k = 1:nk
                weight_val(k) = sum(weight(1:k));
            end
            step_rand = 1-rand();
            for k = 1:nk
                if step_rand < weight_val(k)
                    istep = dxn_iwalk(dxn(k));
                    jstep = dxn_jwalk(dxn(k));
                    break
                end
            end
            dist = sqrt(istep^2+jstep^2);

            if dist > 0
                qs(px,py) = qs(px,py)+Vp_res/2/dt/dx;
            end % exit accumulation
            
            px = px+istep;
            py = py+jstep;

            if dist > 0
                qs(px,py) = qs(px,py)+Vp_res/2/dt/dx;
            end % entry accumulation            

            % =========== deposition and erosion at one step
            U_loc = uw(px,py);
            qs_cap = qs0*f_bedload/u0^beta*U_loc^beta;
%             qs_cap = qs0/u0^beta*U_loc^beta;
            qs_loc = qs(px,py);
            eta_change_loc = 0;
            Vp_dep = 0;
            Vp_ero = 0;
            if qs_loc > qs_cap
                Vp_dep = min(Vp_res,(H(px,py)-eta(px,py))/4*(dx*dx));
                
                eta_change_loc = Vp_dep/(dx*dx);
                eta(px,py) = eta(px,py)+eta_change_loc;
                h(px,py) = max(0, H(px,py) - eta(px,py));
                uw(px,py) = min(u_max,qw(px,py)/h(px,py));
                if qw(px,py) > 0
                    ux(px,py) = uw(px,py)*qx(px,py)/qw(px,py);
                    uy(px,py) = uw(px,py)*qy(px,py)/qw(px,py);
                else
                    ux(px,py) = 0;
                    uy(px,py) = 0;
                end
                Vp_res = Vp_res-Vp_dep;
            elseif U_loc > U_ero_sand && qs_loc < qs_cap
                Vp_ero = Vp_sed*(U_loc^beta-U_ero_sand^beta)/U_ero_sand^beta;
                Vp_ero = min(Vp_ero,(H(px,py)-eta(px,py))/4*(dx*dx));
                
                eta_change_loc = -Vp_ero/(dx*dx);
                eta(px,py) = eta(px,py)+eta_change_loc;
                h(px,py) = max(0, H(px,py) - eta(px,py));
                uw(px,py) = min(u_max,qw(px,py)/h(px,py));
                if qw(px,py) > 0
                    ux(px,py) = uw(px,py)*qx(px,py)/qw(px,py);
                    uy(px,py) = uw(px,py)*qy(px,py)/qw(px,py);
                else
                    ux(px,py) = 0;
                    uy(px,py) = 0;
                end
                Vp_res = Vp_res+Vp_ero;
            end
            Vp_dep_sand(px,py) = Vp_dep_sand(px,py)+Vp_dep;
            
            if boundflag(px,py) == TRUE
                sed_continue = FALSE;
            end
        end % --- end of one individual sediment parcel
    end % --- end of all sediment parcels
    
    % ---- topo diffusion after all sand/coarse sediment parcels
    for crossdiff = 1:N_crossdiff
        eta_diff = eta;
        for i = 2:L-1
            for j = 2:W-1
                if boundflag(i,j) == 0 && wall_flag(i,j) == 0
                    crossflux = 0;
                    for k = 1:Nnbr(i,j)
                        dxn(k) = nbr(i,j,k);
                        inbr = i+dxn_iwalk(dxn(k));
                        jnbr = j+dxn_jwalk(dxn(k));
                        if wall_flag(inbr,jnbr) == 0
                            crossflux_nb = dt/N_crossdiff*alpha*0.5*(qs(i,j)+qs(inbr,jnbr))*dx*(eta(inbr,jnbr)-eta(i,j))/dx;
                            crossflux = crossflux+crossflux_nb;
                            
                            eta_diff(i,j) = eta_diff(i,j)+crossflux_nb/dx/dx;
                        end
                    end

                end
            end
        end
        eta = eta_diff;
    end
    for np_sed = 1:Np_sed*(1-f_bedload) % start mud/fine parcels
        Vp_res = Vp_sed;
        
        itmax = 2*(L+W);
        if mod(np_sed,100) == 0
            np_sed;
        end
        
        px = px_start;
        if VER_MATLAB == 0
            py = py_start(randi(1,1,[1,length(py_start)]));
        else
            py = py_start(randi([1,length(py_start)],1,1));
        end

        it = 1;
        iseq(it) = px;
        jseq(it) = py;
        sed_continue = TRUE;
        while sed_continue == TRUE && it < itmax
            clear weight
            it = it+1;
            
            % ======== decide the next step
            % get local out dxns 1:k
            nk = Nnbr(px,py);
            weight = zeros(nk,1);
            for k = 1:nk
                dxn(k) = nbr(px,py,k);
            end
           
            for k = 1:nk
                pxn = px+dxn_iwalk(dxn(k));
                pyn = py+dxn_jwalk(dxn(k));
                dist = dxn_dist(dxn(k));
                % ------- both theta_sq and theta_sh participate in the
                % calculation
                weight(k) = (max(0,qx(px,py)*dxn_ivec(dxn(k))+qy(px,py)*dxn_jvec(dxn(k))))^1.0*...
                    h(pxn,pyn)^theta_mud/dist;
                if wet_flag(pxn,pyn) ~= 1
                    weight(k) = 0; % doesn't allow dry nodes
                end
                if wall_flag(pxn,pyn) ~= 0
                    weight(k) = 0; % doesn't allow wall nodes
                end
            end
            if sum(weight) == 0 
                for k = 1:nk
                    pxn = px+dxn_iwalk(dxn(k));
                    pyn = py+dxn_jwalk(dxn(k));
                    dist = dxn_dist(dxn(k));

                    weight(k) = 1/dist;
                    if wall_flag(pxn,pyn) == TRUE
                        weight(k) = 0;
                    end
                end
            end

            weight = weight/sum(weight);
            
            for k = 1:nk
                weight_val(k) = sum(weight(1:k));
            end
            step_rand = 1-rand();
            for k = 1:nk
                if step_rand < weight_val(k)
                    istep = dxn_iwalk(dxn(k));
                    jstep = dxn_jwalk(dxn(k));
                    break
                end
            end
            dist = sqrt(istep^2+jstep^2);

            
            px = px+istep;
            py = py+jstep;


            % =========== deposition and erosion at one step
            U_loc = uw(px,py);
            eta_change_loc = 0;
            Vp_dep = 0;
            Vp_ero = 0;
            if U_loc < U_dep_mud
                Vp_dep = lambda*Vp_res*(U_dep_mud^beta-U_loc^beta)/(U_dep_mud^beta);
                Vp_dep = min(Vp_dep,(H(px,py)-eta(px,py))/4*(dx*dx));
                
                eta_change_loc = Vp_dep/(dx*dx);
                eta(px,py) = eta(px,py)+eta_change_loc;
                h(px,py) = max(0, H(px,py) - eta(px,py));
                uw(px,py) = min(u_max,qw(px,py)/h(px,py));
                if qw(px,py) > 0
                    ux(px,py) = uw(px,py)*qx(px,py)/qw(px,py);
                    uy(px,py) = uw(px,py)*qy(px,py)/qw(px,py);
                else
                    ux(px,py) = 0;
                    uy(px,py) = 0;
                end
                Vp_res = Vp_res-Vp_dep;
            end
            if U_loc > U_ero_mud
                Vp_ero = Vp_sed*(U_loc^beta-U_ero_mud^beta)/U_ero_mud^beta;
                Vp_ero = min(Vp_ero,(H(px,py)-eta(px,py))/4*(dx*dx));
                
                eta_change_loc = -Vp_ero/(dx*dx);
                eta(px,py) = eta(px,py)+eta_change_loc;
                h(px,py) = max(0, H(px,py) - eta(px,py));
                uw(px,py) = min(u_max,qw(px,py)/h(px,py));
                if qw(px,py) > 0
                    ux(px,py) = uw(px,py)*qx(px,py)/qw(px,py);
                    uy(px,py) = uw(px,py)*qy(px,py)/qw(px,py);
                else
                    ux(px,py) = 0;
                    uy(px,py) = 0;
                end
                Vp_res = Vp_res+Vp_ero;
            end
            Vp_dep_mud(px,py) = Vp_dep_mud(px,py)+Vp_dep;
            
            if boundflag(px,py) == TRUE
                sed_continue = FALSE;
            end
        end % --- end of one individual sediment parcel
    end % --- end of all sediment parcels
    
    
    for i = 1:L
        for j = 1:W
            if Vp_dep_sand(i,j) > 0
                sand_frac(i,j) = Vp_dep_sand(i,j)/(Vp_dep_mud(i,j)+Vp_dep_sand(i,j));
            elseif Vp_dep_mud(i,j) > 0
                sand_frac(i,j) = 0;
            end
        end
    end
    
    for px = 1:L
        for py = 1:W
            zn = round((eta(px,py)-z0)/dz);
            zn = max(1,zn);
            if zn >= topz(px,py)
                for z = topz(px,py):zn
                    strata(px,py,z) = sand_frac(px,py);
                end
            else
                for z = zn:topz(px,py)
                    strata(px,py,z) = -1;
                end
                sand_frac(px,py) = strata(px,py,max(1,z-1));
            end
            topz(px,py) = zn;
        end
    end
    
    % ============== apply subsidence
%     if timestep > 1000
%         eta = eta - sigma;
%         h = H-eta;
%         strata_new = strata;
%         for i = 1:L
%             for j = 1:W
%                 zn = max(0,round((eta(i,j)-z0)/dz));
%                 if zn < topz(i,j)
%                     strata_new(i,j,zn+1:zmax) = strata0;
%                     if zn > 0
%                         strata_new(i,j,1:zn) = strata(i,j,topz(i,j)-(zn-1):topz(i,j));
%                     end
%                 end
%                 topz(i,j) = zn;
%             end
%         end
%         strata = strata_new;
%     end

    %  flooding/dry-wet correction
    for i = 1:L
        for j = 1:W
            if wet_flag(i,j) == 0 % locate dry nodes
                for k = 1:Nnbr(i,j)
                    dxn(k) = nbr(i,j,k);
                    inbr = i+dxn_iwalk(dxn(k));
                    jnbr = j+dxn_jwalk(dxn(k));
                    if wet_flag(inbr,jnbr) == 1 && H(inbr,jnbr)>eta(i,j)
                        H(i,j) = H(inbr,jnbr);
                    end
                end
            end
        end
    end
%    h = H-eta; % no need to update velocities because they are not used in the following updates
    h = max(0,H-eta); % This version ensures that h (water depth) stays positive, so when raised to the power of theta_mud etc. no imaginary numbers are created
    
    % upstream boundary condition - constant depth
    eta(px_start,py_start) = H(px_start,py_start)-h0;
    
    H_SL = H_SL+SLR/1000*dt/3600;
    
    if ~isreal(eta)
        error(['bed elevation became complex on iteration ', num2str(timestep)])
    end
    
    if mod(timestep,plotinterval) == 0
        if showPlot
            figure(2)
            imagesc(eta,[-12.0,1.0]*h0/5)
            colormap(gray)
            axis equal
            colorbar
            title('bed elevation')
        end
        
        clear data
        data.eta = eta;
        data.h = h;
        data.qw = qw;
        data.uw = uw;
        data.strata = strata;
        save(sprintf('%s/data%s',simName,num2str(timestep,'%04.f')),'data')
    end
    
end
simulationTime = toc;
