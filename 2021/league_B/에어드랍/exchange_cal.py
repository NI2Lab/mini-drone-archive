"""
21년 4월 10일 기준
1달러  = 1,121.00원

1유로 = 1332.31원

1위안 = 170.75원

1엔 = 1,021.83원
"""

def cal(won):
    KRW = won
    USD = '%0.2f' % float(KRW/1121)
    EUR = '%0.2f' % float(KRW/1332.31)
    CNY = '%0.2f' % float(KRW/170.75)
    JPY = '%0.2f' % float(KRW/1021.83)
    return USD, EUR, CNY, JPY

def change_cal(nation_cur, cu):
    cha_unit = []
    cha_num = []
    for i in nation_cur:
        if cu // i < 1 :

            continue
        else :
            cu = round(cu, 2)
            v = int(cu/i)

            cu = round(cu - i*v, 2)
            cha_unit.append(i)
            cha_num.append(v)
    return cha_unit, cha_num

