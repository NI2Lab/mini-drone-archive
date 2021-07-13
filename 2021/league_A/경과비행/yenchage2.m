function yen2=yenchage2(x)

charge=fix(x/10.3);
    M=fix(charge/10000);
    MT=fix((charge-M*10000)/5000);
    T=fix((charge-M*10000-MT*5000)/1000);
    F=fix((charge-M*10000-MT*5000-T*1000)/500);
    m=fix((charge-M*10000-MT*5000-T*1000-F*500)/100);
    f=fix((charge-M*10000-MT*5000-T*1000-F*500-m*100)/50);
    t=fix((charge-M*10000-MT*5000-T*1000-F*500-m*100-f*50)/10);
    o=fix((charge-M*10000-MT*5000-T*1000-F*500-m*100-f*50-10*t)/1);
    
    yen2= M+MT+T+F+m+f+t+o;
    fprintf("최소한의 화폐로 환전했을 때, 화폐는 %d개 입니다. \n", yen2)
    
    