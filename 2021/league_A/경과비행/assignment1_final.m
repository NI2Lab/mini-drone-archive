prompt = "환전할 돈을 입력해주세요(단위 원): ";
K_money = input(prompt);

prompt1 = "\n환전할 나라를 선택해주세요 (미국: 1, 유럽: 2, 일본: 3, 중국: 4): ";
number = input(prompt1);

switch number
    case 1
        dollar = changeUSMoney(K_money)
        n_dollar = showUSMoney(dollar)
        
    case 2
        euro = changeEUMoney(K_money)
        n_euro = showEUMoney(euro)
        
    case 3
        yen = yenchange(K_money)
        n_yen = yenchage2(K_money)
        
    case 4
        wian = exchange2cny(K_money)
        n_wian = minmoney(wian)
end


 
        
        