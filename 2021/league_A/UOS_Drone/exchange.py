print("*****한국 원화의 돈을 입력받는다.")
won = int(input())
print("입력받은 돈 : ",won,"원")
print("***********************************************************************************")
#최소한의 화폐로 환전했을 때, 몇장(개) 화폐가 필요한지 출력하는 프로그램을 작성한다
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
exchange_lst=[0.00089, 0.00075, 0.0058, 0.098]  # [달러, 유로, 위안, 엔] 환율

Dollar_unit = [100,50,20,10,5,2,1,0.5,0.25,0.1,0.05,0.01]
Eur_unit=[500,200,100,50,20,10,5,2,1,0.5,0.2,0.1,0.05,0.02,0.01]
Yuan_unit = [100, 50, 20, 10, 5, 1, 0.5, 0.1]  # 중국 화폐 단위[위안]
Yen_unit = [10000, 5000, 2000, 1000, 500, 100, 50, 10, 5, 1]  # 일본 화폐 단위[엔]

money_name_lst=['달러', '유로', '위안', '엔']  # ['달러', '유로', '위안', '엔']

def Exchanger(won , unit, exchange,string) :
    # 각 화폐의 최소 단위보다 작은 수는 어차피 for 문 이후에 나머지로 남아 처리가 되지 않으므로 환전 시 소수점 3번째 자리에서 반올림
    Exchange = round(won * exchange,3)
    print("환전:",Exchange,string)
    count = 0
    for x in unit:
        share = int(Exchange // x)
        count += share
        Exchange -= share*x
        Exchange = round(Exchange,3)# 계산에서 발생하는 미세한 오차를 없애기 위해 반올림
        print(x, string," ", share, "개/ ", end='', sep='')
    print("\n총 지폐 계수:", count, "개")
    return(print("***********************************************************************************"))
Exchanger(won, Dollar_unit, exchange_lst[0],money_name_lst[0])
Exchanger(won,Eur_unit,exchange_lst[1],money_name_lst[1])
Exchanger(won,Yuan_unit,exchange_lst[2],money_name_lst[2])
Exchanger(won,Yen_unit,exchange_lst[3],money_name_lst[3])
