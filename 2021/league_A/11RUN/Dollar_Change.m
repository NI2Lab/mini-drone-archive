
function [Dollar_Array,Dcount] = Dollar_Change(won)
    dollar = [won * 0.00089];
    Dollar_Array = "달러";
    sub = sprintf("%d 원은 %d 달러 입니다.",won,dollar);
    Dollar_Array = [Dollar_Array, sub];   
    Dcount = 0;    
    num = [];
    i=1;
    type = [100, 50,20,10,5,2,1,0.5,0.25,0.1,0.05,0.01];
    for c = [100, 50,20,10,5,2,1,0.5,0.25,0.1,0.05,0.01]
        Quotient = fix(dollar/c);
        dollar = rem(dollar,c);
        Dcount = Dcount+Quotient;    
        num(i) = Quotient;
        i=i+1;
    end

   
    %% 각 화폐별 개수 표시
    for j=1:7   
        if 1<= num(j)
            dollar_count = num(j);
            dollar_type = type(j);
            ans2 = sprintf("%d 달러 지폐는 %d장 필요합니다.", dollar_type, dollar_count );           
            Dollar_Array = [Dollar_Array, ans2];            
        end
    end
    
     for j=8:12   
        if 1<= num(j)
            cent_count = num(j);
            cent_type = type(j);
            cent_type = cent_type * 100;
            ans2 = sprintf("%d 센트 동전은 %d개 필요합니다.", cent_type, cent_count );            
            Dollar_Array = [Dollar_Array, ans2];              
        end
     end
    
    Dollar_Array=[Dollar_Array]';    
end
