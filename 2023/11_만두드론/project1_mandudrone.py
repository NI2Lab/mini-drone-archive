import math
import numpy as np

# 세 개의 3차원 벡터 입력
print("=====벡터 1======")
ax = int(input("벡터1 x: "))
ay = int(input("벡터1 y: "))
az = int(input("벡터1 z: "))

print("=====벡터 2======")
bx = int(input("벡터2 x: "))
by = int(input("벡터2 y: "))
bz = int(input("벡터2 z: "))
print("=====벡터 3======")
cx = int(input("벡터3 x: "))
cy = int(input("벡터3 y: "))
cz = int(input("벡터3 z: "))

#각각 유클리디안 거리
print("------유클리디안 거리 ------")
v12 = math.sqrt(((abs(ax-bx))**2)+((abs(ay-by))**2)+((abs(az-bz))**2));
print("벡터1 벡터2: {}".format(v12))

v23 = math.sqrt(((abs(cx-bx))**2)+((abs(cy-by))**2)+((abs(cz-bz))**2));
print("벡터2 벡터3: {}".format(v23))

v13 = math.sqrt(((abs(ax-cx))**2)+((abs(ay-cy))**2)+((abs(az-cz))**2));
print("벡터1 벡터3: {}".format(v13))

#코사인유사도
print("------코사인 유사도 ------")
c12 = (ax*bx+ay*by+az*bz)/((math.sqrt(ax**2+ay**2+az**2))*(math.sqrt(bx**2+by**2+bz**2)))
print("벡터1 벡터2: {}".format(c12))

c23 = (cx*bx+cy*by+cz*bz)/((math.sqrt(cx**2+cy**2+cz**2))*(math.sqrt(bx**2+by**2+bz**2)))
print("벡터2 벡터3: {}".format(c23))

c13 = (ax*cx+ay*cy+az*cz)/((math.sqrt(ax**2+ay**2+az**2))*(math.sqrt(cx**2+cy**2+cz**2)))
print("벡터1 벡터3: {}".format(c13))

#유클리디안 거리로 보았을 때 가장 가까운 벡터 2개
print("유클리디안 거리로 보았을 때 가장 가까운 벡터 2개 : ")
v = [v12, v23, v13]
k = max(v)
v.remove(k)

print("가장 가까운 벡터 2개: ",v)

#코사인 유사도로 보았을 때 가장 유사한 벡터 2개
print("코사인 유사도로 보았을 때 가장 가까운 벡터 2개 : ")
c = [abs(1-c12), abs(1-c23), abs(1-c13)]
n = max(c)
c.remove(n)
m = [c[0]+1, c[1]+1]
print("가장 가까운 벡터 2개: ",m)