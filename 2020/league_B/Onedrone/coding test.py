import numpy as np

input_str = "2 4\n2 3 14 3 23 1 4 6 5\n 6 30 25 1 32 64 34 23"
a= input_str.split('\n')
b=a[0]
b = b.split()
b=list(map(int,b))
del a[0]
for i in range(0,b[0],1):
    C= a[i] + " " + a[i+1]
C= C.split()
C= list(map(int,C))
tep= len(C)//2
D=C[0:tep]
D=np.array(D)
D=D.reshape(b[0],b[1])
E=C[tep:len(C)]
E=np.array(E)
E=E.reshape(b[0],b[1])


print(D+E)
print(D-E)
print(D*E)
print(D//E)
print(D%E)
print(D**E)