import math

def exchange(won):
    euro_rate = 0.00075  # 원화 1원당 유로 가격
    euro = won * euro_rate   # 원화 -> 유로 환전
    euro = math.floor(euro * 100) / 100   #  euro = round(euro,2)
    exchanged_euro = euro
    euro_list = [500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01]  # 유로 화폐 단위
    exchanged_list = [] # 각 유로별 최소 화폐 수


    for i in range(15):     # 최소 화폐 개수를 찾는 과정
        k = 0
        k += euro // euro_list[i]
        exchanged_list.append(k)
        euro -= euro_list[i] * k

    print("유로 환전 금액 : {}   화폐 수 : {} ".format(exchanged_euro, int(sum(exchanged_list))))

def main():
    pass

if __name__ == "__main__":
    main()
else:
    pass