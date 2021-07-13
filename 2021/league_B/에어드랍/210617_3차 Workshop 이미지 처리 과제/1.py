import cv2
import numpy as np

input = input().split()
img= cv2.imread(input[0])
input = input[1], input[2]

min_hsv = (0, 110, 0)
max_hsv = (80, 160, 140)

img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
img_th = cv2.inRange(img, min_hsv, max_hsv)
value_th = np.where(img_th [:, :] == 255)
min_x = np.min(value_th[1])
max_x = np.max(value_th[1])
min_y = np.min(value_th[0])
max_y = np.max(value_th[0])
    
cen_x = (min_x + max_x) / 2
cen_y = (min_y + max_y) / 2

ri = int(cen_x) + np.min(np.where(img_th [int(cen_y), int(cen_x):]))
le= int(cen_x) - np.min(np.where(img_th [int(cen_y), int(cen_x)::-1]))
up = int(cen_y) - np.min(np.where(img_th [int(cen_y)::-1, int(cen_x)]))
do= int(cen_y) + np.min(np.where(img_th [int(cen_y):, int(cen_x)]))

cen_x= int((ri + le) / 2)
cen_y= int((up + do) / 2)

flag1 = 0
flag2 = 0
if int(input[0]) < cen_x+ 15 and int(input[0]) > cen_x- 15:
    flag1  = 1
if int(input[1]) < cen_y+ 15 and int(input[1]) > cen_y- 15:
    flag2 = 1

if flag1 == 1 and flag2 == 1:
    print("True")

else:
    print("False")