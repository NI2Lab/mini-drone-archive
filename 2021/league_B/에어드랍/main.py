from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
from time import sleep
import numpy as np
import cv2

#def
lower_purple = (120, 150, 55) #가장 잘보일 때 = h가 128일 때  
upper_purple = (150, 255, 255)

lower_red1 = (150, 30, 30)
upper_red1 = (190, 255, 255)
lower_red2 = (-10, 100, 55)
upper_red2 = (10, 255, 255)

lower_blue = (96, 190, 75) #가장 잘보일 때 = h가 112일 때
upper_blue = (114, 255, 255)


def find_center(img_hsv):
    img_mask_blue = cv2.inRange(img_hsv, lower_blue, upper_blue)
    img_blue = cv2.medianBlur(img_mask_blue, 15)
    value_th = np.where(img_blue[:, :] == 255)

    min_x = np.min(value_th[1])
    max_x = np.max(value_th[1])
    min_y = np.min(value_th[0])
    max_y = np.max(value_th[0])
    center_x = (min_x + max_x) / 2
    center_y = (min_y + max_y) / 2

    if (np.where(image_th[int(center_y), int(center_x):])==''): #원의 오른쪽이 안보이는 경우
        return 0,-1
    elif (np.where(image_th[int(center_y), int(center_x)::-1])==''): #원의 왼쪽이 안보이는 경우
        return 0,-2
    elif (np.where(image_th[int(center_y)::-1, int(center_x)])==''): #원의 위쪽이 안보이는 경우
        return -1,0
    elif (np.where(image_th[int(center_y):, int(center_x)])==''): #원의 아래쪽이 안보이는 경우
        return -2,0
    else :
        right = int(center_x) + np.min(np.where(image_th[int(center_y), int(center_x):]))
        left = int(center_x) - np.min(np.where(image_th[int(center_y), int(center_x)::-1]))
        up = int(center_y) - np.min(np.where(image_th[int(center_y)::-1, int(center_x)]))
        down = int(center_y) + np.min(np.where(image_th[int(center_y):, int(center_x)]))

        center_x = int((right + left) / 2)
        center_y = int((up + down) / 2)

        return center_x, center_y

def find_blue(img_hsv):
    img_mask_blue = cv2.inRange(img_hsv, lower_blue, upper_blue)
    img_blue = cv2.medianBlur(img_mask_blue, 15)
    value_th = np.where(img_blue[:, :] == 255)

    if value_th[1]==0 or value_th[0]==0 :
        return 0
    else :
        return 1 
    
def check_position(img_hsv):
    img_mask_blue = cv2.inRange(img_hsv, lower_blue, upper_blue)
    img_blue = cv2.medianBlur(img_mask_blue, 15)
    value_th = np.where(img_blue[:, :] == 255)

    min_x = np.min(value_th[1])
    max_x = np.max(value_th[1])
    min_y = np.min(value_th[0])
    max_y = np.max(value_th[0])
    center_x = (min_x + max_x) / 2
    center_y = (min_y + max_y) / 2

    if (np.where(image_th[int(center_y), int(center_x):])==''): #원의 오른쪽이 안보이는 경우
        return 1,1
    elif (np.where(image_th[int(center_y), int(center_x)::-1])==''): #원의 왼쪽이 안보이는 경우
        return 1,1
    elif (np.where(image_th[int(center_y)::-1, int(center_x)])==''): #원의 위쪽이 안보이는 경우
        return 1,1
    elif (np.where(image_th[int(center_y):, int(center_x)])==''): #원의 아래쪽이 안보이는 경우
        return 1,1
    else :
        return 0,0

    
#main
drone = Drone()
drone.open()

