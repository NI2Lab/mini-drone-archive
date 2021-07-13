from decimal import Decimal

EXCHANGE_RATE = {'KRW': 1000, 'USD': 0.89, 'EUR': 0.75, 'JPY': 97.82, 'CNY': 5.85}

def exchange(money_krw):
    money_usd = round(float(Decimal(str(EXCHANGE_RATE['USD'])) * Decimal(str(money_krw / EXCHANGE_RATE['KRW']))), 2)
    money_eur = round(float(Decimal(str(EXCHANGE_RATE['EUR'])) * Decimal(str(money_krw / EXCHANGE_RATE['KRW']))), 2)
    money_jpy = round(float(Decimal(str(EXCHANGE_RATE['JPY'])) * Decimal(str(money_krw / EXCHANGE_RATE['KRW']))), 2)
    money_cny = round(float(Decimal(str(EXCHANGE_RATE['CNY'])) * Decimal(str(money_krw / EXCHANGE_RATE['KRW']))), 2)
    exchanged_money = {'KRW': money_krw,
                       'USD': money_usd, 'EUR': money_eur,
                       'JPY': money_jpy, 'CNY': money_cny}
    return exchanged_money

def countUSD(money_usd):
    bills = {100: 0, 50: 0, 20: 0, 10: 0, 5: 0, 2: 0, 1: 0}  # 지폐 : 100달러 / 50달러 / 20달러 / 10달러 / 5달러 / 2달러 / 1달러
    coins = {0.5: 0, 0.25: 0, 0.1: 0, 0.05: 0, 0.01: 0}      # 동전 : 50센트 / 25센트 / 10센트 / 5센트 / 1센트

    for bill in bills.keys():
        bills[bill] = int(money_usd // bill)
        money_usd = money_usd % bill
    for coin in coins.keys():
        coins[coin] = int(money_usd // coin)
        money_usd = money_usd % coin

    return bills, coins

def countEUR(money_eur):
    bills = {500: 0, 200: 0, 100: 0, 50: 0, 20: 0, 10: 0, 5: 0}    # 지폐: 500유로 / 200유로 / 100유로 / 50유로
                                                                                   # 20유로 / 10유로 / 5유로
    coins = {2: 0, 1: 0, 0.5: 0, 0.2: 0, 0.1: 0, 0.05: 0, 0.02: 0, 0.01: 0}    # 동전: 2유로 / 1유로 / 50센트 / 20센트
                                                                                    # 10센트 / 5센트 / 2센트 / 1센트트
    for bill in bills.keys():
        bills[bill] = int(money_eur // bill)
        money_eur = money_eur % bill
    for coin in coins.keys():
        coins[coin] = int(money_eur // coin)
        money_eur = money_eur % coin

    return bills, coins

def countJPY(money_jpy):
    bills = {10000: 0, 50000: 0, 2000: 0, 1000: 0}      # 지폐: 10,000엔 / 5,000엔 / 2,000엔 / 1,000엔
    coins = {500: 0, 100: 0, 50: 0, 10: 0, 5: 0, 1: 0}  # 동전: 500엔 / 100엔 / 50엔 / 10엔 / 5엔 / 1엔

    for bill in bills.keys():
        bills[bill] = int(money_jpy // bill)
        money_jpy = money_jpy % bill
    for coin in coins.keys():
        coins[coin] = int(money_jpy // coin)
        money_jpy = money_jpy % coin

    return bills, coins

def countCNY(money_cny):
    bills = {100: 0, 50: 0, 20: 0, 10: 0, 5: 0, 1: 0}   # 지폐: 100위안 / 50위안 / 20위안 / 10위안 / 5위안 / 1위안
    coins = {0.5: 0, 0.1: 0}                            # 동전: 5자오 / 1자오

    for bill in bills.keys():
        bills[bill] = int(money_cny // bill)
        money_cny = money_cny % bill
    for coin in coins.keys():
        coins[coin] = int(money_cny // coin)
        money_cny = money_cny % coin

    return bills, coins


if __name__ == "__main__":
    money_krw = float(input('원화를 입력하세요: '))
    exchanged_money = exchange(money_krw)
    for key, value in exchanged_money.items():
        print(key, value)

    print(f'\n환전해야하는 달러 권종과 개수:')
    bills_usd, coins_usd = countUSD(exchanged_money['USD'])
    for key, value in bills_usd.items():
        if value != 0:
            print(f'{key}달러 짜리 지폐: {value}개')
    for key, value in coins_usd.items():
        if value != 0:
            print(f'{int(key * 100)}센트 짜리 동전: {value}개')

    print(f'\n환전해야하는 유로 권종과 개수:')
    bills_eur, coins_eur = countEUR(exchanged_money['EUR'])
    for key, value in bills_eur.items():
        if value != 0:
            print(f'{key}유로 짜리 지폐: {value}개')
    for key, value in coins_eur.items():
        if value != 0:
            if key >= 1:    # 1, 2유로 동전일 때
                print(f'{key}유로 짜리 동전: {value}개')
            else:    # 센트일 때
                print(f'{int(key*100)}센트 짜리 동전: {value}개')

    print(f'\n환전해야하는 엔화 권종과 개수:')
    bills_jpy, coins_jpy = countJPY(exchanged_money['JPY'])
    for key, value in bills_jpy.items():
        if value != 0:
            print(f'{key}엔짜리 지폐: {value}개')
    for key, value in coins_jpy.items():
        if value != 0:
            print(f'{key}엔짜리 동전: {value}개')

    print(f'\n환전해야하는 위안화 권종과 개수:')
    bills_cny, coins_cny = countCNY(exchanged_money['CNY'])
    for key, value in bills_cny.items():
        if value != 0:
            print(f'{key}위안짜리 지폐: {value}개')
    for key, value in coins_cny.items():
        if value != 0:
            print(f'{int(key*10)}자오짜리 동전: {value}개')
