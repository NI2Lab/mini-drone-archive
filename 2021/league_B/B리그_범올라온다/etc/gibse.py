def USA():
    x = (round(usd_money, 2) * 100)
    cnt = 0
    coinTypes = [10000, 5000, 2000, 1000, 500, 200, 100, 50, 25, 10, 5, 1]

    dollar = list(range(len(coinTypes), 0))
    dollar = [0 for i in range(len(coinTypes))]
    num = 0


    for i in range(len(coinTypes)):
        coin = coinTypes[i]
        if x >= coinTypes[i]:
            mok = x // coin
            x -= coin * mok
            num += mok
            dollar[i] = int(mok)

    for i in range(len(coinTypes)):
        if dollar[i] > 0:
            if i <= 7:
                print(int(coinTypes[i]/100), "달러는", dollar[i],"개 입니다.")
            else:
                print(coinTypes[i] , "센트는", dollar[i], "개 입니다.")

def EURO():
    x = (round(eur_money, 2) * 100)
    cnt = 0
    coinTypes = [50000,20000,10000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1]

    EUR = list(range(len(coinTypes), 0))
    EUR = [0 for i in range(len(coinTypes))]
    num = 0


    for i in range(len(coinTypes)):
        coin = coinTypes[i]
        if x >= coinTypes[i]:
            mok = x // coin
            x -= coin * mok
            num += mok
            EUR[i] = int(mok)

    for i in range(len(coinTypes)):
        if EUR[i] > 0:
            if i <= 7:
                print(int(coinTypes[i]/100), "유로는", EUR[i],"개 입니다.")
            else:
                print(coinTypes[i] , "센트는", EUR[i], "개 입니다.")




