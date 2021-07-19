import cv2
import numpy as np

Path = 'data/'
Name = 'exam1.jpg'
FileName = Path + Name
# 이미지 읽어오기 #
img = cv2.imread(FileName)


# 색상 (Hue) : 0 ~ 180의 값을 지닙니다.
# 채도 (Saturation) : 0 ~ 255의 값을 지닙니다.
# 명도 (Value) : 0 ~ 255의 값을 지닙니다.

bi = 180/255
min_value = (129*bi,150,50)
max_value = (150*bi,255,255)

img = cv2.resize(img, (640, 360))
dst = img.copy()
blur_img = cv2.GaussianBlur(img, (5, 5), 0)
hsv = cv2.cvtColor(blur_img, cv2.COLOR_BGR2HSV)

cv2.imshow("blur_img", blur_img)
cv2.imshow("original_img", img)
cv2.imshow("hsv", hsv)

binary_img = cv2.inRange(hsv, min_value, max_value)
canny_img = cv2.Canny(binary_img, 500, 830)
lines = cv2.HoughLines(canny_img, 1, np.pi/180, 100)

for i in lines:
    rho, theta = i[0][0], i[0][1]
    a, b = np.cos(theta), np.sin(theta)
    x0, y0 = a*rho, b*rho

    scale = dst.shape[0] + dst.shape[1]

    x1 = int(x0 + scale * -b)
    y1 = int(y0 + scale * a)
    x2 = int(x0 - scale * -b)
    y2 = int(y0 - scale * a)

    cv2.line(dst, (x1, y1), (x2, y2), (0, 0, 255), 2)

cv2.imshow("dst", dst)

cv2.imshow("binary_img", binary_img)
cv2.imshow("Canny", canny_img)

result_img = cv2.bitwise_and(img, img, mask = binary_img)
cv2.imshow("mask_img", result_img)



cv2.waitKey()
cv2.destroyAllWindows()