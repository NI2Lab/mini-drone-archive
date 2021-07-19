from picamera.array import PiRGBArray
from picamera import PiCamera
import time
import cv2
import numpy as np
import math
import threading,time
from time import sleep
from e_drone.drone import *
from e_drone.protocol import *


def test1():
    

    camera = PiCamera( )
    camera.resolution = (320,240)
    camera.framerate = 40
    rawCapture = PiRGBArray(camera, size=(320,240))



    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        frame1 = frame.array    
        frame1 = cv2.flip(frame1,0)
        frame1 = cv2.flip(frame1,1)
        blur = cv2.GaussianBlur(frame1,(5,5),0)
        hsv = cv2.cvtColor(blur,cv2.COLOR_BGR2HSV)
        cv2.circle(frame1,(160,120),6,(0,255,255),2)

    
        frame2 = frame1[0:240, 0:320]
        frame2 = cv2.GaussianBlur(frame2,(5,5),0)
        frame2 = cv2.cvtColor(frame2,cv2.COLOR_BGR2HSV)

        lower_green = np.array([48,169,0])
        upper_green = np.array([85,255,255])
        frame2 = cv2.inRange(frame2,lower_green,upper_green)
        global contours1
        contours1,_ = cv2.findContours(frame2, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        global x1, x2, x3, x4, y1, y2, y3, y4
        x1, x2, x3, x4, y1, y2, y3, y4 = 1, 1, 1, 1, 1, 1, 1, 1

    
        cv2.line(frame1,(0,0),(320,0),(0,0,0),1)
        cv2.line(frame1,(0,240),(320,240),(0,0,0),1)


    
        lower_red = np.array([0,135,0])
        upper_red = np.array([17,255,255])
        frame3 = cv2.inRange(hsv,lower_red,upper_red)
        global x21,x23,y23,y21
        contours2,_ = cv2.findContours(frame3, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        x21, x22, x23, x24, y21, y22, y23, y24 = 1, 1, 1, 1, 1, 1, 1, 1

    
        lower_blue = np.array([94,95,48])
        upper_blue = np.array([115,255,122])
        frame4 = cv2.inRange(hsv,lower_blue,upper_blue)
        global x31,x33,y31,y33
        contours3,_ = cv2.findContours(frame4, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        x31,x32,x33,x34,y31,y32,y33,y34=1,1,1,1,1,1,1,1

    
        if len(contours1)>0:
            for i in range(len(contours1)):
                area1 = cv2.contourArea(contours1[i])
                if area1>5000:
                    rect1 = cv2.minAreaRect(contours1[i])
                    box1 = cv2.boxPoints(rect1)
                    box1 = np.int0(box1)
                    if 0<=box1[1][0]<=320 and 0<=box1[3][0]<=320:
                        cv2.drawContours(frame1,[box1],-1,(0,255,0),3)
 
                        x1,y1 = box1[0]
                        x2,y2 = box1[1]
                        x3,y3 = box1[2]
                        x4,y4 = box1[3]


    
        if len(contours2)>0:
            
            for i in range(len(contours2)):
                
                area2 = cv2.contourArea(contours2[i])
                
                if area2 > 100:
                    
                    rect2 = cv2.minAreaRect(contours2[i])
                    box2 = cv2.boxPoints(rect2)
                    box2 = np.int0(box2)

                    cv2.drawContours(frame1,[box2],-1,(0,255,255),3)
                    
                    
                    x21, y21 = box2[0]
                    x23, y23 = box2[2]

    
        if len(contours3)>0:
            
            for i in range(len(contours3)):
                
                area3 = cv2.contourArea(contours3[i])
                
                if area3 > 100:
                    
                    rect3 = cv2.minAreaRect(contours3[i])
                    box3 = cv2.boxPoints(rect3)
                    box3 = np.int0(box3)

                    cv2.drawContours(frame1,[box3],-1,(0,255,255),3)

                    x31, y31 = box3[0]
                    x33, y33 = box3[2]
             
    

    
        global redarea, bluearea
        
    
        redarea = (abs((int(x21)-int(x23))*(int(y21)-int(y23)))+abs((int(x22)-int(x24))*(int(y22)-int(y24))))/2

    
        bluearea = (abs((int(x31)-int(x33))*(int(y31)-int(y33)))+abs((int(x32)-int(x34))*(int(y32)-int(y34))))/2

    
        global LgapX,LgapY, gab1
        
        LgapX=(int(x1)+int(x3)+int(x2)+int(x4))/4-160    
        LgapY=(int(y1)+int(y3)+int(y2)+int(y4))/4-120
        cv2.imshow("frame",frame1)
    ## 트랙 중간지점과 거리 표시 ##
        #cv2.line(frame1,(int((x1+x3)/2),120),(160,120),(255,255,0),3)
        #cv2.putText(frame1,"gab="+str(gab),(int((x1+x3)/2)+10,120-10),cv2.FONT_HERSHEY_SIMPLEX,1,(255,0,0),1,cv2.LINE_AA)

        #if redarea>10000: ## 값 수정 필요
            #cv2.putText(frame1,"Detected",(200,30),cv2.FONT_HERSHEY_SIMPLEX,0.7,(0,0,255),1,cv2.LINE_AA)
        #if greenarea>10000: ## 값 수정 필요
            #cv2.putText(frame1,"Detected",(200,60),cv2.FONT_HERSHEY_SIMPLEX,0.7,(0,255,0),1,cv2.LINE_AA)
        


        key = cv2.waitKey(1) & 0xFF

        rawCapture.truncate(0)

        if key == ord("q"):
            break

def test2():

    

    if __name__ == '__main__':

        drone = Drone()
        drone.open()
        drone.sendLightManual(DeviceType.Drone, 0xFF, 0)
        sleep(1);

        print("TakeOff")
        drone.sendTakeOff()
        for i in range(3, 0, -1):
            print(i)
            sleep(1)

        print("hovering")
        sleep(1)

        ##print("상승")
        ##drone.sendControlPosition16(0, 0, 1, 20, 0, 0)
        ##sleep(3)

        
        global cnt,cnt2, cntred, cntup, cntdown, cntblue

        cnt=0
        cnt2=0
        cntred=0
        cntblue=0

        cntup=0
        cntdown=0

        print("길게 전진")
        drone.sendControlPosition16(8, 0, 0, 5, 0, 0)
        for i in range(3, 0, -1):
            print(i)
            sleep(1)
        
        while True :

            

            if cntred == 1 and cnt2 == 0 :

                

                while True :

                    if LgapY > -118 and LgapY < -15 :
                        
                        print("상승")
                        drone.sendControlPosition16(0, 0, 1, 15, 0, 0)
                        sleep(1)
                        
                        cntup+=1

                    elif LgapY > 15 and LgapY < 118 :
                        
                        print("하강")
                        drone.sendControlPosition16(0, 0, -1, 15, 0, 0)
                        sleep(1)

                        cntdown+=1

                    elif LgapY >= -15 and LgapY <= 15 :

                        print("고도 확인, 주행을 시작합니다.")
                        sleep(1)

                        cnt2+=1

                        break
                        
            


            if cntred == 2  :

                print("좌우이동된 목표를 찾기위해 탐색합니다.")
                sleep(3)

                print("우회전하여 목표 찾는 중")
                drone.sendControlPosition16(0,0,0,10,-45,40)
                sleep(5)

                if x1==1 and y1==1 :

                    print("목표 확인불가, 목표는 좌측에 위치함.")
                    sleep(1)
                    
                    print("정면 조정")
                    drone.sendControlPosition16(0,0,0,10,45,40)
                    sleep(3)
                    
                    print("좌로 이동")
                    drone.sendControlPosition16(0, 9, 0, 15, 0, 0)
                    sleep(3)

                    if cntup < cntdown :

                        print("목표는 위에 위치함.")
                        sleep(1)

                        print("상승")
                        drone.sendControlPosition16(0, 0, 7, 15, 0, 0)
                        sleep(3)

                    elif cntup >= cntdown :

                        print("목표는 아래에 위치함.")
                        sleep(1)

                        print("하강")
                        drone.sendControlPosition16(0, 0, -7, 15, 0, 0)
                        sleep(3)
                        
                    
                    cnt=-1
                    cntred+=1

                else :
                    
                    print("목표 확인완료, 목표는 우측에 위치함.")
                    sleep(1)
                    
                    print("정면 조정")
                    drone.sendControlPosition16(0,0,0,10,45,40)
                    sleep(3)
                    
                    print("우로 이동")
                    drone.sendControlPosition16(0, -9, 0, 15, 0, 0)
                    sleep(3)

                    if cntup < cntdown :

                        print("목표는 위에 위치함.")
                        sleep(1)

                        print("상승")
                        drone.sendControlPosition16(0, 0, 7, 15, 0, 0)
                        sleep(3)

                    elif cntup >= cntdown :

                        print("목표는 아래에 위치함.")
                        sleep(1)

                        print("하강")
                        drone.sendControlPosition16(0, 0, -7, 15, 0, 0)
                        sleep(3)
                    
                    cnt=-1
                    cntred+=1
                    
            

            if x1 != 1 and y1 != 1 :

                

                if cnt < 3 :

                    
            
                    if LgapX > -158 and LgapX < -20:

                        print("좌로 이동")
                        drone.sendControlPosition16(0, 1, 0, 15, 0, 0)
                        sleep(1)

                    elif LgapX > 20 and LgapX < 158:

                        print("우로 이동")
                        drone.sendControlPosition16(0, -1, 0, 15, 0, 0)
                        sleep(1)

                    


                    if LgapY > -118 and LgapY < -15 :
                        
                        print("상승")
                        drone.sendControlPosition16(0, 0, 1, 15, 0, 0)
                        sleep(1)

                    elif LgapY > 15 and LgapY < 118 :
                        
                        print("하강")
                        drone.sendControlPosition16(0, 0, -1, 15, 0, 0)
                        sleep(1)


                    if LgapX >= -20 and LgapX <= 20 and LgapY >= -15 and LgapY <= 15 :
                        
                        print("전진")
                        drone.sendControlPosition16(2, 0, 0, 17, 0, 0)
                        sleep(1)
                        cnt+=1

                

                else :

                    

                    if LgapX > -158 and LgapX < -20 :
                        
                        print("우로 이동")
                        drone.sendControlPosition16(0, -1, 0, 15, 0, 0)
                        sleep(1)

                    elif LgapX > 20 and LgapX < 158 :
                        
                        print("좌로 이동")
                        drone.sendControlPosition16(0, 1, 0, 15, 0, 0)
                        sleep(1) 

                    


                    if LgapY > -118 and LgapY < -15 :
                        
                        print("하강")
                        drone.sendControlPosition16(0, 0, -1, 15, 0, 0)
                        sleep(1)

                    elif LgapY > 15 and LgapY < 118 :
                        
                        print("상승")
                        drone.sendControlPosition16(0, 0, 1, 15, 0, 0)
                        sleep(1)

                    if LgapX >= -20 and LgapX <= 20 and LgapY >= -15 and LgapY <= 15 :
                        
                        print("전진")
                        drone.sendControlPosition16(2, 0, 0, 17, 0, 0)
                        sleep(1)
                        
            
                        
            else :

                if cnt < 3 :
                    
                    print("링 인식이 안된채로 전진")
                    drone.sendControlPosition16(2, 0, 0, 17, 0, 0)
                    sleep(3)
                    cnt+=1

                else :
                    
                    if redarea < 300 and bluearea <200 :
                        
                        print("원 찾아서 전진")
                        drone.sendControlPosition16(2, 0, 0, 15, 0, 0)
                        sleep(2)
                        
                        if cntred == 3 :
                            cntblue+=1
                        
                    elif redarea > 300 :
                        
                        print("좌회전")
                        drone.sendControlPosition16(0,0,0,10,90,40)
                        sleep(5)

                        if cntred == 0 or cntred == 1 :

                            ##if cntred == 0 :
                                
                                ##print("상승")
                                ##drone.sendControlPosition16(0, 0, 2, 15, 0, 0)
                                ##sleep(1)
                                
                            cntred+=1

                        print("길게 전진")
                        drone.sendControlPosition16(8, 0, 0, 20, 0, 0)
                        sleep(2)
                        
                        cnt=-1

                        print("우측 이동")
                        drone.sendControlPosition16(0, -4, 0, 20, 0, 0)
                        sleep(5)

                    elif bluearea > 200 and cntred == 3 :

                        print("Landing")
                        drone.sendLanding()
                        break
                        
                    elif cntblue >= 3 :
                        
                        print("Landing")
                        drone.sendLanding()
                        break
                        
                
                                
                
    
t1=threading.Thread(target=test1)
t2=threading.Thread(target=test2)

t1.start()
t2.start()
