def JPY():
    x = (math.trunc(jpy_money) * 100)
    cnt = 0
    coinTypes = [10000, 5000, 2000, 1000, 500, 100, 50, 10, 5, 1]

    JPY = list(range(len(coinTypes), 0))
    JPY = [0 for i in range(len(coinTypes))]
    num = 0


    print("환산된 가격은 ", x / 100, "엔입니다.")

    for i in range(len(coinTypes)):
        coin = coinTypes[i]
        if x >= coinTypes[i]:
            mok = x // coin
            x -= coin * mok
            num += mok
            JPY[i] = int(mok)

    print("총 화폐의 개수는 ", int(num), "개 입니다.")

    for i in range(len(coinTypes)):
        if JPY[i] > 0:
            print(int(coinTypes[i]), "엔으로는", JPY[i],"개 입니다.")
def CHY():
    x = (math.trunc(cny_money) * 100)
    cnt = 0
    coinTypes = [100, 50, 20 , 10, 5, 1]

    CHY = list(range(len(coinTypes), 0))
    CHY = [0 for i in range(len(coinTypes))]
    num = 0


    print("환산된 가격은 ", x / 100, "위안입니다.")

    for i in range(len(coinTypes)):
        coin = coinTypes[i]
        if x >= coinTypes[i]:
            mok = x // coin
            x -= coin * mok
            num += mok
            CHY[i] = int(mok)


    print("총 화폐의 개수는 ", int(num), "개 입니다.")

    for i in range(len(coinTypes)):
        if CHY[i] > 0:
            print(int(coinTypes[i]), "위안으로는", CHY[i],"개 입니다.")

