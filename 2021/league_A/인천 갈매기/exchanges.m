function exchanges()
   prompt = '환전할 금액(KRW)를 입력하세요: ';
   krw = input(prompt); 
   % exchange_rates = [USD to KRW, EUR to KRW, JPY to KRW, CNY to KRW]
   exchange_rates = [1121.12, 1334.22, 10.22, 171.08];
   for i=1:length(exchange_rates)
       if i==1
           usd = krw/exchange_rates(i);
       elseif i==2
           eur = krw/exchange_rates(i);
       elseif i==3
           jpy = krw/exchange_rates(i);
       else
           cny = krw/exchange_rates(i);
       end
   end
   get_usd(usd);
   get_eur(eur);
   get_jpy(jpy);
   get_cny(cny);
end

