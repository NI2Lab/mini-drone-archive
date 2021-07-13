function get_usd(usd)
    unit = [100, 50, 20, 10, 5, 2, 1, 0.5, 0.25, 0.1, 0.05, 0.01];
    num = zeros(1,length(unit));
    for i=1:length(unit)
        num(i) = floor(usd/unit(i));
        usd = mod(usd,unit(i));
    end
    fprintf('입력한 원화를 달러로 환전할 때 필요한 최소의 화폐 개수: %d\n',sum(num))
%     fprintf('(')
%     for i=1:length(num)
%         if num(i) > 0
%             if i==1
%                 fprintf('100달러: %d개 ',num(i))
%             elseif i==2
%                 fprintf('50달러: %d개 ',num(i))
%             elseif i==3
%                 fprintf('20달러: %d개 ',num(i))
%             elseif i==4
%                 fprintf('10달러: %d개 ',num(i))
%             elseif i==5
%                 fprintf('5달러: %d개 ',num(i))
%             elseif i==6
%                 fprintf('2달러: %d개 ',num(i))
%             elseif i==7
%                 fprintf('1달러: %d개 ',num(i))
%             elseif i==8
%                 fprintf('50센트: %d개 ',num(i))
%             elseif i==9
%                 fprintf('25센트: %d개 ',num(i))
%             elseif i==10
%                 fprintf('10센트: %d개 ',num(i))
%             elseif i==11
%                 fprintf('5센트: %d개 ',num(i))
%             else
%                 fprintf('1센트: %d개 ',num(i))
%             end
%         end
%     end
%     fprintf(')\n')
end