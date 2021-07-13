function get_eur(eur)
    unit = [500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01];
    num = zeros(1,length(unit));
    for i=1:length(unit)
        num(i) = floor(eur/unit(i));
        eur = mod(eur,unit(i));
    end
    fprintf('입력한 원화를 유로로 환전할 때 필요한 최소의 화폐 개수: %d\n',sum(num))
%     fprintf('(')
%     for i=1:length(num)
%         if num(i) > 0
%             if i==1
%                 fprintf('500유로: %d개 ',num(i))
%             elseif i==2
%                 fprintf('200유로: %d개 ',num(i))
%             elseif i==3
%                 fprintf('100유로: %d개 ',num(i))
%             elseif i==4
%                 fprintf('50유로: %d개 ',num(i))
%             elseif i==5
%                 fprintf('20유로: %d개 ',num(i))
%             elseif i==6
%                 fprintf('10유로: %d개 ',num(i))
%             elseif i==7
%                 fprintf('5유로: %d개 ',num(i))
%             elseif i==8
%                 fprintf('2유로: %d개 ',num(i))
%             elseif i==9
%                 fprintf('1유로: %d개 ',num(i))
%             elseif i==10
%                 fprintf('50센트: %d개 ',num(i))
%             elseif i==11
%                 fprintf('20센트: %d개 ',num(i))
%             elseif i==12
%                 fprintf('10센트: %d개 ',num(i))
%             elseif i==13
%                 fprintf('5센트: %d개 ',num(i))
%             elseif i==14
%                 fprintf('2센트: %d개 ',num(i))
%             else
%                 fprintf('1센트: %d개 ',num(i))
%             end
%         end
%     end
%     fprintf(')\n')
end