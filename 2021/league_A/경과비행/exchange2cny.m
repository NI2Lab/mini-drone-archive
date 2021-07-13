function china = exchange2cny(x)
    temp1 = x / 171.62;
    temp2 = temp1 * 10;
    temp3 = fix(temp2);
    temp4 = temp3 / 10;
    x = temp4;
    fprintf("실제 환전된 금액은 %d위안 입니다 \n", x)
    
    china = x;
end
