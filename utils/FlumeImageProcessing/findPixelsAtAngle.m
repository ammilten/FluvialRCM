function shore = findPixelsAtAngle(im,ctr,theta,tol)


% A is the image
% ctr is a vector of coordinates of the starting point
% theta is the angle upon which to sample
% tol is the tolerance for pixels to be on the line

s = size(im);

pxs = zeros(numel(s),2);
r = zeros(numel(s),1);
val = zeros(numel(s),1);
ct = 1;
for i = 1:s(1)
    for j = 1:s(2)
        
        r1 = sqrt((i-ctr(1))^2 + (j-ctr(2))^2);
        r2 = (i-ctr(1)) * cos(theta) + (j-ctr(2)) * sin(theta);
        d = sqrt(r2^2 - r1^2);
        
        if d < tol
            pxs(ct,:) = [i,j];
            r(ct) = r1;
            val(ct) = (im(i,j)>100);
            ct = ct + 1;
        end
    end
end
ct = ct-1;

pxs = pxs(1:ct,:);
r = r(1:ct);
val = val(1:ct);

[~,ind] = max(r.*val);
shore = pxs(ind,:);



        