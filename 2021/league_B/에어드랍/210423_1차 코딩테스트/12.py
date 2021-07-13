A = list(map(int, input().split()))
A = sorted(A)

print(sum(A[0:-1]), end=" ")
print(sum(A[1:5]))