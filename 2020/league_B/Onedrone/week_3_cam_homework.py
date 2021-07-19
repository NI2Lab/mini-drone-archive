import cv2

Thre = 61
img = cv2.imread('ex.png')
img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
H = img[:, :, 0]
_, bi_H = cv2.threshold(H, Thre - 5, 255, cv2.THRESH_BINARY)
_, bi_H_ = cv2.threshold(H, Thre + 4, 255, cv2.THRESH_BINARY_INV)
G = cv2.bitwise_and(bi_H, bi_H_)
tempx = []
tempy = []
real_x = []
real_y = []
x1=0
x2=0
y1=0
y2=0
for i in range(0, 720):
    for j in range(0, 960):
        if G[i][j] == 255:
            tempx.append(i)
            tempy.append(j)

for i in range(0, 720):
    if i in tempx:
        if tempx.count(i) > 530:
            real_y.append(i)
for j in range(0, 960):
    if j in tempy:
        if tempy.count(j) > 400:
            real_x.append(j)

for i in range(1, len(real_y)-1):
    if real_y[i] - real_y[i-1] > 120:
        y1 = real_y[i-1]
        y2 = real_y[i]

for j in range(1, len(real_x)-1):
    if real_x[j] - real_x[j - 1] > 180:
        x1 = real_x[j - 1]
        x2 = real_x[j]

if (x1+x2)//2 == 0:
    for j in range(0, 960):
        if j in tempy:
            if tempy.count(j) > 350:
                real_x.append(j)

    for j in range(1, len(real_x) - 1):
        if real_x[j] - real_x[j - 1] > 180:
            x1 = real_x[j - 1]
            x2 = real_x[j]

if (y1 + y2) // 2 == 0:
    for i in range(0, 720):
        if i in tempx:
            if tempx.count(i) > 450:
                real_y.append(i)

    for i in range(1, len(real_y) - 1):
        if real_y[i] - real_y[i - 1] > 120:
            y1 = real_y[i - 1]
            y2 = real_y[i]

print((x1+x2)//2)
print((y1+y2)//2)