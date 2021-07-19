import cv2
import numpy as np
import math

Path = 'data/'
Name = 'mp2.mp4'
FileName = Path + Name
# 이미지 읽어오기 #
cap = cv2.VideoCapture(FileName)

# 색상 (Hue) : 0 ~ 180의 값을 지닙니다.
# 채도 (Saturation) : 0 ~ 255의 값을 지닙니다.
# 명도 (Value) : 0 ~ 255의 값을 지닙니다.
rate_h = 180/255
blue_min_h = 90 * rate_h
blue_max_h = 170 * rate_h
blue_min_value = (blue_min_h,100,0)
blue_max_value = (blue_max_h,255,255)

red_min_h = 170 * rate_h
red_max_h = 290 * rate_h
red_min_value = (red_min_h, 90, 0)
red_max_value = (red_max_h, 180, 255)

while(True):
    ret, frame = cap.read()

    if ret == False:
        break

    # img = cv2.resize(img, (320, 180))
    w = 320
    h = 640
    img = cv2.resize(frame, (w, h))
    dst = img.copy()
    blur_img = cv2.GaussianBlur(img, (5, 5), 0)
    hsv = cv2.cvtColor(blur_img, cv2.COLOR_BGR2HSV)


    cv2.imshow("original_img", img)

    binary_img = cv2.inRange(hsv, blue_min_value, blue_max_value)
    red_binary = cv2.inRange(hsv, red_min_value, red_max_value)
    kernel = np.ones((5,5), np.uint8)
    binary_img = cv2.dilate(binary_img,kernel,iterations=1)
    red_binary = cv2.dilate(red_binary,kernel,iterations=1)
    binary_img = cv2.bitwise_or(binary_img, red_binary)
    # red_binary = cv2.cvtColor()
    cv2.imshow('red_circle',red_binary)
    canny_img = cv2.Canny(binary_img, 50, 300)
    #lines = cv2.HoughLines(canny_img, 1, np.pi / 180, 165)
    lines = cv2.HoughLinesP(canny_img, 1, np.pi/180, 3)

    cv2.imshow("binary_img", binary_img)
    cv2.imshow("Canny", canny_img)
    try:
        if lines is not None:
            for i in lines:
                x1, y1, x2, y2 = i[0]

                cv2.line(dst, (x1, y1), (x2, y2), (0, 0, 255), 3)
        else:
            continue
        # 허프변환 라인 그린 이미지
        cv2.imshow("dst", dst)

        # result_img = cv2.bitwise_and(img, img, mask = binary_img)
        # cv2.imshow("mask_img", result_img)

        find_yindex = 120
        H = h-find_yindex
        a=np.where(dst[H]==(0,0,255))
        a = a[0]
        a = int(np.mean(a))
    except:
        print('error')
        continue

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

    if cv2.waitKey(50) & 0xFF == 27:
        break

cap.release()
cv2.destroyAllWindows()