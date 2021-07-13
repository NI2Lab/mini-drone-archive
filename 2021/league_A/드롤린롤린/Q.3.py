li1 = [100,50,20,10,5,2,1]
sum1 = 0
for i in li1 :
    m = x // i
    x = x % i
    sum1 += m
    print(i,'달러',':',m,'개')
print("{0} 장(개)의 화폐가 필요합니다.\n". format(sum1))


li2 = [500,200,100,50,20,10,5,2,1]
sum2 = 0
for i in li2 :
    m = y // i
    y = y % i
    sum2 += m
    print(i,'유로',':',m,'개')
print("{0} 장(개)의 화폐가 필요합니다.\n". format(sum2))

li3 = [10000,5000,2000,1000,500,100,50,10,5,1]
sum3 = 0
for i in li3 :
    m = z // i
    z = z % i
    sum3 += m
    print(i,'엔',':',m,'개')
print("{0} 장(개)의 화폐가 필요합니다.\n". format(sum3))


li4 = [100,50,20,10,5,1]
sum4 = 0
for i in li4 :
    m = w // i
    w = w % i
    sum4 += m
    print(i,'위안',':',m,'개')
print("{0} 장(개)의 화폐가 필요합니다.\n". format(sum4))
