#########################################################
#   @변경사항@
#
#   BlueSum 판단 기준 값 : 25000 -> 10000
#   각 프린트 내용에 BlueSum 값 출력
#   BlueSum크기 판단 전에 값 출력
#   red 픽셀 수로 red/purple 판단
##########################################################

from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
from time import sleep
import numpy as np
import cv2


lower_purple = (110, 0, 5)
upper_purple = (140, 255, 50)

#여기 threshold 값 수정 필요

lower_blue = (95, 0, 50)  
upper_blue = (110, 255, 250)

lower_red = (0, 0, 5)  
upper_red = (17, 255, 240)

level_cnt = 1
no_trap = True

mode = {1:[range(100, 30000), range(30000, 100000), range(100000, 150000), 150000], 
        2:[range(100, 50000), range(50000, 120000), range(120000, 170000), 170000], 
        3:[range(100, 70000), range(70000, 140000), range(140000, 200000), 200000]}  # [min,max]

lastBluesum = 0

#통과하는 level이 어느정도냐에 따라서 파란색 화면 픽셀수의 갯수도 달라진다. 상한선을 정해야할 필요가 있다
#[min, max] 로 구분지어두고, min 보다 작으면 미친직진 후 방향조절, 카메라 다시 받고 max 보다 크면
# 파란색(tmpB) 무게중심(cx, cy) 찾고, 그 무게 중심 어딨냐에 따라 1번정도 방향조정하고 직진
# 직진후에 다시 이미지 받아서, 파란색 있는지 확인하고(파란색 sum이 어느정도 있으면 앞으로 직진 10cm 정도) 
# 파란색의 sum이 없으면 링안에 들어왔다 판정, 그 내부에 있는점이 빨간색이냐 파란색이냐를 판별해서 회전을 하든 착지를 하든 하기


def moveLarge(drone, BlueSum):
    #이동 11
    print(f"move Large / BlueSum : {BlueSum}")            
    drone.sendControlPosition16(11, 0, 0, 6, 0, 0)
    sleep(4)
        

def moveSoso(drone, BlueSum):
    #이동 8
    print(f"move soso / BlueSum : {BlueSum}")
    drone.sendControlPosition16(8, 0, 0, 5, 0, 0)
    sleep(4)
   
                    
