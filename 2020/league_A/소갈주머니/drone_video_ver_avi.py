import cv2
import numpy as np

Path = 'data/'
Name = 'mp2.mp4'
FileName = Path + Name
# 이미지 읽어오기 #
cap = cv2.VideoCapture(FileName)

# 색상 (Hue) : 0 ~ 180의 값을 지닙니다.
# 채도 (Saturation) : 0 ~ 255의 값을 지닙니다.
# 명도 (Value) : 0 ~ 255의 값을 지닙니다.
rate_h = 180/255
min_h = 100 * rate_h
max_h = 160 * rate_h
min_value = (min_h,150,0)
max_value = (max_h,255,255)

while(True):
    try:
        ret, frame = cap.read()

        if ret == False:
            break

        # img = cv2.resize(img, (320, 180))
        w = 320
        h = 640
        img = cv2.resize(frame, (w, h))
        dst = img.copy()
        # img = img[int(h/2):h, :]
        img_copy = np.zeros(img.shape, np.uint8)
        img_copy[int(h / 2):h, :] = 255
        img_copy = cv2.cvtColor(img_copy, cv2.COLOR_BGR2GRAY)
        # img = cv2.bitwise_and(img, img_copy)

        blur_img = cv2.GaussianBlur(img, (5, 5), 0)
        hsv = cv2.cvtColor(blur_img, cv2.COLOR_BGR2HSV)


        cv2.imshow("original_img", img)


        binary_img = cv2.inRange(hsv, min_value, max_value)
        # kernel = np.ones((11, 11), np.uint8)
        # binary_img = cv2.erode(binary_img,kernel)
        kernel = np.ones((11, 11), np.uint8)
        binary_img = cv2.dilate(binary_img, kernel, iterations=1)
        binary_img = cv2.erode(binary_img, kernel)

        canny_img = cv2.Canny(binary_img, 50, 300)
        canny_img = cv2.bitwise_and(img_copy,canny_img)
        lines = cv2.HoughLines(canny_img, 1, np.pi/180, 100)

        cv2.imshow("binary_img", binary_img)
        cv2.imshow("Canny", canny_img)
        if lines is not None:
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
        else:
            continue
        # 허프변환 라인 그린 이미지
        cv2.imshow("dst", dst)

        result_img = cv2.bitwise_and(img, img, mask = binary_img)
        cv2.imshow("mask_img", result_img)

        find_yindex = 120
        H = h-find_yindex
        a=np.where(dst[H]==(0,0,255))
        # print(a)
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

        if cv2.waitKey(70) & 0xFF == 27:
            break

    except:
        continue

cap.release()
cv2.destroyAllWindows()