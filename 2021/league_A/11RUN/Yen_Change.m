function [Yen_Array,Ecount] = Yen_Change(won)
    yen = [won * 0.097];
    Yen_Array = "엔";
    sub = sprintf("%d 원은 %d 엔 입니다.",won,yen);
    Yen_Array = [Yen_Array, sub];    
    Ecount = 0;
    num = [];
    i=1;
     type = [10000,5000,2000,1000,500,100,50,10,5,1];
    for c = [10000,5000,2000,1000,500,100,50,10,5,1]
        Quotient = fix(yen/c);
        yen = rem(yen,c);
        Ecount = Ecount+Quotient;    
        num(i) = Quotient;
        i=i+1;
    end

   
    %% 각 화폐별 개수 표시
        for j=1:4;   
        if 1<= num(j)
            yen_count = num(j);
            yen_type = type(j);
            ans2 = sprintf('%d 엔 지폐는 %d장 필요합니다.', yen_type, yen_count );
            Yen_Array=[Yen_Array, ans2];
        end
    end
    
     for j=5:10;   
        if 1<= num(j)
            yen_count = num(j);
            yen_type = type(j);
            ans2 = sprintf('%d 엔 동전은 %d개 필요합니다.', yen_type, yen_count );            
            Yen_Array=[Yen_Array, ans2];
        end
     end    
         
     
    
    
    Yen_Array=[Yen_Array]';
    
end