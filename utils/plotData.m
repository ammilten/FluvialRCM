function [a1,a2] = plotData(data,option,yConst, varargin)

s=size(data.strata);
dz = 0.01 * 0.15; %NOTE THIS DZ DEPENDS ON H0, THIS IS ONLY AN APPROXIMATION

if length(varargin) == 2
    x = varargin{1};
    y = varargin{2};
    z = linspace(-round(s(3)/2)*dz, round(s(3)/2)*dz, s(3));
else
    x = 1:s(2);
    y = 1:s(1);
    z = 1:s(3);
end

    
    %Stratigraphy
a2 = subplot(4,1,4);
    imagesc(x,z*100,flipud(reshape(data.strata(end-yConst,:,:), s(2), s(3))'))
    cbh=colorbar();
    caxis([-1,1])
    set(cbh,'YTick',[-1,0,1], 'YTickLabel',{'n/a', '0', '1'})
    ylabel(cbh,'Sand Fraction')
    title('Stratigraphy')
    xlabel('Distance (m)')
    ylabel('Depth (cm)')
    
    %Surface
a1 = subplot(4,1,[1,2,3]);
    if strcmp(option,'bed_elevation')
        imagesc(x,y,flipud(data.eta)) %bed elevation
        t = 'Bed Elevation (meters above sea level)';
    elseif strcmp(option, 'water_depth')
        imagesc(x,y,flipud(data.h)) %water depth
        t = 'Water Depth';
    elseif strcmp(option, 'discharge')
        imagesc(x,y,flipud(data.qw)) %unit discharge magnitude
        t = 'Unit Discharge Magnitude';
    elseif strcmp(option, 'velocity')
        imagesc(x,y,flipud(data.uw)) %velocity magnitude
        t = 'Velocity Magnitude';
    end
    %title(['t = ',num2str(i)])
    hold on 
    plot(x,y(yConst)+zeros(s(2),1),'-k')
    hold off
    ylabel('Distance (m)')
    set(gca,'XTick',[])
    cbl = colorbar();
    ylabel(cbl, t)
    
    