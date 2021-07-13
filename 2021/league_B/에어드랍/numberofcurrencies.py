import exchange_cal as ec

"""
0.01달러 = 1센트
센트 : 1, 5, 10, 25
달러 : 1, 5, 10, 20, 50, 100
0.01유로 = 1센트
센트 : 1, 5, 10, 20, 50
유로 : 1, 2
0.1위안 = 1자오
자오 : 1, 5
위안 : 1, 5, 10, 20, 50, 100
엔 : 1, 5, 10, 50, 100, 1000, 2000, 5000, 10000
"""

def cal_main(): # 달러, 유로, 위안, 엔
    USD = [100, 50, 20, 10, 5, 2, 1, 0.5, 0.25, 0.10, 0.05, 0.01]
    EUR = [500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01]
    CHY = [100, 50, 20, 10, 5, 2, 1, 0.50, 0.20, 0.10, 0.05, 0.02, 0.01]
    JPN = [10000, 5000, 2000, 1000, 500, 100, 50, 10, 5, 1]

    won = eval(input("금액을 적어주세요 : "))
    print("입력하신 금액은 " + str(won) + "원입니다.")

    cu_li = ec.cal(won)
    print('-' * 30)
    case = 0
    while(case < 4):
        if case == 0:
            unit, num = ec.change_cal(USD, eval(cu_li[case]))
            print("미국환율 : " + cu_li[case] + "달러" )
            for i, j in zip(unit, num):
                if i >= 1:
                    print("{}달러 {}장".format(i, j))
                else :
                    print("{}센트 {}개".format(int(i/0.01) ,j))
                cusum = sum(num)
            print("총 화폐 개수 : {}".format(cusum))
            case += 1
        elif case == 1:
            unit, num = ec.change_cal(EUR, eval(cu_li[case]))
            print("유럽환율 : " + cu_li[case] + "유로")
            for i, j in zip(unit, num):
                if i >= 1:
                    print("{}유로 {}장".format(i, j))
                else:
                    print("{}유로센트 {}개".format(int(i/0.01) ,j))
                cusum = sum(num)
            print("총 화폐 개수 : {}".format(cusum))
            case += 1
        elif case == 2:
            unit, num = ec.change_cal(CHY, eval(cu_li[case]))
            print("중국환율 : " + cu_li[case] + "위안")
            for i, j in zip(unit, num):
                if i >= 1:
                    print("{}위안 {}장".format(i, j))
                elif i < 1 and i/0.1 >= 1:
                    print("{}자오 {}개".format(int(i / 0.1), j))
                else:
                    print("{}펀 {}개".format(int(i / 0.01), j))
                cusum = sum(num)
            print("총 화폐 개수 : {}".format(cusum))

            case += 1
        elif case == 3:
            unit, num = ec.change_cal(JPN, eval(cu_li[case]))
            print("일본환율 : " + cu_li[case] + "엔")
            for i, j in zip(unit, num):
                print("{}엔 {}장".format(i, j))
                cusum = sum(num)
            print("총 화폐 개수 : {}".format(cusum))
            print("남은 금액 {}엔".format(round(eval(cu_li[case])%1, 2)))
            case += 1
        print('-' * 30)



cal_main()
