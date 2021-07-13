import decimal
money = int(input('Enter your KRW money : '))

print('exchange',money,'₩') 
dollar = 1121 #one dollar per 1121 won as of 2021.04.09 20:02
KtoUS=money/dollar
print(KtoUS,'$ //one dollar per 1121 won')

d=['$100','$50','$20','$10','$5','$2','$1','50￠','25￠','10￠','5￠','1￠']
da=[0,0,0,0,0,0,0,0,0,0,0,0]
for I in range(0,int(money/0.01)):
    if KtoUS>100:
        da[0]=da[0]+1; KtoUS=KtoUS-100
    elif KtoUS>50:
        da[1]=da[1]+1; KtoUS=KtoUS-50
    elif KtoUS>20:
        da[2]=da[2]+1; KtoUS=KtoUS-20
    elif KtoUS>10:
        da[3]=da[3]+1; KtoUS=KtoUS-10
    elif KtoUS>5:
        da[4]=da[4]+1; KtoUS=KtoUS-5
    elif KtoUS>2:
        da[5]=da[5]+1; KtoUS=KtoUS-2
    elif KtoUS>1:
        da[6]=da[6]+1; KtoUS=KtoUS-1
    elif KtoUS>0.5:
        da[7]=da[7]+1; KtoUS=KtoUS-0.5
    elif KtoUS>0.25:
        da[8]=da[8]+1; KtoUS=KtoUS-0.25
    elif KtoUS>0.1:
        da[9]=da[9]+1; KtoUS=KtoUS-0.1 
    elif KtoUS>0.05:
        da[10]=da[10]+1; KtoUS=KtoUS-0.05
    elif KtoUS>0.01:
        da[11]=da[11]+1; KtoUS=KtoUS-0.01    
    else :
        break
dt=0
for I in range(0,12):
    if da[I]!=0:
        dt+=da[I]
        print(d[I],':',da[I])
print('dollar total :',dt,'개\n')

euro=1332.31 #one euro per 1332.31 won as of 2021.04.09 20:02
KtoEUR=money/euro
print(KtoEUR,'€ //one euro per 1332.31 won')
e=['€500','€200','€100','€50','€20','€10','€5','€2','€1','50c','20c','10c','5c','2c','1c']
ea=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] 
for I in range(0,int(money/0.01)):
    if KtoEUR>500:
        ea[0]=ea[0]+1; KtoEUR=KtoEUR-500
    elif KtoEUR>200:
        ea[1]=ea[1]+1; KtoEUR=KtoEUR-200
    elif KtoEUR>100:
        ea[2]=ea[2]+1; KtoEUR=KtoEUR-100
    elif KtoEUR>50:
        ea[3]=ea[3]+1; KtoEUR=KtoEUR-50
    elif KtoEUR>20:
        ea[4]=ea[4]+1; KtoEUR=KtoEUR-20
    elif KtoEUR>10:
        ea[5]=ea[5]+1; KtoEUR=KtoEUR-10
    elif KtoEUR>5:
        ea[6]=ea[6]+1; KtoEUR=KtoEUR-5
    elif KtoEUR>2:
        ea[7]=ea[7]+1; KtoEUR=KtoEUR-2
    elif KtoEUR>1:
        ea[8]=ea[8]+1; KtoEUR=KtoEUR-1
    elif KtoEUR>0.5:
        ea[9]=ea[9]+1; KtoEUR=KtoEUR-0.5
    elif KtoEUR>0.2:
        ea[10]=ea[10]+1; KtoEUR=KtoEUR-0.2
    elif KtoEUR>0.1:
        ea[11]=ea[11]+1; KtoEUR=KtoEUR-0.1
    elif KtoEUR>0.05:
        ea[12]=ea[12]+1; KtoEUR=KtoEUR-0.05
    elif KtoEUR>0.02:
        ea[13]=ea[13]+1; KtoEUR=KtoEUR-0.02
    elif KtoEUR>0.01:
        ea[14]=ea[14]+1; KtoEUR=KtoEUR-0.01
    else :
        break
et=0
for I in range(0,15):
    if ea[I]!=0:
        et=et+ea[I]
        print(e[I],':',ea[I])
print('euro total :',et,'개 \n')


JPY = float(money * 0.098)
print("In Japan, ", JPY, " JPY")
a = JPY // 10000
JPY = JPY - 10000*a
b = JPY // 5000
JPY = JPY - 5000*b
c = JPY // 2000
JPY = JPY - 2000*c
d = JPY // 1000
JPY = JPY - 1000*d
e = JPY // 500
JPY = JPY - 500*e
f = JPY // 100
JPY = JPY - 100*f
g = JPY // 50
JPY = JPY - 50*g
h = JPY // 10
JPY = JPY - 10*h
i = JPY // 5
JPY = JPY - 5*i
j = JPY // 1

print("10000 JPY : ", int(a), "\n 5000 JPY : ", int(b), "\n 2000 JPY : ", int(c), "\n 1000 JPY : ", int(d), "\n  500 JPY : ", int(e),
      "\n  100 JPY : ", int(f), "\n   50 JPY : ", int(g), "\n   10 JPY : ", int(h), "\n    5 JPY : ", int(i), "\n    1 JPY : ", int(j))
print("Total : ", int(a+b+c+d+e+f+g+h+i+j), "개 \n")

wian=decimal.Decimal(money)*decimal.Decimal(0.01)
print("\n", ">>total CNY: ", "¥", money*0.01)

lst=[100, 50, 20, 10, 5, 1, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01] #화폐 단위 위안
lst2=["¥100", "¥50", "¥20", "¥10", "¥5", "¥1", "5 jiao(¥0.5)", "2 jiao(¥0.2)", "1 jiao(¥0.1)", "5 fen(¥0.05)", "2 fen(¥0.02)", "1 fen(¥0.01)"] #화폐 단위 명칭
d=[]             #해당 화폐 최소 단위 위안 넣을 리스트
unit=[]          #해당 최소 단위 넣을 리스트

print(">>필요한 최소 화폐 갯수")
index=0
number=0
for i in lst:
    h= wian//decimal.Decimal(i)
    if h==0:
        index+=1
        continue
    else:         #해당 화폐 단위 존재
        d.append(h)
        unit.append(i)
        number+=h
        print(lst2[index], ":", int(h), " 개")   #해당 화폐 갯수 출력
        index+=1
    wian = decimal.Decimal(wian)-decimal.Decimal(i)*int(h)

print(">>total: ", int(number), "개")