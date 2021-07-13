won = input('한국 원화 단위의 돈을 입력해주세요: ');
fprintf('------------------달러------------------\n');
Dollar(won);
fprintf('------------------ 엔 ------------------\n');
Yen(won);
fprintf('------------------유로------------------\n');
euro(won);
fprintf('------------------위안------------------\n');
yuan(won);
function Dollar(won)
    dollar = fix(won / 11.2112);
    fprintf('달러로 환전한 돈은 %.2f달러입니다.\n',dollar/100);
    dollarKinds = [10000,5000,2000,1000,500,200,100,50,25,10,5,1];
    Dresult = zeros(1,length(dollarKinds));
    for i=1:length(dollarKinds)
        Dresult(i) = fix(dollar / dollarKinds(i));
        if Dresult(i) > 0
            dollar = dollar - fix(dollarKinds(i) * Dresult(i));
            %출력 부분 추가로 나누기
            if Dresult(i)~=0
                if fix(dollarKinds(i)/100)>0
                    fprintf('%d 달러는 %d개입니다\n',dollarKinds(i)/100,Dresult(i));
                else
                    fprintf('%d 센트는 %d개입니다\n',dollarKinds(i),Dresult(i));
                end
            end
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
        if Yresult(i) > 0
            yen = yen - fix(yenKinds(i) * Yresult(i));
            if Yresult(i)~=0
                fprintf('%d 엔은 %d개입니다\n',yenKinds(i),Yresult(i));
            end
        end
        if yen < 0
            break
        end
    end
    total = sum(Yresult);
    fprintf('최소 화폐 갯수는 %d개입니다.\n',total);
end
function euro(won)
rate=1334.22;
cnt=0;
euro_kind=[50000 0; 20000 0; 10000 0; 5000 0; 2000 0; 1000 0; 500 0; 200 0; 100 0; 50 0; 20 0; 10 0; 5 0; 2 0; 1 0];
    
euro_cent=won/rate*100;
fprintf("유로로 환전한 돈은 ");
fprintf('%.3f',won/rate);
fprintf("유로입니다.\n");

for i=1:15
    if euro_cent>=euro_kind(i,1)
        euro_kind(i,2)=fix(euro_cent./euro_kind(i,1));
        euro_cent=rem(euro_cent,euro_kind(i,1));
    end
    
    if(euro_kind(i,2)>0)
        if(euro_kind(i,1)>100)
            fprintf('%d',euro_kind(i,1)/100);
            fprintf(" 유로는 ");
            fprintf('%d',euro_kind(i,2));
            disp(" 개 입니다.");
        end
        if(euro_kind(i,1)<100)
            fprintf('%d',euro_kind(i,1));
            fprintf(" 센트는 ");
            fprintf('%d',euro_kind(i,2));
            disp(" 개 입니다.");
        end
    end
    cnt=cnt+euro_kind(i,2);
end

fprintf("최소 화폐 갯수는 ");
fprintf('%d',cnt);
fprintf("개입니다.\n");
end
function yuan(won)
rate=171.07;
cnt=0;
yuan_kind=[10000 0; 5000 0; 2000 0; 1000 0; 500 0; 100 0; 50 0; 10 0;];
    
yuan_cent=won/rate*100;
fprintf("위안로 환전한 돈은 ");
fprintf('%.2f',yuan_cent/100);
fprintf("위안입니다.\n");

for i=1:8
    if yuan_cent>=yuan_kind(i,1)
        yuan_kind(i,2)=fix(yuan_cent./yuan_kind(i,1));
        yuan_cent=rem(yuan_cent,yuan_kind(i,1));
    end
    
    if(yuan_kind(i,2)>0)
        if(yuan_kind(i,1)>100)
            fprintf('%d',yuan_kind(i,1)/100);
            fprintf(" 위안은 ");
            fprintf('%d',yuan_kind(i,2));
            disp(" 개 입니다.");
        end
        if(yuan_kind(i,1)<100)
            fprintf('%d',yuan_kind(i,1));
            fprintf(" 자오는 ");
            fprintf('%d',yuan_kind(i,2));
            disp(" 개 입니다.");
        end
    end
    cnt=cnt+yuan_kind(i,2);
end

fprintf("최소 화폐 갯수는 ");
fprintf('%d',cnt);
fprintf("개입니다.\n");
end
