import cv2
import numpy as np

Path = 'data/'
Name = 'strait2.jpg'
FileName = Path + Name
# 이미지 읽어오기 #
img = cv2.imread(FileName)


# 색상 (Hue) : 0 ~ 180의 값을 지닙니다.
# 채도 (Saturation) : 0 ~ 255의 값을 지닙니다.
# 명도 (Value) : 0 ~ 255의 값을 지닙니다.
rate_h = 180/255
min_h = 129 * rate_h
max_h = 150 * rate_h
min_value = (min_h,150,50)
max_value = (max_h,255,255)

# img = cv2.resize(img, (320, 180))
w = 640
h = 360
img = cv2.resize(img, (w, h))
dst = img.copy()
blur_img = cv2.GaussianBlur(img, (5, 5), 0)
hsv = cv2.cvtColor(blur_img, cv2.COLOR_BGR2HSV)

# cv2.imshow("blur_img", blur_img)
cv2.imshow("original_img", img)
# cv2.imshow("hsv", hsv)

binary_img = cv2.inRange(hsv, min_value, max_value)
canny_img = cv2.Canny(binary_img, 500, 830)
lines = cv2.HoughLines(canny_img, 1, np.pi/180, 100)

cv2.imshow("binary_img", binary_img)
cv2.imshow("Canny", canny_img)

for i in lines:
    rho, theta = i[0][0], i[0][1]
    a, b = np.cos(theta), np.sin(theta)
    x0, y0 = a*rho, b*rho

    scale = dst.shape[0] + dst.shape[1]

    x1 = int(x0 + scale * -b)
    y1 = int(y0 + scale * a)
    x2 = int(x0 - scale * -b)
    y2 = int(y0 - scale * a)

    cv2.line(dst, (x1, y1), (x2, y2), (0, 0, 255), 3)
# 허프변환 라인 그린 이미지
cv2.imshow("dst", dst)

# result_img = cv2.bitwise_and(img, img, mask = binary_img)
# cv2.imshow("mask_img", result_img)

find_yindex = 120
H = h-find_yindex
a=np.where(dst[H]==(0,0,255))
a = a[0]
a = int(np.mean(a))

dst[H-5:H+5, :] = (0x62, 0x8d, 0x00)
for y in range(H-5, H+5):
    for i in range(a-5, a+5):
        dst[y, i] = (0,0,0)

cv2.line(dst, (int(w / 2), h), (a, H), (0, 0, 255), 3)

#if((w / 2 - a) )
leanear = h - H / (w / 2) - a - 22
print(w/2 - a)
print(leanear)

cv2.imshow("dst", dst)

cv2.waitKey()
cv2.destroyAllWindows()