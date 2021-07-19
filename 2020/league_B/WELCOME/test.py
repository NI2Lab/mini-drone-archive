import cv2 
import numpy as np 
  
# Read image. 
img = cv2.imread('test_image/11.jpg', cv2.IMREAD_COLOR) 

hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV) # hsv 변환

h, s, v = cv2.split(hsv) # h, s, v 추출
# ttt = h&v#&gray
# hsv[:,:,2] = 150
# ttt = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
ttt = cv2.equalizeHist(gray)
ttt= cv2.GaussianBlur(ttt,(5, 5), 0)
# ret,th = cv2.threshold(ttt, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
# th = cv2.adaptiveThreshold(ttt, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)
kernel = np.ones((3, 3), np.uint8)

edge1 = cv2.Canny(ttt, 230, 250)


kernel2 = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5,5))
th = cv2.morphologyEx(edge1, cv2.MORPH_CLOSE, kernel2,iterations = 1)

cv2.imshow('gray',gray)
cv2.imshow('edge',edge1)
cv2.imshow('all',ttt)
cv2.imshow('th', th)


#허프만
detected_circles = cv2.HoughCircles(th,  cv2.HOUGH_GRADIENT, 1, 50, 
                                    param1 = 1, param2 =45,
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