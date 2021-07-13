function get_cny(cny)
    yuan=[100,50,20,10,5,1,0.5,0.1];
    num_mon=0;
    
    for i=1:length(yuan)
        if fix(cny/yuan(i))>=1
            num_mon=num_mon+fix(cny/yuan(i)); 
            cny=cny-fix(cny/yuan(i))*yuan(i);
        elseif cny < min(yuan)
            break;
        else
            continue;
        end
    end
    
    fprintf('입력한 원화를 위안화로 환전할 때 필요한 최소의 화폐 개수: %d\n',num_mon);
end