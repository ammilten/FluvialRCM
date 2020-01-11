function num = name2num(name)

numcell = regexp(name,'\d*','Match');

num = str2double(numcell{1});


