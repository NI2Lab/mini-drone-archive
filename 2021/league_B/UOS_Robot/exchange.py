import math as m

dollar_rate = 1121.12 # 달러 환율
euro_rate = 1334.22 # 유로 환율
yuan_rate = 171.08 # 위안 환율
yen_rate = 10.22 # 옌 환율

def KRW2USD(KRW):                                               # 함수 정의
    USD = m.trunc(KRW / dollar_rate*100)/100                    # 환전(KRW -> USD)
    print(USD, '달러\n')
    unit=[100, 50, 20, 10, 5, 2, 1, 0.5, 0.25, 0.1, 0.05, 0.01] # 화폐 단위
    total = 0                                                   # count를 위한 변수 선언

    for i in unit:                                              # 화폐 단위에 맞추어 반복 처리
        share = USD/i                                           # 몫
        remainder = round(USD%i,2)                              # 나머지(round - 나머지 함수에서 발생하는 작은 단위 제거)
        print(i,'달러 : ',m.trunc(share),'개')
        total += m.trunc(share)                                 # 총 화폐 수 count
        USD=remainder                                           # 나머지 이전

    print('\n총 ',total,'개\n')                                  # 총 화폐 수 출력

def KRW2UTC(KRW):                                               # 함수 정의
    UTC = m.trunc(KRW / euro_rate*100)/100                      # 환전(KRW -> UTC)
    print(UTC, '유로\n')
    unit = [500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01]    #화폐 단위
    total = 0                                                   # count를 위한 변수 선언

    for i in unit:                                              # 화폐 단위에 맞추어 반복 처리
        share = UTC / i                                         # 몫
        remainder = round(UTC%i,2)                              # 나머지(round - 나머지 함수에서 발생하는 작은 단위 제거)
        print(i, '유로 : ', m.trunc(share), '개')
        total += m.trunc(share)                                 # 총 화폐 수 count
        UTC = remainder                                         # 나머지 이전

    print('\n총 ',total,'개\n')                                  # 총 화폐 수 출력

print('Enter the amount to exchange')
money=int(input())                                              # input 요구
KRW2USD(money)                                                  # 환전(KRW -> USD)
KRW2UTC(money)                                                  # 환전(KRW -> UTC)


yuan=m.trunc(money/yuan_rate*100)*0.01                          # 환전(KRW -> YUAN), 환율 계산 과정에서 발생하는 필요없는 소수 버림

print(yuan, end='위안\n\n')
yuan_unit=[100, 50, 20, 10, 5, 1, 0.5, 0.1]                     # 화폐 단위
yuan_count=0                                                    # count를 위한 변수 선언
for i in yuan_unit:                                             # 화폐 단위에 맞추어 반복 처리
    print(i, end='위안 : ')
    yuan_count +=yuan//i                                        # 총 화폐 수 count
    print(int(yuan//i), end='')
    print('개')
    yuan= round(yuan%i, 2)                                      # 나머지(round - 나머지 함수에서 발생하는 작은 단위 제거)
print('\n총 ', end='')
print(int(yuan_count), end='')
print(' 개\n')

yen=m.trunc(money/yen_rate)                                     # 환전(KRW -> YEN)

print(yen, end='엔\n\n')
yen_unit=[10000, 5000, 2000, 1000, 500, 100, 50, 10, 5, 1]      # 화폐 단위
yen_count=0                                                     # count를 위한 변수 선언
for i in yen_unit:                                              # 화폐 단위에 맞추어 반복 처리
    print(i, end='엔 : ')
    yen_count += yen // i                                       # 총 화폐 수 count
    print(yen // i, end='')
    print('개')
    yen %= i                                                    # 나머지
print('\n총 ', end='')
print(int(yen_count), end='')
print(' 개')
