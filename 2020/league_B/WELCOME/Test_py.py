import cv2 
import numpy as np 
  
# Read image. 
img = cv2.imread('test_image/11.jpg', cv2.IMREAD_COLOR) 

hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV) # hsv 변환
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
h, s, v = cv2.split(hsv) # h, s, v 추출
ttt = s&v#&gray
ret,th = cv2.threshold(ttt, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
kernel = np.ones((7, 7), np.uint8)
th = cv2.morphologyEx(th, cv2.MORPH_CLOSE, kernel)
edge1 = cv2.Canny(ttt, 230, 250)
cv2.imshow('S',s)
cv2.imshow('V',v)
cv2.imshow('gray',edge1)
cv2.imshow('all',ttt)
cv2.imshow('th', th)

#허프만
detected_circles = cv2.HoughCircles(edge1,  cv2.HOUGH_GRADIENT, 1, 50, 
                                    param1 = 40, param2 = 35,
                                   minRadius = 0, maxRadius = 0) 
  
# 원 그리기 
if detected_circles is not None: 
  
    # 좌표찾기
    detected_circles = np.uint16(np.around(detected_circles)) 
  
    for pt in detected_circles[0, :]: 
        a, b, r = pt[0], pt[1], pt[2] 
  
        # 원 그리기
        cv2.circle(img, (a, b), r, (0, 255, 0), 2) 
  
        # 중심 그리기 
        cv2.circle(img, (a, b), 1, (0, 0, 255), 3) 
cv2.imshow("Detected Circle", img) 
cv2.waitKey(0)