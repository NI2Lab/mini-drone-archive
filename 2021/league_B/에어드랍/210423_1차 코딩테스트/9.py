X, Y, Z = list(map(int, input().split()))
A = 0
num = 0
while (A <= Z):
    if A+X < Z:
        A += X - Y
        num += 1
    else:
        num += 1
        print(num)
        break
    
    
    
    
    

    
    
    
    