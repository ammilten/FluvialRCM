function type = TDB(L_cells,W_cells,N0,L0)

%       |------y--------|
%            |-N0-|
% _____________________________   _ --
% |xxxxxxxxxxxx||xxxxxxxxxxxxx|   | L0
% |xxxxx                 xxxxx|   | --
% |xxx                     xxx|   |
% |x                         x|   |
% |                           |   L
% |                           |   |
% |                           |   |
% |                           |   |
% |___________________________|   _
% 
% |------------W--------------|

image_width_m = 2.2; %Width of overhead image
ticklength = .5; %m
x_m =  3.75 * ticklength; %3.5 ticks on top axis before cutoff
y_m = ticklength * 1.5 * sqrt(2); %1.5 ticks along x- and y-axes, find hypotenuse with sqrt(2)
W_m = x_m * sqrt(2); %Total width of sub-basin to be modeled


type_ocean = 0;
type_chn = 1;
type_sed = 2;


% Make sure flanks can be divided in 2 for symmetry
frac_inside = y_m / W_m; %about 3.7 on actual overhead image
ncells_outsides = floor(W_cells - frac_inside * W_cells);
if mod(ncells_outsides,2) == 1
    ncells_outsides = ncells_outsides+1;
end

CTR = floor(W_cells/2);

type = zeros(L_cells,W_cells);
type(1:L0,:) = type_sed; %back wall
type(1:L0,CTR-round(N0/2)+1:CTR-round(N0/2)+N0) = type_chn;
for i=1:L_cells
    for j=1:W_cells
        if i<ncells_outsides/2-j || W_cells-j+1<ncells_outsides/2-i
            type(i,j) = type_sed;
        end
    end
end




