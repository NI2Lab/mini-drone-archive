% 역할 분담 : 선영 - 달러/유로 환전 함수, 종훈 - 메인 코드, 위안/엔 환전 함수
%% won 단위의 돈을 각 나라 화폐로 환전하여 필요한 화폐의 최소 개수를 출력하는 함수
function exchange2
    ex_rate_lst=[0.00089, 0.00075, 0.0058, 0.098];   % [달러, 유로, 위안, 엔] 환율
    
    Dollar_unit = [100 50 20 10 5 2 1 0.5 0.25 0.1 0.05 0.01];           % 미국 화폐 단위
    Eur_unit=[500 200 100 50 20 10 5 2 1 0.5 0.2 0.1 0.05 0.02 0.01];    % 유럽 화폐 단위
    yuan_unit=[100 50 20 10 5 1 0.5 0.1];                  % 중국 화폐 단위
    yen_unit=[10000 5000 2000 1000 500 100 50 10 5 1];    % 일본 화폐 단위
    
    won=input('원화 단위의 돈을 입력하세요:');
    exchanger(won, Dollar_unit, ex_rate_lst(1), "달러")
    exchanger(won, Eur_unit, ex_rate_lst(2), "유로")
    exchanger(won, yuan_unit, ex_rate_lst(3), "위안")
    exchanger(won, yen_unit, ex_rate_lst(4), "엔")
end

%% 각 나라의 화폐를 환전하여 필요한 최소의 화폐 개수를 출력하는 함수
function exchanger(won, unit, ex_rate, name)
    % 각 화폐의 최소 단위보다 작은 수는 어차피 for 문 이후에 나머지로 남아 처리가 되지 않으므로 환전 시 소수점 3번째 자리에서 반올림
    ex_money=round(won*ex_rate, 3);
    fprintf("****************************************\n");
    fprintf("환전 : %.2f %s\n", ex_money, name);
    count=0;
    for i=1:size(unit,2)
       q=fix(ex_money/unit(i));                 % 몫을 계산
       count=count+q;                           % 필요한 최소 화폐 수 카운트
       ex_money=round(ex_money-q*unit(i), 3);   % 잔금 계산
       fprintf("%.2f%s %d개/ ", unit(i), name, q);
    end
    fprintf("\n총 지폐 개수 : %d개\n",count);
end 
