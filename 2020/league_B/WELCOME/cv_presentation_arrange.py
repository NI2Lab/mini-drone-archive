import cv2
import numpy as np

cap = cv2.VideoCapture("line_test2.mp4")

kernel = np.ones((5, 5), np.uint8)

while cap.isOpened():
    ret, frame = cap.read()

    # res = np.zeros_like(frame)
    # res2 = np.zeros_like(frame)
    # white = np.zeros_like(frame) + 255

    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)


    # 추출할 color 지정 
    lower_black = ( 0,  0, 0)       # h : 0~180, s : 0~255, v : 0~255
    upper_black = ( 180, 255, 80)
    img_mask = cv2.inRange(hsv, lower_black, upper_black)
    img_mask_inv = cv2.bitwise_not(img_mask)

    # cv2.bitwise_and(frame, frame, res, img_mask)
    # cv2.bitwise_and(frame, white, res2, img_mask_inv)
    

    # cv2.imshow("res", res)
    # cv2.imshow("res", res2)


    res = cv2.bitwise_not(frame, mask = img_mask)
    res2 = cv2.bitwise_and(frame, frame, mask = img_mask)
    gray2 = cv2.cvtColor(res, cv2.COLOR_BGR2GRAY)

    ret2, img_hsv_bin = cv2.threshold(gray2, 230, 255, cv2.THRESH_BINARY)
    # img_hsv_bin = cv2.adaptiveThreshold(gray2, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 21, 2)

    edge = cv2.Canny(img_hsv_bin, 50, 200,)

    lines = cv2.HoughLinesP(edge, 1, np.pi/180, 5, minLineLength=5, maxLineGap = 5)

    # lines = cv2.HoughLines(edge, 1, np.pi/180, 100)

    hough = edge.copy()
    hough = cv2.cvtColor(hough, cv2.COLOR_GRAY2BGR)

    try:
        for line in lines:
           x1, y1, x2, y2 = line[0]
           cv2.line(hough, (x1, y1), (x2, y2), (0, 0, 255), 2)

        # for line in lines:
        #     r, theta = line[0]
        #     a = np.cos(theta)
        #     b = np.sin(theta)
        #     x0 = a*r
        #     y0 = b*r
        #     x1 = int(x0 + 1000*(-b))
        #     y1 = int(y0 + 1000*a)
        #     x2 = int(x0 - 1000 * (-b))
        #     y2 = int(y0 - 1000*a)

        #     cv2.line(hough, (x1, y1), (x2, y2), (0, 0, 255), 1)
    except:
        pass


 

    cv2.imshow('RGB', frame)
    cv2.imshow('res', res)
    cv2.imshow('res2', res2)
    cv2.imshow('hsv_bin', img_hsv_bin)

    cv2.imshow('canny', edge)
    cv2.imshow('hough', hough)

    key = cv2.waitKey(100)
    if key == 27:
        break

cap.release()
cv2.destroyAllWindows()
