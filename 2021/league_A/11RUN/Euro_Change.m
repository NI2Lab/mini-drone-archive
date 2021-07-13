function [Euro_Array,Ucount] = Euro_Change(won)
    Euro = [won * 0.00075];
    Euro_Array = "유로";
    sub = sprintf("%d 원은 %d 유로 입니다.",won,Euro);
    Euro_Array = [Euro_Array, sub];    
    Ucount = 0;
    num = [];
    i=1;
     type = [500,200,100,50,20,10,5,2,1,0.5,0.2,0.1,0.05,0.02,0.01];
    for c = [500,200,100,50,20,10,5,2,1,0.5,0.2,0.1,0.05,0.02,0.01]
        Quotient = fix(Euro/c);
        Euro = rem(Euro,c);
        Ucount = Ucount+Quotient;    
        num(i) = Quotient;
        i=i+1;
    end

   
    %% 각 화폐별 개수 표시
        for j=1:7;   
        if 1<= num(j)
            Euro_count = num(j);
            Euro_type = type(j);
            ans2 = sprintf('%d 유로 지폐는 %d장 필요합니다.', Euro_type, Euro_count );
            Euro_Array=[Euro_Array, ans2];
        end
    end
    
     for j=8:9;   
        if 1<= num(j)
            Euro_count = num(j);
            Euro_type = type(j);
            ans2 = sprintf('%d 유로 동전은 %d개 필요합니다.', Euro_type, Euro_count );            
            Euro_Array=[Euro_Array, ans2];
        end
     end    
     
     for j=10:15;   
        if 1<= num(j)
            Cent_count = num(j);
            Cent_type = type(j);
            Cent_type = Cent_type * 100;
            ans2 = sprintf('%d 센트 동전은 %d개 필요합니다.', Cent_type, Cent_count );            
            Euro_Array=[Euro_Array, ans2];
        end
     end    
     
     
         
     
    
    
    Euro_Array=[Euro_Array]';
    
end