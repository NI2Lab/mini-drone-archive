function china1 = minmoney(z1)

    temp1 = fix(z1/100);
    temp1_1 = z1 - temp1*100;
    temp2 = fix(temp1_1/50);
    temp2_2 = temp1_1 - temp2*50;
    temp3 = fix(temp2_2/20);
    temp3_3 = temp2_2 - temp3*20;
    temp4 = fix(temp3_3/10);
    temp4_4 = temp3_3 - temp4*10;
    temp5 = fix(temp4_4/5);
    temp5_5 = temp4_4 - temp5*5;
    temp6 = fix(temp5_5/1);
    temp6_6 = temp5_5 - temp6*1;
    temp7 = fix(temp6_6/0.5);
    temp7_7 = temp6_6 - temp7*0.5;
    temp8 = fix(temp7_7/0.1);
    temp8_8 = temp7_7 - temp8*0.1;
    
    china1 = temp1 + temp2 + temp3 + temp4 + temp5+ temp6 + temp7 + temp8;
     fprintf("최소한의 화폐로 환전했을 때, 화폐는 %d개 입니다. \n", china1)
end