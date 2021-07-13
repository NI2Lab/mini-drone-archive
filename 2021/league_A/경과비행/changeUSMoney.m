function US = changeUSMoney(x)
    exchange_rate = 1120;
    temp = x / exchange_rate;
    B = temp * 100;
    C = fix(B);
    result = C * 0.01;
    fprintf("실제 환전된 금액은 원화 %d원 입니다 \n", result * exchange_rate)
    US = result;
    fprintf("환전된 달러는 %.3f 달러입니다", US)
end