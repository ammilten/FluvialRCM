function issame = isSameSetup(SETUP1, SETUP2)
issame = false;

fields1 = fieldnames(SETUP1);
fields2 = fieldnames(SETUP2);

if length(fields1) ~= length(fields2)
    error('SETUP structs must have same number of elements')
end

for i=1:length(fields1)
    if ~strcmp(fields1{i}, fields2{i})
        error('Field names do not match')
    end
    
    v1 = getfield(SETUP1,fields1{i});
    v2 = getfield(SETUP2,fields2{i});
    
    if v1 ~= v2
        error(['Value for ',fields1{i},' do not match']);
    end
end
issame = true;



            