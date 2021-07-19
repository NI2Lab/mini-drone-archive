import cv2
import numpy as np

Thre = 61
img = cv2.imread('ex18.png')
img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
H = img[:, :, 0]
_, bi_H = cv2.threshold(H, Thre - 5, 255, cv2.THRESH_BINARY)
_, bi_H_ = cv2.threshold(H, Thre + 4, 255, cv2.THRESH_BINARY_INV)
G = cv2.bitwise_and(bi_H, bi_H_)
cv2.imshow('bi_H', G)
key = cv2.waitKey(0) & 0xFF

cv2.destroyAllWindows()

G = np.array(G)

index = np.where(G == 255)
new_A = np.array([])
real_A = np.array([])
new_B = np.array([])
real_B = np.array([])
for i in range(np.min(index[0]), np.max(index[0])+1):
    if np.count_nonzero(index[0] == i) > 530:
        new_A = np.append(new_A, i)
for i in range(1, np.size(new_A)-1):
    if (new_A[i]-new_A[i-1]) > 120:
        real_A = np.append(real_A,[new_A[i-1],new_A[i]])
for i in range(np.min(index[1]), np.max(index[1])+1):
    if np.count_nonzero(index[1] == i) > 400:
        new_B = np.append(new_B, i)
for i in range(1, np.size(new_B)-1):
    if (new_B[i]-new_B[i-1]) > 180:
        real_B = np.append(real_B,[new_B[i-1],new_B[i]])

print(int((np.sum(real_B)//2)), end=" ")
print(int(np.sum(real_A)//2))
