# 0.01달러 = 1센트
def exchange(k_money):
    # original_usd_rate = 0.00090
    usd = int(k_money * 0.090)
    usd=round(usd,2)
    ori = usd/100  # 달러 출력을 위한 변수

    # usd_list=[100,50,20,10,5,2,1,0.5,0.25,0.15,0.1,0.05,0.01]에 100씩 곱하기

    usd_list = [1, 5, 10, 15, 25, 50, 100, 200, 500, 1000, 2000, 5000, 10000]

    coin = [usd+1 for i in range(usd+1)]
    coin[0] = 0

    for i in range(1, usd+1):
        for j in range(0,len(usd_list)):
            if((usd_list[j]<=i) and (coin[i-usd_list[j]]+1<coin[i])):
                coin[i]=coin[i-usd_list[j]]+1

    print("달러 환전 금액 :",ori,"  화폐 수 :",coin[usd])

def main():
    pass

if __name__ == "__main__":
    main()
else:
    pass