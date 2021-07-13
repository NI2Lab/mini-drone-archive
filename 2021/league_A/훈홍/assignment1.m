%% 1.한국 원화 단위의 돈을 입력받는다.

prompt = '환전할 금액을 입력해주세요(한국 원화 단위) = ';

x = input(prompt);

%

%% 2. 달러(미국), 유로(유럽), 앤(일본), 위안(중국) 화폐로 환전한다.
%2021년 3월 4일 기준 환율
%1달러 = 1115원
%달러 단위 = 1,2,5,10,20,50,100달러, 1,5,10,25,50센트(1센트=0.01달러)

%1유로 = 1333원
%유로 단위 = 1,2,5,10,20,50,100,200,500유로, 1,2,5,10,20,50센트(1센트=0.01유로)

%1엔 = 10원
%엔 단위=1,5,10,50,100,500,1000,2000,5000,10000엔

%1위안 = 170원
%위안 단위 = 1,5,10,20,50,100위안

ru=1115;
re=1333;
rj=10;
rc=170;

usd=floor(x/ru);
eur=floor(x/re);
jpy=floor(x/rj);
cny=floor(x/rc);

%

%% 3. 최소한의 화페로 환전했을 때 몇장(개)의 화페가 필요한지 출력하는 프로그램을 작성한다.

%1,2,5,10,20,50,100달러

unit_usd = [100, 50, 20, 10 ,5, 2, 1];
unit_eur = [500,200,100,50,20,10,5,2,1];
unit_jpy = [10000, 5000, 2000, 1000, 500, 100, 50, 10, 5, 1];
unit_cny = [100,50,20,10,5,1];

num_usd = min_num(unit_usd,usd);
num_eur = min_num(unit_eur,eur);
num_jpy = min_num(unit_jpy,jpy);
num_cny = min_num(unit_cny,cny);

%check calculation
if usd ~= sum(unit_usd.* num_usd)
    error('false usd')
end
if eur ~= sum(unit_eur.* num_eur)
    error('false usd')
end
if jpy ~= sum(unit_jpy.* num_jpy)
    error('false usd')
end
if cny ~= sum(unit_cny.* num_cny)
    error('false usd')
end

%display result
aa = [unit_usd',num_usd'];
fprintf('usd :\n unit($)  num\n')
disp(aa)

aa = [unit_eur',num_eur'];
fprintf('eur :\n unit(€) num\n')
disp(aa)

aa = [unit_jpy',num_jpy'];
fprintf('jpy :\n      unit(¥)         num\n')
disp(aa)

aa = [unit_cny',num_cny'];
fprintf('cny :\n unit(¥)  num\n')
disp(aa)
