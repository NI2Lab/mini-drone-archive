function EU = changeEUMoney(x)
    exchange_rate = 1340;
    temp = x / exchange_rate;
    B = temp * 100;
    C = fix(B);
    result = C * 0.01;
    fprintf("실제 환전된 금액은 원화 %d원 입니다 \n", result * exchange_rate)
    EU = result;
    fprintf("환전된 달러는 %.3f 유로입니다", EU)
end