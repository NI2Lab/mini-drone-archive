clc
clear

%% KRW
KRW=input('How much money do you want to exchange(KRW)? ');

%% USD

% USD Dollar Unit
% 1, 2, 5, 10, 20 ,50 ,100
% 4/18 USD Exchange Rate 1 USD = 1,234.30 KRW
% USDER : Exchange Rate in USD
USDER=1234.30;

USD=KRW/USDER;
fprintf(['USD : %f'],USD);
% Matrix D : Unit of Dollar
% D_count : The number of dollar pieces
% D100 : The number of 100 dollar pieces
% D50 : The number of 50 dollar pieces
% D20 : The number of 20 dollar pieces
% D10 : The number of 10 dollar pieces
% D5 : The number of 5 dollar pieces
% D2 : The number of 2 dollar pieces
% D1 : The number of 1 dollar pieces

D=[100 50 20 10 5 2 1];
nD=length(D);

for k=1:nD
    d(k)=mod(USD,D(k));
    D_count(k)=(USD-d(k))/D(k);
    USD=USD-D_count(k)*D(k);
end

D100=D_count(1);
D50=D_count(2);
D20=D_count(3);
D10=D_count(4);
D5=D_count(5);
D2=D_count(6);
D1=D_count(7);

%USD Total : Total number of dollar pieces
USD_Total=D100+D50+D20+D10+D5+D2+D1;
%% EUR

% EUR Euro Unit
% 5, 10, 20, 50, 100, 200 ,500
% 4/18 EUR Exchange Rate 1 EUR = 1,331.90 EUR
% EURER : Exchange Rate in EUR
EURER=1331.90;

EUR=KRW/EURER;
fprintf(['\nEUR : %f'],EUR);
% Matrix E : Unit of Euro
% E_count : The number of Euro pieces
% E500 : The number of 500 Euro pieces
% E200 : The number of 200 Euro pieces
% E100 : The number of 100 Euro pieces
% E50 : The number of 50 Euro pieces
% E20 : The number of 20 Euro pieces
% E10 : The number of 10 Euro pieces
% E5 : The number of 5 Euro pieces

E=[500 200 100 50 20 10 5];
nE=length(E);

for k=1:nE
    e(k)=mod(EUR,E(k));
    E_count(k)=(EUR-e(k))/E(k);
    EUR=EUR-E_count(k)*E(k);
end

E500=E_count(1);
E200=E_count(2);
E100=E_count(3);
E50=E_count(4);
E20=E_count(5);
E10=E_count(6);
E5=E_count(7);

%EUR Total : Total number of euro pieces
EUR_Total=E500+E200+E100+E50+E20+E10+E5;
%% JPY

% JPY Yen Unit
% 1000 2000 5000 10000
% 4/18 JPY Exchange Rate 1 JPY = 9.75 KRW
% JPYER : Exchange Rate in JPY
JPYER=9.75;

JPY=KRW/JPYER;
fprintf(['\nJPY : %f'],JPY);
% Matrix J : Unit of Yen
% J_count : The number of Yen pieces
% J10000 : The number of 10000 Yen pieces
% J5000 : The number of 5000 Yen pieces
% J2000 : The number of 2000 Yen pieces
% J1000 : The number of 1000 Yen pieces

J=[10000 5000 2000 1000];
nJ=length(J);

for k=1:nJ
    y(k)=mod(JPY,J(k));
    J_count(k)=(JPY-y(k))/J(k);
    JPY=JPY-J_count(k)*J(k);
end

J10000=J_count(1);
J5000=J_count(2);
J2000=J_count(3);
J1000=J_count(4);

%JPY Total : Total number of Yen pieces
JPY_Total=J10000+J5000+J2000+J1000;
%% CNY

% CNY Yuan Unit
% 1 2 5 10 20 50 100
% 4/18 CNY Exchange Rate 1 CNY = 193.90 KRW
% CNYER : Exchange Rate in CNY

CNYER=193.90;

CNY=KRW/CNYER;
fprintf(['\nCNY : %f'],CNY);
% Matrix C : Unit of Yuan
% C_count : The number of Yuan pieces
% C100 : The number of 100 Yuan pieces
% C50 : The number of 50 Yuan pieces
% C20 : The number of 20 Yuan pieces
% C10 : The number of 10 Yuan pieces
% C5 : The number of 5 Yuan pieces
% C2 : The number of 2 Yuan pieces
% C1 : The number of 1 Yuan pieces

C=[100 50 20 10 5 2 1];
nC=length(C);

for k=1:nC
    c(k)=mod(CNY,C(k));
    C_count(k)=(CNY-c(k))/C(k);
    CNY=CNY-C_count(k)*C(k);
end

C100=C_count(1);
C50=C_count(2);
C20=C_count(3);
C10=C_count(4);
C5=C_count(5);
C2=C_count(6);
C1=C_count(7);

%CNY Total : Total number of Yuan pieces
CNY_Total=C100+C50+C20+C10+C5+C2+C1;
%% Total result
fprintf(['\nTotal number of USD Dollars pieces is %f pieces.' ...
    '\nTotal number of EUR Euros pieces is %f pieces.' ...
    '\nTotal number of JPY Yen pieces is %f pieces.' ...
    '\nTotal number of CNY Yuan pieces is %f pieces.'],USD_Total,EUR_Total,JPY_Total,CNY_Total);
