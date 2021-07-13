import math
from forex_python.converter import CurrencyRates

def USA():
    x = (math.trunc(usd_money) * 100)
    cnt = 0
    coinTypes = [10000, 5000, 2000, 1000, 500, 200, 100, 50, 25, 10, 5, 1]

    dollar = list(range(len(coinTypes), 0))
    dollar = [0 for i in range(len(coinTypes))]
    num = 0

    print("환산된 가격은 ", x / 100, "달러입니다.")

    for i in range(len(coinTypes)):
        coin = coinTypes[i]
        if x >= coinTypes[i]:
            mok = x // coin
            x -= coin * mok
            num += mok
            dollar[i] = int(mok)


    print("총 화폐의 개수는 ", int(num), "개 입니다.")

    for i in range(len(coinTypes)):
        if dollar[i] > 0:
            if i <= 7:
                print(int(coinTypes[i]/100), "달러로는", dollar[i],"개 입니다.")
            else:
                print(coinTypes[i] , "센트로는", dollar[i], "개 입니다.")
def EURO():
    x = (math.trunc(eur_money) * 100)
    cnt = 0
    coinTypes = [50000,20000,10000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1]

    EUR = list(range(len(coinTypes), 0))
    EUR = [0 for i in range(len(coinTypes))]
    num = 0

    print("환산된 가격은 ", x / 100, "유로입니다.")

    for i in range(len(coinTypes)):
        coin = coinTypes[i]
        if x >= coinTypes[i]:
            mok = x // coin
            x -= coin * mok
            num += mok
            EUR[i] = int(mok)


    print("총 화폐의 개수는 ", int(num), "개 입니다.")

    for i in range(len(coinTypes)):
        if EUR[i] > 0:
            if i <= 7:
                print(int(coinTypes[i]/100), "유로로는", EUR[i],"개 입니다.")
            else:
                print(coinTypes[i] , "센트로는", EUR[i], "개 입니다.")
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

c = CurrencyRates()
usd= c.get_rates('USD')['KRW']
eur= c.get_rates('EUR')['KRW']
jpy= c.get_rates('JPY')['KRW']
cny= c.get_rates('CNY')['KRW']

print("환율 계산기 입니다.")
print("[USD],[JPY],[EUR],[CNY]를 지원합니다. ")
money = input("계산하시고자 하는 화폐의 종류를 대문자로 입력하세요 : ")
money3 = input("원화를 입력하세요 :")

eur_money = float(money3)/eur
usd_money = float(money3)/usd
cny_money = float(money3)/cny
jpy_money = float(money3)/jpy


if money == "USD":
        USA()
elif money == "JPY":
        JPY()
elif money == "EUR":
        EURO()
elif money == "CNY":
        CHY()




