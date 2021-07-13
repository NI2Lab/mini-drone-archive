function get_jpy(jpy)
    yen=[10000,5000,2000,1000,500,100,50,10,5,1];
    num_mon=0;
    
    for i=1:length(yen)
        if fix(jpy/yen(i))>=1
            num_mon=num_mon+fix(jpy/yen(i)); %fix는 버림을 위한 함수 
            jpy=jpy-fix(jpy/yen(i))*yen(i);
        elseif jpy < min(yen)
            break;  
        else
            continue;
       end
    end
    
    fprintf('입력한 원화를 엔화로 환전할 때 필요한 최소의 화폐 개수: %d\n',num_mon);
end