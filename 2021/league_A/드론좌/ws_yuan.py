def exchange(won):
    yuan_rate = 0.0059  # 원화 1원당 위안화 가격
    yuan = int(won * yuan_rate) * 10  # 원화 -> 위안화 환전 (인덱스 계산 위해 x10)
    cny = [1, 5, 10, 50, 100, 200, 500, 1000]  # 위안화 화폐 단위 (인덱스 계산 위해 x10)

    c = []  # 각 위안화별 최소 화폐 수
    c = [yuan+1 for i in range(yuan+1)]
    c[0] = 0

    for i in range(1, yuan+1):  # 동적 프로그래밍을 통한 거스름돈 계산
        for j in range(0, len(cny)):
            if ((cny[j] <= i) and (c[i-cny[j]] + 1 < c[i])):
                c[i] = c[i-cny[j]] + 1

    print("위안 환전 금액 :", yuan/10, " 화폐 수 :", c[yuan], "개")

def main():
    pass

if __name__ == "__main__":
    main()
else:
    pass