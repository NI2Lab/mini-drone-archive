def exchange(won):
    yen_rate = 0.097  # 원화 1원당 엔화 가격
    yen = int(won * yen_rate)  # 원화 -> 엔화 환전
    jpy = [1, 5, 10, 50, 100, 500, 1000, 2000, 5000, 10000]  # 엔 화폐 단위

    c = []  # 각 엔화별 최소 화폐 수
    c = [yen+1 for i in range(yen+1)]
    c[0] = 0

    for i in range(1, yen+1):  # 동적 프로그래밍을 통한 거스름돈 계산
        for j in range(0, len(jpy)):
            if ((jpy[j] <= i) and (c[i-jpy[j]] + 1 < c[i])):
                c[i] = c[i-jpy[j]] + 1

    print("엔 환전 금액 :", yen, " 화폐 수 :", c[yen], "개")

def main():
    pass

if __name__ == "__main__":
    main()
else:
    pass