
function [Yuan_Array,Ycount] = Yuan_Change(won)
    yuan = [won * 0.0058];
    Yuan_Array = "위안";
    sub = sprintf("%d 원은 %d 위안 입니다.",won,yuan);
    Yuan_Array = [Yuan_Array, sub];    
    Ycount = 0;
    num = [];
    i=1;
     type = [100,50,20,10,5,1,0.5,0.1];
    for c = [100,50,20,10,5,1,0.5,0.1]
        Quotient = fix(yuan/c);
        yuan = rem(yuan,c);
        Ycount = Ycount+Quotient;    
        num(i) = Quotient;
        i=i+1;
    end

   
    %% 각 화폐별 개수 표시
        for j=1:6;   
        if 1<= num(j)
            yuan_count = num(j);
            yuan_type = type(j);
            ans2 = sprintf('%d 위안 지폐는 %d장 필요합니다.', yuan_type, yuan_count );
            Yuan_Array=[Yuan_Array, ans2];
        end
    end
    
     for j=7:8;   
        if 1<= num(j)
            jiao_count = num(j);
            jiao_type = type(j);
            jiao_type = jiao_type * 10;
            ans2 = sprintf('%d 자오 동전은 %d개 필요합니다.', jiao_type, jiao_count );            
            Yuan_Array=[Yuan_Array, ans2];
        end
     end    
         
     
    
    
    Yuan_Array=[Yuan_Array]';
    
end