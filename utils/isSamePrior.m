function issame = isSamePrior(PRIOR1, PRIOR2)
fields1 = fieldnames(PRIOR1);
fields2 = fieldnames(PRIOR2);

if length(fields1) ~= length(fields2)
    error('Priors have different number of variables')
end

for i=1:length(fields1)
    obj1 = getfield(PRIOR1,fields1{i});
    obj2 = getfield(PRIOR2,fields2{i});
    
    type1 = class(obj1);
    type2 = class(obj2);
    
    if ~strcmp(type1,type2)
        error('Priors have different types')
    end
    
    switch type1
        case 'double'
            if ~isequal(obj1,obj2)
                error(['Priors have different values for parameter ',fields1{i}])
            end
        otherwise
            if ~isSameDistribution(obj1,obj2)
                error(['Priors have different values for parameter ',fields1{i}])
            end
    end
end

issame = true;