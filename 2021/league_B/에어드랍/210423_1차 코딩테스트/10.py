A, B = list(map(int, input().split()))
ans = ""
ans2 = ""
ans3 = 0
        
while A//B >= 1:
    remain = A%B 
    A = A// B 
    ans  = str(remain) + ans 
    if A < B  :
        ans  = str(A) + ans 
for i in ans [::-1]:
    ans2 += "".join(i)    

for idx, number in enumerate(ans2[::-1]):
    ans3 += int(number) * (B**idx)
print(ans3)