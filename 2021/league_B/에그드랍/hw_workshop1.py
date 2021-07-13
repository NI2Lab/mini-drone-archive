country = int(input("환전할 국가는?(1:japan, 2:china, 3:USA, 4: EU): "))
money = int(input("환전할 금액을 입력하세요.: "))

krw_to_usd = money / 1124.63
krw_to_eur = money / 1336.73
krw_to_jpy = money / 10.24
krw_to_cny = money / 171.46
cnt = 0

if country == 1:
    print("{}원은 {}엔입니다.".format(money, int(krw_to_jpy)))
    jpy_dict = {"10000엔" : 10000, "5000엔" : 5000, "1000엔" : 1000, "500엔" : 500, "100엔" : 100,
                "50엔" : 50, "10엔" : 10, "5엔" : 5, "1엔" : 1}
    for k, v in jpy_dict.items():
        v_tmp = v
        jpy_dict[k] = int(krw_to_jpy/v)
        krw_to_jpy = krw_to_jpy - (v_tmp * jpy_dict[k])
        cnt += jpy_dict[k]
    print("10000엔 {}장, 5000엔 {}장, 1000엔 {}장, 500엔 {}개, 100엔 {}개, 50엔 {}개, 10엔 {}개, 5엔 {}개, 1엔 {}개"
          .format(*jpy_dict.values()))


if country == 2:
    print("{}원은 {}위안 {}자오입니다.".format(money, int(krw_to_cny), int((krw_to_cny%1)*10)))
    cny_dict = {"50위안" : 50, "20위안" : 20, "10위안" : 10, "5위안" : 5, "1위안" : 1, "5자오" : 0.5, "1자오" : 0.1}
    for k, v in cny_dict.items():
        v_tmp = v
        cny_dict[k] = int(krw_to_cny/v)
        krw_to_cny = krw_to_cny - (v_tmp * cny_dict[k])
        cnt += cny_dict[k]
    print("50위안 {}장, 20위안 {}장, 10위안 {}장, 5위안 {}장, 1위안 {}장, 5자오 {}개, 1자오 {}개"
          .format(*cny_dict.values()))
    
if country == 3:
    print("{}원은 {}달러 {}센트입니다.".format(money, int(krw_to_usd), int((krw_to_usd%1)*100)))
    usd_dict = {"100달러" : 100, "50달러" : 50, "20달러" : 20, "10달러" : 10, "5달러" : 5, "2달러" : 2, "1달러" : 1,
                "50센트" : 0.5, "25센트" : 0.25, "10센트" : 0.1, "5센트" : 0.05, "1센트" : 0.01}
    for k, v in usd_dict.items():
        v_tmp = v
        usd_dict[k] = int(krw_to_usd/v)
        krw_to_usd = krw_to_usd - (v_tmp * usd_dict[k])
        cnt += usd_dict[k]
    print("100달러 {}장, 50달러 {}장, 20달러 {}장, 10달러 {}장, 5달러 {}장, 2달러 {}장, 1달러 {}장, 50센트 {}개, 25센트 {}개, 10센트 {}개, 5센트 {}개, 1센트 {}개"
          .format(*usd_dict.values()))

if country == 4:
    print("{}원은 {}유로 {}유로센트입니다.".format(money, int(krw_to_eur), int((krw_to_eur%1)*100)))
    eur_dict = {"500유로" : 500, "200유로" : 200, "100유로" : 100, "50유로" : 50, "20유로" : 20, "10유로" : 10, "5유로" : 5, "2유로" : 2, "1유로" : 1,
                "50유로센트" : 0.5, "20유로센트" : 0.2, "10유로센트" : 0.1, "5유로센트" : 0.05, "1유로센트" : 0.01}
    for k, v in eur_dict.items():
        v_tmp = v
        eur_dict[k] = int(krw_to_eur/v)
        krw_to_eur = krw_to_eur - (v_tmp * eur_dict[k])
        cnt += eur_dict[k]
    print("500유로 {}장, 200유로 {}장, 100유로 {}장, 50유로 {}장, 20유로 {}장, 10유로 {}장, 5유로 {}장, 2유로 {}장, 1유로 {}장 \n50유로센트 {}개, 20유로센트 {}개, 10유로센트 {}개, 5유로센트 {}개, 1유로센트 {}개"
          .format(*eur_dict.values()))

print("최소 화폐는 {}개 입니다.".format(cnt))