def moveSmall(drone, BlueSum, dist_x, dist_y):
    #이동 6
    print(f"move small / BlueSum : {BlueSum}")
    if (dist_x == 0 and dist_y == 0):
        drone.sendControlPosition16(6, 0, 0, 4, 0, 0)
        sleep(3)
                
    elif (dist_x != 0 and dist_y == 0):
        drone.sendControlPosition16(0, dist_x//abs(dist_x), 0, 1, 0, 0)
        sleep(3)
        drone.sendControlPosition16(6, 0, 0, 4, 0, 0)
        sleep(3)
    
    elif (dist_x == 0 and dist_y != 0):
        drone.sendControlPosition16(0, 0, 2*(dist_y//abs(dist_y)), 2, 0, 0)
        sleep(3)
        drone.sendControlPosition16(6, 0, 0, 4, 0, 0)
        sleep(3)
                    
    elif (dist_x != 0 and dist_y != 0):
        drone.sendControlPosition16(0, dist_x//abs(dist_x), 0, 1, 0, 0)
        sleep(3)
        drone.sendControlPosition16(0, 0, 2*(dist_y//abs(dist_y)), 2, 0, 0)
        sleep(3)
        drone.sendControlPosition16(6, 0, 0, 4, 0, 0)
        sleep(3)


def move2Small(drone, BlueSum, dist_x, dist_y):
    #속도 4
    print(f"move 2 Small / BlueSum : {BlueSum}")
    if (dist_x == 0 and dist_y == 0):
        drone.sendControlPosition16(4, 0, 0, 3, 0, 0)
        sleep(3)
                
    elif (dist_x != 0 and dist_y == 0):
        drone.sendControlPosition16(0, dist_x//abs(dist_x), 0, 1, 0, 0)
        sleep(3)
        drone.sendControlPosition16(4, 0, 0, 3, 0, 0)
        sleep(3)
    
    elif (dist_x == 0 and dist_y != 0):
        drone.sendControlPosition16(0, 0, 2*(dist_y//abs(dist_y)), 2, 0, 0)
        sleep(3)
        drone.sendControlPosition16(4, 0, 0, 3, 0, 0)
        sleep(3)
                    
    elif (dist_x != 0 and dist_y != 0):
        drone.sendControlPosition16(0, dist_x//abs(dist_x), 0, 1, 0, 0)
        sleep(3)
        drone.sendControlPosition16(0, 0, 2*(dist_y//abs(dist_y)), 2, 0, 0)
        sleep(3)
        drone.sendControlPosition16(4, 0, 0, 3, 0, 0)
        sleep(3)

def detectDist(tmpB):
    tmpB_div_1 = tmpB[:240, :320]
    tmpB_div_2 = tmpB[240:, :320]
    tmpB_div_3 = tmpB[:240, 320:]
    tmpB_div_4 = tmpB[240:, 320:]

    tmpB_div_1 = np.sum(tmpB_div_1 == 255, axis = None)
    tmpB_div_2 = np.sum(tmpB_div_2 == 255, axis = None)
    tmpB_div_3 = np.sum(tmpB_div_3 == 255, axis = None)
    tmpB_div_4 = np.sum(tmpB_div_4 == 255, axis = None)
    
    dist_x = (tmpB_div_3 + tmpB_div_4) - (tmpB_div_1 +tmpB_div_2)
    dist_y = (tmpB_div_4 + tmpB_div_2) - (tmpB_div_3 +tmpB_div_1)
    
    return (dist_x, dist_y)


drone = Drone()
drone.open()

try:
    drone.sendTakeOff()
    sleep(5)
    #일단 1단계에서는 많이 이동을 해봅시다
    drone.sendControlPosition16(11,0,0,5,0,0)
    sleep(5) 

    camera = PiCamera() 
    camera.resolution = (640, 480) 
    camera.framerate = 32 
    rawCapture = PiRGBArray(camera, size=(640, 480))
    Dmode = mode[level_cnt] 

    for frame in camera.capture_continuous(rawCapture, format='bgr', use_video_port=True):
        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1) #이렇게 해야 원본이미지 보는 효과~
        imghsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        imgH_B = cv2.inRange(imghsv, lower_blue, upper_blue)

        rawCapture.truncate(0)

        tmpB = cv2.medianBlur(imgH_B, 21) # 파란색 링에 medianBlur 적용한 이미지
        
        BlueSum = np.sum(tmpB == 255, axis = None) # 파란색링의 이미지
        print(f"first BlueSum : {BlueSum}")
        
        if (BlueSum < Dmode[0][0]):
            #링 내부로 들어왔다는 뜻
            print(f"inside ring / BlueSum : {BlueSum}")
            
            imgH_R = cv2.inRange(imghsv, lower_red, upper_red)
            imgH_P = cv2.inRange(imghsv, lower_purple, upper_purple)
            tmpR = cv2.medianBlur(imgH_R, 7) # 좌회전을 판단할 점 요소
            tmpP = cv2.medianBlur(imgH_P, 7)
            RedSum = np.sum(tmpR == 255, axis = None)
            PurpleSum = np.sum(tmpP == 255, axis = None)
        
        
            #if (RedSum > PurpleSum):
            if (RedSum != 0 and level_cnt != 3):
                #일단 노이즈 없이 검출 되는 경우
                if (RedSum < 200):
                    print(f"detect red / BlueSum : {BlueSum}")
                    drone.sendControlPosition16(4, 0, 0, 4, 0, 0)
                    sleep(4)
                    drone.sendControlPosition16(0, 0, 0, 0, 90, 20)
                    sleep(6)
                    level_cnt += 1
                    print("red, rotate complete, now level_cnt:", level_cnt)
                    Dmode = mode[level_cnt]
                    no_trap = True
                    drone.sendControlPosition16(10,0,0,5,0,0)
                    sleep(5)
                    continue

                else:
                    print(f"detect red / BlueSum : {BlueSum}")
                    drone.sendControlPosition16(3, 0, 0, 3, 0, 0)
                    sleep(4)
                    drone.sendControlPosition16(0, 0, 0, 0, 90, 20)
                    sleep(6)
                    level_cnt += 1
                    print("red, rotate complete, now level_cnt:", level_cnt)
                    Dmode = mode[level_cnt]
                    no_trap = True
                    drone.sendControlPosition16(10,0,0,5,0,0)
                    sleep(5)
                    continue

                
            elif (RedSum == 0 and PurpleSum != 0 or level_cnt == 3):
                print("purple")
                drone.sendLanding()
                drone.close()
                break



            else:
                #둘다 노이즈로 판명난 경우엔 다시 검출을 합니다
                continue  

        else:
            # 링 외부에 있다는 뜻
            print(f"out of ring / BlueSum : {BlueSum}")

            (dist_x, dist_y) = detectDist(tmpB)
            
            if (BlueSum in Dmode[0]):               #링 경계   
                # 사진 capture 1와 같을 것이라 판단 (긍까 멀리있을거라 판단) 
                # or 경계에 있을 것이라 판단 (이건 배제)
                
                if (BlueSum - lastBluesum >= 0 and no_trap):
                    #현재 - 과거 픽셀이며, 양수면 매우 멀리있는 경우이므로 moveLarge 모드로 더 다가가야 함
                    moveLarge(drone, BlueSum)

                else:
                    #음수면 링과 매우 근접한 경우이므로, 조금만 움직여야 함.
                    move2Small(drone, BlueSum, dist_x, dist_y)
                lastBluesum = BlueSum
                continue
            
            elif (BlueSum in Dmode[1]):
                # 사진 capture 5보다 멀 것이라 판단

                if (BlueSum - lastBluesum >= 0):
                    moveSoso(drone, BlueSum)
                    no_trap = False
                else:
                    moveSoso(drone, BlueSum)
                    no_trap = False

                lastBluesum = BlueSum
                continue

            
            elif (BlueSum in Dmode[2]):
                #
                if (BlueSum - lastBluesum >= 0):
                    moveSmall(drone, BlueSum, dist_x, dist_y)
                    no_trap = False
                else:
                    move2Small(drone, BlueSum, dist_x, dist_y)
                    no_trap = False
                
                lastBluesum = BlueSum
                continue


            elif (BlueSum >= Dmode[3]):
                #detect color 함수 추가할거임
                #sqr_color = detect_color() 이런식으로
                moveSmall(drone, BlueSum, dist_x, dist_y)
                lastBluesum = BlueSum
                continue

            else:
                continue

except Exception as e:
    print("exception")
    drone.sendLanding()
    drone.close()