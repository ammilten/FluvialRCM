p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images/graph_topoclip/';

f = dir([p,'*.mat']);

ev2 = zeros(length(f),1);
adj = cell(length(f),1);
for i=1:length(f)
    load([f(i).folder,'/',f(i).name]);
    L = diag(sum(G.Wred,2)) - G.Wred;
    E = eig(L);
    ev2(i) = E(2);
    adj{i} = G.Wred;
end

[P,ev] = ecdf(ev2);


save('ev2vals.mat','ev','adj');


