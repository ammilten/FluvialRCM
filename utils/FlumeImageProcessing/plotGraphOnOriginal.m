function plotGraphOnOriginal(name)
p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images';
gr = 'graph_topoclip';
O = 'original';

gmat = [p,'/',gr,'/',name(1:end-4),'.mat'];
o = [p,'/',O,'/',name];
   
load(gmat);
orig = imread(o);

nVertices = size(G.Wred,1);

fig = figure;
hold on;
for j = 1:nVertices
    h = plot(nan,nan);
    cc{j} = get(h,'color'); % get standard Matlab colors
end
close(fig)


imshow(orig, 'InitialMagnification', 'fit')
hold on

g = plot(graph(G.Wred), 'Ydata', G.Y(:,1), 'Xdata', G.Y(:,2), 'NodeLabel', []);
for j = 1:nVertices
   highlight(g, j, 'markersize', G.mu(j)*200); 
   highlight(g, j, 'NodeColor', cc{j}); 
   %text(Y(j,2), Y(j,1), num2str(j));
end
[I,J] = find(G.Wred);
scale = max(G.Wred(:));
for j = 1:length(I)
    highlight(g, I(j), J(j), 'LineWidth', 10/scale*G.Wred(I(j), J(j)))
    highlight(g, I(j), J(j), 'EdgeColor', [1 .2 0])
end