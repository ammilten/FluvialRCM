function class = reduceColors(Acrop)
%This function takes a cropped image and clusters the remaining colors in
%two
s = size(Acrop);

Acrop2 = reshape(Acrop,s(1)*s(2),3);
outside = sum(Acrop2,2)==0;
Ainside = Acrop2(~outside,:);

[idx, c] = kmeans(double(Ainside),2);

for i = 1:max(idx)
    repl = (idx == i);
    Ainside(repl,:) = repmat(c(i,:),sum(repl),1);
end

Acrop2(~outside,:) = Ainside;

class = uint8(reshape(Acrop2,s(1),s(2),s(3)));

        