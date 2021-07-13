USD=1126.30 ## 2021.04.12기준
JPY=10.2811 ## 2021.04.12기준
CNY=171.68  ## 2021.04.12기준

i=0
USD_INDEX=[100,50,20,10,5,2,1,0.25,0.1,0.05,0.01]
USD_EXCHANGE=[0 for i in range(len(USD_INDEX))]

money=int(input("money(원화) : "))
print("입력된 원화는",money,"원 입니다.")
print(sep='\n')

usd=round(money/USD,2)
jpy=int(money/JPY) ## 엔화는 0.1이하로 단위가 존재하지 않음.
cny=round(money/CNY,2)

print("입력된 원화를 달러로 환전하면",usd,"달러","입니다.")
print("입력된 원화를 엔화로 환전하면",jpy,"엔","입니다.")
print("입력된 원화를 위안로 환전하면",cny,"위안","입니다.")
print(sep='\n')

print("달러로 환전하면 다음과 같이 화폐가 지급됩니다.")

i=0
while i < len(USD_INDEX) :
    USD_EXCHANGE[i]=int(usd/USD_INDEX[i])
    usd=round(usd-USD_EXCHANGE[i]*USD_INDEX[i],2)
    i+=1

i=0
while i < len(USD_INDEX) :
    print('{}달러 :'.format(USD_INDEX[i]),'{}개'.format(USD_EXCHANGE[i]))
    i+=1


i=0
CNY_INDEX=[100,50,20,10,5,1,0.1,0.01]
CNY_EXCHANGE=[0 for i in range(len(USD_INDEX))]


print(sep='\n')
print("위안으로  환전하면 다음과 같이 화폐가 지급됩니다.")

i=0
while i < len(CNY_INDEX) :
    CNY_EXCHANGE[i]=int(cny/CNY_INDEX[i])
    cny=round(cny-CNY_EXCHANGE[i]*CNY_INDEX[i],2)
    i+=1

i=0
while i < len(CNY_INDEX) :
    print('{}위안 :'.format(CNY_INDEX[i]),'{}개'.format(CNY_EXCHANGE[i]))
    i+=1


i=0

JPY_INDEX=[10000, 2000, 1000, 500,100,50,10, 1]
JPY_EXCHANGE=[0 for i in range(len(JPY_INDEX))]

print(sep='\n')
print("엔화으로  환전하면 다음과 같이 화폐가 지급됩니다.")

while i < len(JPY_INDEX) :
    JPY_EXCHANGE[i]=int(jpy/JPY_INDEX[i])
    jpy=jpy-JPY_EXCHANGE[i]*JPY_INDEX[i]
    i+=1

i=0
while i < len(JPY_INDEX) :
    print('{}엔 :'.format(JPY_INDEX[i]),'{}개'.format(JPY_EXCHANGE[i]))
    i+=1

    
