function [shoremap, shore_image] = flumeShore(BW)
p = '/home/ammilten/Programs/DeltaRCM-master/Tools/DeltaRCM_Metrics';
addpath(p);

TH_ANGLE = 100;

numviews = 2; % This is how many times the opening angle method will "look"
waves= Seaangles_mod(BW,numviews);

%% This extracts the contour line coordinates from the opening angle method
% You need to define the matrix x which will include the xy coordinates of
% the output from the shoreline method (e.g., x =
% waves(1,1).seaangles(:,1:3811)). You need to find where the opening angles
% are not equal to zero in the seaangles matrix (3 - numview rows) and pull
% out those xy coordinates.  The other ones (containing zeros for angle)
% are actually the exteriors of the domain and are unecessary.


x = waves(1,1).seaangles(:,:);
%% Create the file to be contoured (you need to pick the sizes)
shore_image = zeros(size(BW));

for i = 1:size(x,2)
    shore_image(x(2,i),x(1,i)) = x(size(x,1),i);
end

%shore_image(shore_image > 150) = 0;

C=contourc(shore_image,[TH_ANGLE TH_ANGLE]);


shoremap = zeros(size(BW));
for k = 1:size(C,2)
    px = C(2,k); py = C(1,k);
    if px <= size(BW,1) && py <= size(BW,2)
        shoremap(round(px),round(py)) = 1;
    end
end



