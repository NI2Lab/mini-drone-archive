import cv2
import numpy as np
import matplotlib.pyplot as plt

src_bgr = cv2.imread('test.png')
src_b, src_g, src_r = cv2.split(src_bgr)  # 색 채널 b g r 로 분리

print(f'SRC_BGR.SHAPE = {src_bgr.shape}')
rows, cols, channels = src_bgr.shape    # 가로, 세로, 채널수 얻어오기
middle_row, middle_col = rows // 2, cols // 2

partion_dict = {'1사분면': 0, '2사분면': 0, '3사분면': 0, '4사분면': 0}

fir = 0; sec = 0; thi = 0; fou = 0  # 1사분면 ~ 4사분면
for row in range(rows):
    for col in range(cols):
        if row < middle_row and col > middle_col:   # 제 1사분면
            partion_dict['1사분면'] += src_bgr[row, col, 1]             # Green Channel 값의 합
        elif row < middle_row and col < middle_col: # 제 2사분면
            partion_dict['2사분면'] += src_bgr[row, col, 1]             # Green Channel 값의 합
        elif row > middle_row and col < middle_col: # 제 3사분면
            partion_dict['3사분면'] += src_bgr[row, col, 1]             # Green Channel 값의 합
        else:                                       # 제 4사분면
            partion_dict['4사분면'] += src_bgr[row, col, 1]             # Green Channel 값의 합

print(partion_dict)
result = max(partion_dict)
print(result)
cv2.imshow('test.png', src_bgr)
cv2.waitKey(0)
exit(0)

for y in range(img.shape[0]):
    for x in range(img.shape[1]):
        if x > w / 2 and y < h / 2:  # 1 사분면
            fir = fir + img[x, y, 1]  # 총 초록색의 합
        elif x < w / 2 and y < h / 2:  # 2 사분면
            sec = sec + img[x, y, 1]
        elif x < w / 2 and y > h / 2:  # 3 사분면
            thi = thi + img[x, y, 1]
        else:  # 4 사분면
            fou = fou + img[x, y, 1]
panel = max(fir, sec, thi, fou)  # 최대값 저장

# 이미지 출력
# cv2.imshow('result', result)

image_gray = cv2.imread('test.png', cv2.IMREAD_GRAYSCALE)

plt.xticks([])
plt.yticks([])
plt.show()

blur = cv2.GaussianBlur(image_gray, ksize=(3, 3), sigmaX=0)  # 또는 ksize=(5,5)
ret, thresh1 = cv2.threshold(blur, 127, 255, cv2.THRESH_BINARY)

edged = cv2.Canny(blur, 10, 250)

kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (7, 7))
closed = cv2.morphologyEx(edged, cv2.MORPH_CLOSE, kernel)
cv2.imshow('closed', closed)
cv2.waitKey(0)

contours, _ = cv2.findContours(closed.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
total = 0

contours_xy = np.array(contours)
contours_xy.shape

# x의 min과 max 찾기
x_min, x_max = 0, 0
value = list()
for i in range(len(contours_xy)):
    for j in range(len(contours_xy[i])):
        value.append(contours_xy[i][j][0][0])  # 네번째 괄호가 0일때 x의 값
        x_min = min(value)
        x_max = max(value)

# y의 min과 max 찾기
y_min, y_max = 0, 0
value = list()
for i in range(len(contours_xy)):
    for j in range(len(contours_xy[i])):
        value.append(contours_xy[i][j][0][1])  # 네번째 괄호가 0일때 x의 값
        y_min = min(value)
        y_max = max(value)

center_x, center_y = (x_min + x_max) / 2, (y_min + y_max) / 2

# (+)
# matlab
#
# https: // kr.mathworks.com / help / images / roi - creation - overview.html
# https: // kr.mathworks.com / help / images / ref / images.roi.rectangle.html
# https: // kr.mathworks.com / help / matlab / ref / matlab.io.fits.getimgsize.html
# https: // kr.mathworks.com / help / images / ref / impixel.html
# https: // kr.mathworks.com / help / images / boundary - tracing - in -images.html