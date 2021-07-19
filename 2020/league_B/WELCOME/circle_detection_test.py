import cv2
import numpy as np

kernel1 = np.ones((3,3), np.uint8)
kernel2 = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (4, 4))


# img = cv2.imread('test_image/33.jpg', cv2.IMREAD_COLOR)
img = cv2.imread('test_image/11.jpg', cv2.IMREAD_COLOR)

img2 = img.copy()

hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
yuv = cv2.cvtColor(img, cv2.COLOR_BGR2YUV)

# hist_equl = cv2.equalizeHist(gray)

# Gau_blur = cv2.GaussianBlur(gray, (3, 3), 0)

bilateral_filtered_img = cv2.bilateralFilter(yuv, 5, 175, 175)


edge_img = cv2.Canny(bilateral_filtered_img, 50, 200)
# edge_img = cv2.dilate(edge_img, kernel2, iterations=1)
# edge_img = cv2.bitwise_not(edge_img)

gray_with_edge = cv2.bitwise_and(edge_img, gray)



cv2.imshow('gray', gray)
# cv2.imshow('hist_equl', hist_equl)
cv2.imshow('bilateral', bilateral_filtered_img)
cv2.imshow('bi_edge', edge_img)
# cv2.imshow('gray_with_img', gray_with_edge)


detected_circles = cv2.HoughCircles(edge_img, cv2.HOUGH_GRADIENT, 1, 50,
                                    param1 = 50, param2 = 30,
                                    minRadius = 0, maxRadius = 0)

if detected_circles is not None:
    for i in detected_circles[0,:]:
        a, b, r = i

        cv2.circle(img, (a,b), r, (0, 255, 0), 2)
        cv2.circle(img, (a, b), 1, (0, 0, 255), 3)

cv2.imshow("circle", img)
cv2.waitKey(0)
