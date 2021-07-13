function Dollar(won)
    dollar = fix(won / 11.2112);
    fprintf('달러로 환전한 돈은 %.2f달러입니다.\n',dollar/100);
    dollarKinds = [10000,5000,2000,1000,500,200,100,50,25,10,5,1];
    Dresult = zeros(1,length(dollarKinds));
    for i=1:length(dollarKinds)
        Dresult(i) = fix(dollar / dollarKinds(i));
        if Dresult(i) > 0
            dollar = dollar - fix(dollarKinds(i) * Dresult(i));
        end
        if dollar < 0
            break
        end
    end
    total = sum(Dresult);
    fprintf('최소 화폐 갯수는 %d개입니다.\n',total);
end
function Yen(won)
    yen = fix(won / 11.2112);
    fprintf('엔으로 환전한 돈은 %d엔입니다.\n',int32(yen));
    yenKinds = [10000,5000,2000,1000,500,100,50,10,5,1];
    Yresult = zeros(1,length(yenKinds));
    for i=1:length(yenKinds)
        Yresult(i) = fix(yen / yenKinds(i));
        if yen < 0
            break
        end
    end
    total = sum(Yresult);
    fprintf('최소 화폐 갯수는 %d개입니다.\n',total);
end