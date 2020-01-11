p = '/home/ammilten/Programs/DeltaRCM-master/Data/TDB_12_1/Images';
gr = 'graphs';

f = dir([p,'/',gr,'/*.mat']);

ev = zeros(length(f),1);
evu = ev;
adj = cell(length(f),1);
adju = adj;
for i=1:length(f)
    load([f(i).folder,'/',f(i).name])
    
    A = G.Wred;
    A(A~=0)=1;
    Lu = diag(sum(A,2)) - A;
    vals = eig(Lu);
    evu(i) = vals(2);
    adju{i} = A;
    
    L = diag(sum(G.Wred,2))-G.Wred;
    vals = eig(L);
    ev(i) = vals(2);
    adj{i} = G.Wred;
end



figure; 
histogram(evu)