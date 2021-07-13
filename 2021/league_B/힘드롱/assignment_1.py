##  please input your code below the current code 

#달러 계산용 함수입니다.
def exchange_dollar(won):
  dollar = won/1121
  dollar = round(dollar,2)
 
  dollar_n = [0,0,0,0,0,0,0,0,0,0,0,0]
  dollar_s = [100, 50, 20, 10, 5, 2, 1, 0.5, 0.25, 0.1, 0.05, 0.01]
  print(f"USD : ${dollar}")

  count_b = 0
  count_c = 0
  
  for i in range(len(dollar_s)):
    if (dollar/dollar_s[i])>=1 :
      dollar_n[i] = int(dollar/dollar_s[i])
      dollar -= dollar_s[i]*dollar_n[i]
      dollar = round(dollar, 2)
      if (dollar_s[i] < 1):
        count_c += dollar_n[i]
        print(f"¢{int(dollar_s[i]*100)}\t: {dollar_n[i]}개")
      else:
        count_b += dollar_n[i]
        print(f"${dollar_s[i]}\t: {dollar_n[i]}장")
  
  print(f"USD 최소 갯수 환전 시 총 {count_b}장, {count_c}개입니다.")

#위안 계산용 함수입니다.
def exchange_yuan(userMoney):
    userMoneyWon = userMoney // 10
    userMoneyWon = userMoneyWon * 10
    count_b = 0
    count_c = 0

    #print(f"환전할 금액 (KRW) : {userMoneyWon}₩")
    userMoneyYuan = round(userMoneyWon * 0.00585, 1)
    print(f"CNY : ¥{userMoneyYuan}")


    userMoneyYuanInt = (int)(userMoneyYuan)
    userMoneyYuanFloat = round(userMoneyYuan - userMoneyYuanInt, 2)
   
    # 위안(지폐 단위) 돈 계산 [100위안, 50위안, 20위안, 10위안, 5위안, 1위안 ]
    for yuan in [100, 50, 20, 10, 5, 1]:
        tempMoney = userMoneyYuanInt // yuan
        if tempMoney != 0:
            print(f"¥{yuan}\t: {tempMoney}장")
            userMoneyYuanInt -= yuan * tempMoney
            count_b += tempMoney
            if userMoneyYuanInt == 0:
                break
        else:
            continue

    #자오(동전 단위) 돈 계산 [5자오(=0.5위안), 1자오(0.1위안)]
    for zuao in [0.5, 0.1]:
        tempMoney = userMoneyYuanFloat // zuao
        if tempMoney != 0:
            print(f"¥{zuao}\t: {int(tempMoney)}개")
            userMoneyYuanFloat -= zuao * tempMoney
            userMoneyYuanFloat = round(userMoneyYuanFloat,2)
            count_c += tempMoney
            if userMoneyYuanFloat == 0:
                break
        else:
            continue

    print(f"CNY 최소 갯수 환전 시 총 {int(count_b)}장, {int(count_c)}개입니다.")

#유로 계산용 함수입니다.
def exchange_euro(userMoney):
    userMoneyWon = userMoney // 10
    userMoneyWon = userMoneyWon * 10
    count_b = 0
    count_c = 0
    #print(f"환전할 금액 (KRW) : {userMoneyWon}₩")
    
    userMoneyEuro = round(userMoneyWon * 0.00075,2)
    print(f"EUR : €{userMoneyEuro}")

    userMoneyEuroInt = int(userMoneyEuro)
    userMoneyEuroFloat = round(userMoneyEuro - userMoneyEuroInt, 2)
   
    for euro in [100, 50, 20, 10, 5,2,1]:
        tempMoney = userMoneyEuroInt // euro
        if tempMoney != 0:
            if euro == 2 or euro == 1:
                count_c += tempMoney
                print(f"€{euro}\t: {tempMoney}개")
            else:
                count_b += tempMoney
                print(f"€{euro}\t: {tempMoney}장")

            userMoneyEuroInt -= euro * tempMoney
            if userMoneyEuroInt == 0:
                break
            
        else:
            continue

    for cent in [0.5, 0.2, 0.1, 0.05, 0.02, 0.01]:
        tempMoney = userMoneyEuroFloat // cent
        if tempMoney != 0:
            count_c += tempMoney
            print(f"c {int(cent*100)}\t: {int(tempMoney)}개")
            
            userMoneyEuroFloat -= cent * tempMoney
            userMoneyEuroFloat = round(userMoneyEuroFloat,2)
            if userMoneyEuroFloat == 0:
                break
        else:
            continue
        
    print(f"EUR 최소 갯수 환전 시 총 {int(count_b)}장, {int(count_c)}개입니다.")

#엔 계산용 함수입니다.
def exchange_yen(a):
  #print(f"환전할 금액 (KRW) : {a}₩")
  en=10.30
  rate=int(a/en)
  count_b = 0
  count_c = 0
  print(f"JPY : ¥{rate}")

  ra=int(rate)
  if(ra>=10000):
    rate_10000 = int(ra/10000)
    ra-=rate_10000*10000
    print(f"¥10000\t: {rate_10000}장")
    count_b += rate_10000

  if(ra>=5000) :
    rate_5000 = int(ra/5000)
    ra-=rate_5000*5000
    print(f"¥5000\t: {rate_5000}장")
    count_b += rate_5000

  if(ra>=2000) :
    rate_2000 = int(ra/2000)
    ra-=rate_2000*2000
    print(f"¥2000\t: {rate_2000}장")
    count_b += rate_2000

  if(ra>=1000) :
    rate_1000 = int(ra/1000)
    ra-=rate_1000*1000
    print(f"¥1000\t: {rate_1000}장")
    count_b += rate_1000

  if(ra>=500) :
    rate_500 = int(ra/500)
    ra-=rate_500*500
    print(f"¥500\t: {rate_500}개")
    count_c += rate_500

  if(ra>=100) :
    rate_100 = int(ra/100)
    ra-=rate_100*100
    print(f"¥100\t: {rate_100}개")
    count_c += rate_100

  if(ra>=50) :
    rate_50 = int(ra/50)
    ra-=rate_50*50
    print(f"¥50\t: {rate_50}개")
    count_c += rate_50

  if(ra>=10) :
    rate_10 = int(ra/10)
    ra-=rate_10*10
    print(f"¥10\t: {rate_10}개")
    count_c += rate_10

  if(ra>=1) :
    rate_1 = int(ra)
    ra-=rate_1
    print(f"¥1\t: {rate_1}개")
    count_c += rate_1

  print(f"JPN 최소 갯수 환전 시 총 {int(count_b)}장, {int(count_c)}개입니다.")



#main 문입니다.
won = int(input("환전할 금액을 입력하세요 : "))
print(f"환전할 금액 (KRW) : {won}₩")
exchange_dollar(won)
exchange_euro(won)
exchange_yen(won)
exchange_yuan(won)

##  end