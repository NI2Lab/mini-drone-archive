function euro(won)
    rate=1334.22;
    cnt=0;
    euro_kind=[50000 0; 20000 0; 10000 0; 5000 0; 2000 0; 1000 0; 500 0; 200 0; 100 0; 50 0; 20 0; 10 0; 5 0; 2 0; 1 0];  
    euro_cent=won/rate*100;
    for i=1:15
        if euro_cent>=euro_kind(i,1)
            euro_kind(i,2)=fix(euro_cent./euro_kind(i,1));
            euro_cent=rem(euro_cent,euro_kind(i,1));
        end
        cnt=cnt+euro_kind(i,2);
    end
end

function yuan(won)
    rate=171.07;
    cnt=0;
    yuan_kind=[10000 0; 5000 0; 2000 0; 1000 0; 500 0; 100 0; 50 0; 10 0;]; 
    yuan_cent=won/rate*100;
    for i=1:8
        if yuan_cent>=yuan_kind(i,1)
            yuan_kind(i,2)=fix(yuan_cent./yuan_kind(i,1));
            yuan_cent=rem(yuan_cent,yuan_kind(i,1));
        end
        cnt=cnt+yuan_kind(i,2);
    end
end