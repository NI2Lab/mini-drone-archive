
def calc_exchange(KRW, USD_rate = -1, EUR_rate = -1, JPY_rate = -1, CNY_rate = -1):
    # USD
    if USD_rate != -1:
        USD_num_arr = [] # 12개 # 100 / 50 / 20 / 10 / 5 / 2 / 1 / 0.50 / 0.25 / 0.10 / 0.05 / 0.01
        USD = KRW / USD_rate
        print('USD : ', USD)
        # 0인덱스가 몫, 1인덱스가 나머지
        USD_num_arr.append(divmod(USD, 100)[0]); usd_100 = divmod(USD, 100)[1]
        USD_num_arr.append(divmod(usd_100, 50)[0]) ; usd_50 = divmod(usd_100, 50)[1]
        USD_num_arr.append(divmod(usd_50, 20)[0]) ; usd_20 = divmod(usd_50, 20)[1]
        USD_num_arr.append(divmod(usd_20, 10)[0]) ; usd_10 = divmod(usd_20, 10)[1]
        USD_num_arr.append(divmod(usd_10, 5)[0]) ; usd_5 = divmod(usd_10, 5)[1]
        USD_num_arr.append(divmod(usd_5, 2)[0]) ; usd_2 = divmod(usd_5, 2)[1]
        USD_num_arr.append(divmod(usd_2, 1)[0]) ; usd_1 = divmod(usd_2, 1)[1]
        USD_num_arr.append(divmod(usd_1, 0.5)[0]) ; usd_P50 = divmod(usd_1, 0.5)[1]
        USD_num_arr.append(divmod(usd_P50, 0.25)[0]) ; usd_P25 = divmod(usd_P50, 0.25)[1]
        USD_num_arr.append(divmod(usd_P25, 0.10)[0]) ; usd_P10 = divmod(usd_P25, 0.10)[1]
        USD_num_arr.append(divmod(usd_P10, 0.05)[0]) ; usd_P05 = divmod(usd_P10, 0.05)[1]
        USD_num_arr.append(divmod(usd_P05, 0.01)[0]) ; usd_P01= divmod(usd_P05, 0.01)[1]
        USD_num_arr = [int(i) for i in USD_num_arr]

        return f"100달러:{USD_num_arr[0]} / 50달러:{USD_num_arr[1]} / 20달러:{USD_num_arr[2]} / 10달러:{USD_num_arr[3]} / 5달러:{USD_num_arr[4]} / 2달러:{USD_num_arr[5]} / 1달러:{USD_num_arr[6]} / 50센트:{USD_num_arr[7]} / 25센트:{USD_num_arr[8]} / 10센트:{USD_num_arr[9]} / 5센트:{USD_num_arr[10]} / 1센트:{USD_num_arr[11]} \n남은 금액 : {usd_P01}" ,int(sum(USD_num_arr))

    # EUR
    elif EUR_rate != -1:
        EUR_num_arr = []  # 15개 # 500 / 200 / 100 / 50 / 20 / 10 / 5 / 2 / 1 / 0.5 / 0.2 / 0.1 / 0.05 / 0.02 / 0.01
        EUR = KRW / EUR_rate
        print('EUR : ', EUR)

        # 0인덱스가 몫, 1인덱스가 나머지
        EUR_num_arr.append(divmod(EUR, 500)[0]); eur = divmod(EUR, 500)[1]
        EUR_num_arr.append(divmod(eur, 200)[0]); eur = divmod(eur, 200)[1]
        EUR_num_arr.append(divmod(eur, 100)[0]); eur = divmod(eur, 100)[1]
        EUR_num_arr.append(divmod(eur, 50)[0]); eur = divmod(eur, 50)[1]
        EUR_num_arr.append(divmod(eur, 20)[0]); eur = divmod(eur, 20)[1]
        EUR_num_arr.append(divmod(eur, 10)[0]); eur = divmod(eur, 10)[1]
        EUR_num_arr.append(divmod(eur, 5)[0]); eur = divmod(eur, 5)[1]
        EUR_num_arr.append(divmod(eur, 2)[0]); eur = divmod(eur, 2)[1]
        EUR_num_arr.append(divmod(eur, 1)[0]); eur = divmod(eur, 1)[1]
        EUR_num_arr.append(divmod(eur, 0.5)[0]); eur = divmod(eur, 0.5)[1]
        EUR_num_arr.append(divmod(eur, 0.2)[0]); eur = divmod(eur, 0.2)[1]
        EUR_num_arr.append(divmod(eur, 0.10)[0]); eur = divmod(eur, 0.10)[1]
        EUR_num_arr.append(divmod(eur, 0.05)[0]); eur = divmod(eur, 0.05)[1]
        EUR_num_arr.append(divmod(eur, 0.02)[0]); eur = divmod(eur, 0.02)[1]
        EUR_num_arr.append(divmod(eur, 0.01)[0]); eur = divmod(eur, 0.01)[1]
        EUR_num_arr = [int(i) for i in EUR_num_arr]

        return f"500유로:{EUR_num_arr[0]} / 200유로:{EUR_num_arr[1]} / 100유로:{EUR_num_arr[2]} / 50유로:{EUR_num_arr[3]} / 20유로:{EUR_num_arr[4]} / 10유로:{EUR_num_arr[5]} / 5유로:{EUR_num_arr[6]} / 2유로:{EUR_num_arr[7]} / 1유로:{EUR_num_arr[8]} / 50유로센트:{EUR_num_arr[9]} / 20유로센트:{EUR_num_arr[10]} / 10유로센트:{EUR_num_arr[11]} / 5유로센트:{EUR_num_arr[12]} / 2유로센트:{EUR_num_arr[13]} / 1유로센트:{EUR_num_arr[14]} \n남은 금액 : {eur} ",  int(sum(EUR_num_arr))

    # JPY
    elif JPY_rate != -1:
        JPY_num_arr = []  # 10개 # 10,000 / 5,000 / 2,000 / 1,000 / 500 / 100 / 50 / 10 / 5 / 1
        JPY = KRW / JPY_rate
        print('JPY : ', JPY)

        # 0인덱스가 몫, 1인덱스가 나머지
        JPY_num_arr.append(divmod(JPY, 10000)[0]); jpy = divmod(JPY, 10000)[1]
        JPY_num_arr.append(divmod(jpy, 5000)[0]); jpy = divmod(jpy, 5000)[1]
        JPY_num_arr.append(divmod(jpy, 2000)[0]); jpy = divmod(jpy, 2000)[1]
        JPY_num_arr.append(divmod(jpy, 1000)[0]); jpy = divmod(jpy, 1000)[1]
        JPY_num_arr.append(divmod(jpy, 500)[0]); jpy = divmod(jpy, 500)[1]
        JPY_num_arr.append(divmod(jpy, 100)[0]); jpy = divmod(jpy, 100)[1]
        JPY_num_arr.append(divmod(jpy, 50)[0]); jpy = divmod(jpy, 50)[1]
        JPY_num_arr.append(divmod(jpy, 10)[0]); jpy = divmod(jpy, 10)[1]
        JPY_num_arr.append(divmod(jpy, 5)[0]); jpy = divmod(jpy, 5)[1]
        JPY_num_arr.append(divmod(jpy, 1)[0]); jpy = divmod(jpy, 1)[1]
        JPY_num_arr = [int(i) for i in JPY_num_arr]

        return f"10,000엔:{JPY_num_arr[0]} / 5,000엔:{JPY_num_arr[1]} / 2,000엔:{JPY_num_arr[2]} / 1,000엔:{JPY_num_arr[3]} / 500엔:{JPY_num_arr[4]} / 100엔:{JPY_num_arr[5]} / 50엔:{JPY_num_arr[6]} / 10엔:{JPY_num_arr[7]} / 5엔:{JPY_num_arr[8]} / 1엔 : {JPY_num_arr[9]} \n남은 금액 : {jpy}", int(sum(JPY_num_arr))

    elif CNY_rate != -1:
        # CNY
        CNY_num_arr = []  # 13개 # 100 / 50 / 20 / 10 / 5 / 2 / 1 / 0.5 / 0.2 / 0.1 / 0.05 / 0.02 / 0.01
        CNY = KRW / CNY_rate
        print('CNY : ', CNY)

        # 0인덱스가 몫, 1인덱스가 나머지
        CNY_num_arr.append(divmod(CNY, 100)[0]); cny = divmod(CNY, 100)[1]
        CNY_num_arr.append(divmod(cny, 50)[0]); cny = divmod(cny, 50)[1]
        CNY_num_arr.append(divmod(cny, 20)[0]); cny = divmod(cny, 20)[1]
        CNY_num_arr.append(divmod(cny, 10)[0]); cny = divmod(cny, 10)[1]
        CNY_num_arr.append(divmod(cny, 5)[0]); cny = divmod(cny, 5)[1]
        CNY_num_arr.append(divmod(cny, 2)[0]); cny = divmod(cny, 2)[1]
        CNY_num_arr.append(divmod(cny, 1)[0]); cny = divmod(cny, 1)[1]
        CNY_num_arr.append(divmod(cny, 0.5)[0]); cny = divmod(cny, 0.5)[1]
        CNY_num_arr.append(divmod(cny, 0.2)[0]); cny = divmod(cny, 0.2)[1]
        CNY_num_arr.append(divmod(cny, 0.10)[0]); cny = divmod(cny, 0.10)[1]
        CNY_num_arr.append(divmod(cny, 0.05)[0]); cny = divmod(cny, 0.05)[1]
        CNY_num_arr.append(divmod(cny, 0.02)[0]); cny = divmod(cny, 0.02)[1]
        CNY_num_arr.append(divmod(cny, 0.01)[0]); cny = divmod(cny, 0.01)[1]
        CNY_num_arr = [int(i) for i in CNY_num_arr]

        return f"100위안:{CNY_num_arr[0]} / 50위안:{CNY_num_arr[1]} / 20위안:{CNY_num_arr[2]} / 10위안:{CNY_num_arr[3]} / 5위안:{CNY_num_arr[4]} / 2위안:{CNY_num_arr[5]} / 1위안:{CNY_num_arr[6]} / 5자오:{CNY_num_arr[7]} / 2자오:{CNY_num_arr[8]} / 1자오:{CNY_num_arr[9]} / 5펀:{CNY_num_arr[10]} / 2펀:{CNY_num_arr[11]} / 1펀:{CNY_num_arr[12]} \n남은 금액 : {cny}", int(sum(CNY_num_arr))

    else :
        print('calc_exchange 함수에 값을 잘 못 전달했습니다.')
        return '0', 0

