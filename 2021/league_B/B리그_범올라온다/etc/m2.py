import math
from forex_python.converter import CurrencyRates


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
