function issame = isSameDistribution(obj1, obj2)

fields1 = fieldnames(obj1);
fields2 = fieldnames(obj2);


if length(fields1) ~= length(fields2)
    error('Distribution objects do not have same number of fields')
end

for i=1:length(fields1)
    prop1 = getfield(obj1,fields1{i});
    prop2 = getfield(obj2,fields2{i});
    type1 = class(prop1);
    type2 = class(prop2);
    
    if ~strcmp(type1, type2)
        error('Distribution objects have different fields')
    end
    
    msg = 'Distributions have different values';
    switch type1
        case 'double'
            if ~isequal(prop1,prop2)
                error(msg)
            end
        case {'string', 'char'}
            if ~strcmp(prop1, prop2)
                error(msg)
            end
        case 'cell'
            if length(prop1) ~= length(prop2)
                error(msg)
            end
            for j=1:length(prop1)
                t1 = class(prop1{j});
                t2 = class(prop2{j});
                
                if ~strcmp(t1,t2)
                    error(msg)
                end
                if ~strcmp(prop1{j}, prop2{j})
                    error(msg)
                end
            end
        case 'logical'
            if prop1 ~= prop2
                error(msg)
            end
        otherwise
            error('Type not recognized')
    end
end


issame = true;
                    