try:
    drone.sendTakeOff() #이륙
    sleep(5) #드론이 안정적으로 이륙하도록 5초를 쉬어준다.
    
    camera = PiCamera()
    camera.resolution = (640, 480)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(640, 480))

    find = True
    step = 1
    know_center = 0

    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        rawCapture.truncate(0)

        if step==1 : #1, 1단계 파란색 천의 중심 찾기
            
            drone.sendControlWhile(0,0,0,0,1000) #호버링
            sleep(1)

            #파란색 천 중심좌표 찾기
            
            while(find):
                
                cx,cy = find_center(img_hsv) #파란색 천의 중심좌표
                
                if cx == 0 and cy == -1 : #원의 오른쪽이 안보이는 경우
                    drone.sendControlPosition16(0, -1, 0, 5, 0, 0) #오른쪽으로 이동 
                    sleep(1)
                    continue
                elif cx == 0 and cy == -2 : #원의 왼쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 1, 0, 5, 0, 0) #왼쪽으로 이동
                    sleep(1)
                    continue
                elif cx == -1 and cy == 0 : #원의 위쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                    continue
                elif cx == -2 and cy == 0 : #원의 아래쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
                    continue
                else :
                    find = False 

            #드론 카메라의 중심과 파란색 천의 중심좌표를 비교해서 드론 위치 이동시키기
                    
            if cx < 320-80 : 
                drone.sendControlPosition16(0, 1, 0, 5, 0, 0) #왼쪽으로 이동
                sleep(1)
                if cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+50 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)                    
            elif cx > 320+80 :
                drone.sendControlPosition16(0, -1, 0, 5, 0, 0) #오른쪽으로 이동
                sleep(1)
                if cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+50 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
            elif cy > 240+50 :
                drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                sleep(1)
            elif cy < 240-50 :
                drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                sleep(1)
            else :
                know_center = 1

            #천을 통과하기 전 드론의 위치 파악 

            if know_center==1 :
                
                while():
                    a,b = check_position(img_hsv)
                    if a == 0 and b == 0 :
                        drone.sendControlPosition16(1, 0, 0, 5, 0, 0) #앞으로 0.1미터 이동
                        sleep(1)
                        continue
                    else :
                        drone.sendControlPosition16(16, 0, 0, 5, 0, 0) #앞으로 1.6미터 이동 
                        sleep(3)
                        know_center = 0
                        step = 2
                        break                       

        elif step==2 : #2, 빨간색 네모 찾기
            
            drone.sendControlWhile(0,0,0,0,1000) #호버링
            sleep(1)

            drone.sendControlPosition16(0, 0, 0, 0, 90, 30) #왼쪽으로 90도 회전
            sleep(3)

            drone.sendControlWhile(0,0,0,0,2000) #호버링
            sleep(2)

            drone.sendControlPosition16(10, 0, 0, 5, 0, 0) #앞으로 1미터 이동
            sleep(2)
            
            step = 3
            find = True

        elif step==3 : #3, 2단계 파란색 천의 중심찾기
            
            drone.sendControlWhile(0,0,0,0,1000) #호버링
            sleep(1)

            while(find):
                
                cx,cy = find_center(img_hsv) #파란색 천의 중심좌표
                
                if cx == 0 and cy == -1 : #원의 오른쪽이 안보이는 경우
                    drone.sendControlPosition16(0, -1, 0, 5, 0, 0) #오른쪽으로 이동
                    sleep(1)
                    continue
                elif cx == 0 and cy == -2 : #원의 왼쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 1, 0, 5, 0, 0) #왼쪽으로 이동
                    sleep(1)
                    continue
                elif cx == -1 and cy == 0 : #원의 위쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                    continue
                elif cx == -2 and cy == 0 : #원의 아래쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
                    continue
                else :
                    find = False

             #드론 카메라의 중심과 파란색 천의 중심좌표를 비교해서 드론 위치 이동시키기
                    
            if cx < 320-80 : 
                drone.sendControlPosition16(0, 1, 0, 5, 0, 0) #왼쪽으로 이동
                sleep(1)
                if cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+50 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)                    
            elif cx > 320+80 :
                drone.sendControlPosition16(0, -1, 0, 5, 0, 0) #오른쪽으로 이동
                sleep(1)
                if cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+50 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
            elif cy > 240+50 :
                drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
            elif cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
            else :
                know_center = 1

            #천을 통과하기 전 드론의 위치 파악 

            if know_center==1 :
                
                while():
                    a,b = check_position(img_hsv)
                    if a == 0 and b == 0 :
                        drone.sendControlPosition16(1, 0, 0, 5, 0, 0) #앞으로 0.1미터 이동
                        sleep(1)
                        continue
                    else :
                        drone.sendControlPosition16(11, 0, 0, 5, 0, 0) #앞으로 1.1미터 이동 
                        sleep(2)
                        know_center = 0
                        step = 4
                        break                       

        elif step==4 : #4, 빨간색 네모 찾기
            drone.sendControlWhile(0,0,0,0,1000) #호버링
            sleep(1)

            drone.sendControlPosition16(0, 0, 0, 0, 90, 30) #왼쪽으로 90도 회전
            sleep(3)

            drone.sendControlWhile(0,0,0,0,2000) #호버링
            sleep(2)

            drone.sendControlPosition16(10, 0, 0, 5, 0, 0) #앞으로 1미터 이동
            sleep(2)
            step = 5
            find = True

        elif step==5 : #5, 3단계 파란색 천의 중심 찾기
            
            drone.sendControlWhile(0,0,0,0,1000) #호버링
            sleep(1)

            blue = find_blue(img_hsv)
            
            if blue==0 :
                drone.sendControlPosition16(0, 0, -5, 5, 0, 0) #아래로
                sleep(1)

                blue = find_blue(img_hsv)

                if blue==0 :
                    drone.sendControlPosition16(0, 0, 10, 5, 0, 0) #위로
                    sleep(2)

                    blue = find_blue(img_hsv)

                    if blue==0 :
                        drone.sendControlPosition16(0, 0, -5, 5, 0, 0) #제자리로
                        sleep(1)

                        drone.sendControlWhile(0,0,0,0,1000) #호버링
                        sleep(1)

                        drone.sendControlPosition16(0, 5, 0, 5, 0, 0) #왼쪽으로
                        sleep(1)

                        blue = find_blue(img_hsv)

                        if blue==0 :
                            drone.sendControlPosition16(0, -10, 0, 5, 0, 0) #오른쪽으로
                            sleep(2)

                            blue = find_blue(img_hsv)

                            if blue==0 :
                                drone.sendControlPosition16(0, 5, 0, 5, 0, 0) #제자리로
                                sleep(1)

                                drone.sendControlWhile(0,0,0,0,1000)
                                sleep(1)

                                drone.sendControlPosition16(0, 0, -5, 5, 0, 0) #아래로
                                sleep(1)

                                drone.sendControlPosition16(0, 5, 0, 5, 0, 0) #왼쪽으로
                                sleep(1)

                                blue = find_blue(img_hsv)

                                if blue==0 :
                                    print('there is no blue')
                                    drone.sendLanding()
                                    sleep(5)
                                    break

                                else :
                                    continue

                            else :
                                continue

                        else :
                            continue

                    else :
                        continue

                else :
                    continue
            
            else :
                continue
            

            while(find):
                
                cx,cy = find_center(img_hsv) #파란색 천의 중심좌표
                
                if cx == 0 and cy == -1 : #원의 오른쪽이 안보이는 경우
                    drone.sendControlPosition16(0, -1, 0, 5, 0, 0) #오른쪽으로 이동
                    sleep(1)
                    continue
                elif cx == 0 and cy == -2 : #원의 왼쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 1, 0, 5, 0, 0) #왼쪽으로 이동
                    sleep(1)
                    continue
                elif cx == -1 and cy == 0 : #원의 위쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                    continue
                elif cx == -2 and cy == 0 : #원의 아래쪽이 안보이는 경우
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
                    continue
                else :
                    find = False

             #드론 카메라의 중심과 파란색 천의 중심좌표를 비교해서 드론 위치 이동시키기
                    
            if cx < 320-80 : 
                drone.sendControlPosition16(0, 1, 0, 5, 0, 0) #왼쪽으로 이동
                sleep(1)
                if cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+50 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)                    
            elif cx > 320+80 :
                drone.sendControlPosition16(0, -1, 0, 5, 0, 0) #오른쪽으로 이동
                sleep(1)
                if cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+50 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
            elif cy > 240+50 :
                drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
            elif cy < 240-50 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
            else :
                know_center = 1

            #천을 통과하기 전 드론의 위치 파악 

            if know_center==1 :
                
                while():
                    a,b = check_position(img_hsv)
                    if a == 0 and b == 0 :
                        drone.sendControlPosition16(1, 0, 0, 5, 0, 0) #앞으로 0.1미터 이동
                        sleep(1)
                        continue
                    else :
                        drone.sendControlPosition16(10, 0, 0, 5, 0, 0) #앞으로 1미터 이동 
                        sleep(2)
                        know_center = 0
                        step = 6
                        break                       

            
        elif step==6 : #6, 보라색 네모 찾기
            drone.sendControlWhile(0,0,0,0,1000) #호버링
            sleep(1)

            drone.sendLanding()
            sleep(5)
            drone.close()
            break
        
except Exception as e:
    drone.sendLanding()
    drone.close()