KRW = 0
USD = 0
EUR = 0
JPY = 0
CNY = 0

def input_KRW():
    global KRW, USD_rate, EUR_rate, JPY_rate, CNY_rate
    while(True):
        try:
            KRW = float(input('KRW 입력 : '))
            break
        except :
            print("KRW을 입력하세요")
    try:
        USD_rate, EUR_rate, JPY_rate, CNY_rate = map(float, input("USD, EUR, JPY, CNY 의 환율을 빈칸으로 구분해 순서대로 입력하세요(입력하지 않으면, 21.04.15 19:55 분 기준 환율 기준 적용) : ").split(' '))
        print()
    except :
        # # 21.04.15 19:55 분 기준 환율
        USD_rate = 1115.96
        EUR_rate = 1335.46
        JPY_rate = 10.26
        CNY_rate = 170.97
        print()

def output_FC():
    print('USD =================================================================================')
    USD_result = calc_exchange(KRW, USD_rate = USD_rate)
    print(USD_result[0]+'\n'+'총 '+str(USD_result[1]), '장(개)\n')
    print('EUR =================================================================================')
    EUR_result = calc_exchange(KRW, EUR_rate=EUR_rate)
    print(EUR_result[0]+'\n'+'총 '+str(EUR_result[1]), '장(개)\n')
    print('JPY =================================================================================')
    JPY_result = calc_exchange(KRW, JPY_rate=JPY_rate)
    print(JPY_result[0]+'\n'+'총 '+str(JPY_result[1]), '장(개)\n')
    print('CNY =================================================================================')
    CNY_result = calc_exchange(KRW, CNY_rate=CNY_rate)
    print(CNY_result[0]+'\n'+'총 '+str(CNY_result[1]), '장(개)\n')

input_KRW()
output_FC()
        


