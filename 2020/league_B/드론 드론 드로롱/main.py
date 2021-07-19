from picamera.array import PiRGBArray
from picamera import PiCamera
from e_drone.drone import *
from e_drone.protocol import *
from e_drone.system import *
import time
from time import sleep
import cv2
import numpy as np

#카메라 세팅
def cam_setting(picam):
    #picam 메뉴얼 URL : https://picamera.readthedocs.io/en/release-1.10/api_camera.html
    #받아오는 카메라 해상도 설정
    picam.resolution = (640,480)
    #카메라의 프레임 설정
    picam.framerate = 32

#드론 이륙
def f_takeOff(drone):
    drone.sendTakeOff()
    print("TakeOff")
    sleep(5)

#초록색 hsv로 변환
def green_hsv(image):
    image_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
    H = image_hsv[:,:,0]
    S = image_hsv[:,:,1]
    V = image_hsv[:,:,2]
    _, bi_H = cv2.threshold(H, 60, 255, cv2.THRESH_BINARY)
    _, bi_H_ = cv2.threshold(H, 80, 255, cv2.THRESH_BINARY_INV)
    _, bi_S = cv2.threshold(S, 230, 255, cv2.THRESH_BINARY)
    _, bi_V = cv2.threshold(V, 15, 255, cv2.THRESH_BINARY)

    bi_H_r = cv2.bitwise_and(bi_H, bi_H_)
    bi_H_r = cv2.bitwise_and(bi_H_r, bi_S)
    bi_H_r = cv2.bitwise_and(bi_H_r, bi_V)

    return bi_H_r

def green_hsv_p3(image):
    image_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
    H = image_hsv[:,:,0]
    S = image_hsv[:,:,1]
    V = image_hsv[:,:,2]
    _, bi_H = cv2.threshold(H, 40, 255, cv2.THRESH_BINARY)
    _, bi_H_ = cv2.threshold(H, 120, 255, cv2.THRESH_BINARY_INV)
    _, bi_S = cv2.threshold(S, 230, 255, cv2.THRESH_BINARY)
    _, bi_V = cv2.threshold(V, 15, 255, cv2.THRESH_BINARY)

    bi_H_r = cv2.bitwise_and(bi_H, bi_H_)
    bi_H_r = cv2.bitwise_and(bi_H_r, bi_S)
    bi_H_r = cv2.bitwise_and(bi_H_r, bi_V)

    return bi_H_r

#빨간색 hsv로 변환
def red_hsv(image):
    image_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
    H = image_hsv[:,:,0]
    _, bi_H = cv2.threshold(H, 172, 255, cv2.THRESH_BINARY)
    _, bi_H_ = cv2.threshold(H, 182, 255, cv2.THRESH_BINARY_INV)

    bi_H_r = cv2.bitwise_and(bi_H, bi_H_)
    return bi_H_r

def blue_hsv(image):
    image_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
    H = image_hsv[:,:,0]
    _, bi_H = cv2.threshold(H, 95, 255, cv2.THRESH_BINARY)
    _, bi_H_ = cv2.threshold(H, 105, 255, cv2.THRESH_BINARY_INV)

    bi_H_r = cv2.bitwise_and(bi_H, bi_H_)
    return bi_H_r

if __name__ == "__main__": #이 파일을 직접 실행했을 경우 __name__ = "__main__"이 됨
    #파이캠 설정
    picam = PiCamera()
    cam_setting(picam)
    rawCapture = PiRGBArray(picam, size=(640,480))
    #drone 인스턴스 선언
    drone = Drone()
    #drone 인스턴스 시작
    drone.open()
    #변수 설정
    #---------------------------------
    phase_1 = 1
    step = 0
    #---------------------------------
    phase_2 = 0
    ud_flag = 0
    first_sight = False
    #---------------------------------
    phase_3 = 0
    PHASE3_PIXEL = 20000
    lr_detection = False
    lr_flag = 0
    #이륙
    f_takeOff(drone)

    start_time = time.time()
    while(True):
        try:
            for frame in picam.capture_continuous(rawCapture, format = 'bgr',\
                                                  use_video_port=True):
                #image 변수에 frame의 배열 저장 - Numpy 형식
                image = frame.array
                sleep(0.01)
                #영상 x, y축 반전
                image = cv2.flip(image, 0)
                image = cv2.flip(image, 1)
                #첫번째 링일 때
                if phase_1 == 1:
                    bi_green = green_hsv(image)
                    see_green = False

                    left_length = 0
                    right_length = 0
                    up_length = 0
                    down_length = 0

                    left_pixel = np.count_nonzero(bi_green[:, 0:320] > 127)
                    right_pixel = np.count_nonzero(bi_green[:, 320:640] > 127)
                    up_pixel = np.count_nonzero(bi_green[0:240, :] > 127)
                    down_pixel = np.count_nonzero(bi_green[240:480, :] > 127)

                    whole_pixel =  np.count_nonzero(bi_green[:, :] > 127)
                    #전체적인 링의 중앙 맞춤
                    if step == 0:
                        step0_flag = [0, 0]
                        if left_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                            sleep(1)
                            step0_flag[0] = 0
                            print("ring_right")
                        elif right_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                            sleep(1)
                            step0_flag[0] = 0
                            print("ring_left")
                        else:
                            step0_flag[0] = 1
                            print("left and right correct")

                        if up_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                            sleep(1)
                            step0_flag[1] = 0
                            print("ring_down")
                        elif down_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                            sleep(1)
                            step0_flag[1] = 0
                            print("ring_up")
                        else:
                            step0_flag[1] = 1
                            print("up and down correct")
                        
                        if step0_flag == [1, 1]:
                            print("Next Step!")
                            step0_flag = [0, 0]
                            step += 1
                            drone.sendControlPosition16(13, 0, 0, 5, 0, 0)
                            sleep(3)

                    elif step == 1:

                        if bi_green[240, 320] == 255:
                            see_green = True
                        if see_green == True:
                            drone.sendControlPosition16(-7, 0, 0, 5, 0, 0)
                            sleep(2)
                            drone.sendControlPosition16(0, 0, -2, 2, 0, 0)
                            sleep(2)
                            step -= 1
                            see_green = False
                        else:
                            step += 1

                    elif step == 2:
                        step2_flag = [0, 0]
                        if bi_green[240, 320] == 255:
                            step -= 1

                        else:
                            for i in range(320):
                                if bi_green[240, 320-i] == 255:
                                    left_length = i
                                    break
                                else:
                                    left_length = i
                            for i in range(320):
                                if bi_green[240, 320 + i] == 255:
                                    right_length = i
                                    break
                                else:
                                    right_length = i
                            ring_width = abs(right_length - left_length)

                            for i in range(240):
                                if bi_green[240 - i, 320] == 255:
                                    up_length = i
                                    break
                                else:
                                    up_length = i
                            for i in range(240):
                                if bi_green[240 + i, 320] == 255:
                                    down_length = i
                                    break
                                else:
                                    down_length = i
                            ring_height = abs(down_length - up_length)

                            print(left_length, right_length)
                            print(up_length, down_length)
                            print(ring_width, ring_height)

                            if left_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                                sleep(1)
                                step2_flag[0] = 0
                                print("ring_right")
                            elif right_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                                sleep(1)
                                step2_flag[0] = 0
                                print("ring_left")
                            else:
                                step2_flag[0] = 1
                                print("left and right correct")

                            if up_length < ring_height * 0.45:
                                drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                                sleep(1)
                                step2_flag[1] = 0
                                print("ring_down")
                            elif down_length < ring_height * 0.4:
                                drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                                sleep(1)
                                step2_flag[1] = 0
                                print("ring_up")
                            else:
                                step2_flag[1] = 1
                                print("up and down correct")
                            
                            if step2_flag == [1, 1]:
                                bi_red = red_hsv(image)
                                if np.count_nonzero(bi_red[:, :] > 127) > 1:
                                    print("phase_1 is Done!")
                                    drone.sendControlPosition16(12, 0, 0, 5, 0, 0)
                                    sleep(3)
                                    drone.sendControlPosition16(0, 0, 0, 0, 0, 0)
                                    sleep(2)
                                    drone.sendControlPosition16(0, 0, 0, 0, 90, 45)
                                    sleep(7)
                                    drone.sendControlPosition16(11, 0, 0, 5, 0, 0)
                                    sleep(3)
                                    phase_1 = 0
                                    phase_2 = 1
                                    step2_flag = [0, 0]
                                    step = 0
                
                elif phase_2 == 1:
                    bi_green = green_hsv(image)

                    see_green = False

                    left_length = 0
                    right_length = 0
                    up_length = 0
                    down_length = 0

                    left_pixel = np.count_nonzero(bi_green[:, 0:320] > 127)
                    right_pixel = np.count_nonzero(bi_green[:, 320:640] > 127)
                    up_pixel = np.count_nonzero(bi_green[0:240, :] > 127)
                    down_pixel = np.count_nonzero(bi_green[240:480, :] > 127)

                    whole_pixel =  np.count_nonzero(bi_green[:, :] > 127)
                    #전체적인 링의 중앙 맞춤
                    if step == 0:
                        step0_flag = [0, 0]
                        if left_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                            sleep(1)
                            step0_flag[0] = 0
                            print("ring_right")
                        elif right_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                            sleep(1)
                            step0_flag[0] = 0
                            print("ring_left")
                        else:
                            step0_flag[0] = 1
                            print("left and right correct")

                        if up_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                            sleep(1)
                            step0_flag[1] = 0
                            print("ring_down")
                            if first_sight == False:
                                first_sight = True
                                ud_flag = 0
                                print("mode up")
                        elif down_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                            sleep(1)
                            step0_flag[1] = 0
                            print("ring_up")
                            if first_sight == False:
                                first_sight = True
                                ud_flag = 1
                                print("mode down")
                        else:
                            step0_flag[1] = 1
                            print("up and down correct")
                        
                        if step0_flag == [1, 1]:
                            print("Next Step!")
                            step0_flag = [0, 0]
                            step += 1
                            drone.sendControlPosition16(8, 0, 0, 5, 0, 0)
                            sleep(3)

                    elif step == 1:

                        if bi_green[240, 320] == 255:
                            see_green = True
                        if see_green == True:
                            drone.sendControlPosition16(-7, 0, 0, 5, 0, 0)
                            sleep(5)
                            if ud_flag == 0:
                                drone.sendControlPosition16(0, 0, -2, 2, 0, 0)
                                sleep(2)
                            else:
                                drone.sendControlPosition16(0, 0, 2, 2, 0, 0)
                                sleep(2)
                            step -= 1
                            see_green = False
                        else:
                            step += 1

                    elif step == 2:
                        step2_flag = [0, 0]
                        
                        if bi_green[240, 320] == 255:
                            see_green = True
                            step -= 1

                        else:
                            for i in range(320):
                                if bi_green[240, 320-i] == 255:
                                    left_length = i
                                    break
                                else:
                                    left_length = i
                            for i in range(320):
                                if bi_green[240, 320 + i] == 255:
                                    right_length = i
                                    break
                                else:
                                    right_length = i

                            ring_width = abs(right_length - left_length)

                            for i in range(240):
                                if bi_green[240 - i, 320] == 255:
                                    up_length = i
                                    break
                                else:
                                    up_length = i
                            for i in range(240):
                                if bi_green[240 + i, 320] == 255:
                                    down_length = i
                                    break
                                else:
                                    down_length = i

                            ring_height = abs(down_length - up_length)

                            print(left_length, right_length)
                            print(up_length, down_length)
                            print(ring_width, ring_height)

                            if left_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                                sleep(2)
                                step2_flag[0] = 0
                                print("square_right")
                            elif right_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                                sleep(2)
                                step2_flag[0] = 0
                                print("square_left")
                            else:
                                step2_flag[0] = 1
                                print("left and right correct")

                            if up_length < ring_height * 0.45:
                                drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                                sleep(2)
                                step2_flag[1] = 0
                                print("square_down")
                            elif down_length < ring_height * 0.4:
                                drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                                sleep(2)
                                step2_flag[1] = 0
                                print("square_up")
                            else:
                                step2_flag[1] = 1
                                print("up and down correct")
                            
                            if step2_flag == [1, 1]:
                                bi_red = red_hsv(image)
                                if np.count_nonzero(bi_red[:, :] > 127) > 1:
                                    print("phase_2 is Done!")
                                    drone.sendControlPosition16(12, 0, 0, 5, 0, 0)
                                    sleep(3)
                                    drone.sendControlPosition16(0, 0, 0, 0, 0, 0)
                                    sleep(2)
                                    drone.sendControlPosition16(0, 0, 0, 0, 90, 45)
                                    sleep(7)
                                    drone.sendControlPosition16(0, -2, 0, 2, 0, 0)
                                    sleep(2)
                                    drone.sendControlPosition16(11, 0, 0, 5, 0, 0)
                                    sleep(3)
                                    phase_2 = 0
                                    phase_3 = 1
                                    step2_flag = [0, 0]
                                    step = 0

                elif phase_3 == 1:

                    bi_green = green_hsv(image)

                    see_green = False

                    left_length = 0
                    right_length = 0
                    up_length = 0
                    down_length = 0

                    left_pixel = np.count_nonzero(bi_green[:, 0:320] > 127)
                    right_pixel = np.count_nonzero(bi_green[:, 320:640] > 127)
                    up_pixel = np.count_nonzero(bi_green[0:240, :] > 127)
                    down_pixel = np.count_nonzero(bi_green[240:480, :] > 127)

                    whole_pixel =  np.count_nonzero(bi_green[:, :] > 127)

                    print(left_pixel, right_pixel)
                    #전체적인 링의 중앙 맞춤
                    if step == 0:
                        #phase_2의 반대 방향으로 위 아래 조절
                        if first_sight == True:
                            if ud_flag == 0:
                                drone.sendControlPosition16(0, 0, 5, 5, 0, 0)
                                sleep(3)
                            else:
                                drone.sendControlPosition16(0, 0, -5, 5, 0, 0)
                                sleep(3)
                            first_sight = False
                        
                        if lr_detection == False:
                            if np.count_nonzero(bi_green[:, :] > 127) > PHASE3_PIXEL:
                                step += 1
                                lr_detection = True
                            else:
                                if lr_flag == 0:
                                    drone.sendControlPosition16(0, -12, 0, 5, 0, 0)
                                    sleep(3)
                                    lr_flag += 1
                                else:
                                    drone.sendControlPosition16(0, 12, 0, 5, 0, 0)
                                    sleep(2)
                                    drone.sendControlPosition16(0, 0, 0, 0, 0, 0,)
                                    sleep(3)
                                    drone.sendControlPosition16(0, 12, 0, 5, 0, 0)
                                    sleep(3)
                                    lr_flag = 0
                                    step += 1
                                    lr_detection = True

                    elif step == 1:
                        step1_flag = [0, 0]
                        if left_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                            sleep(1)
                            step1_flag[0] = 0
                            print("ring_right")
                        elif right_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                            sleep(1)
                            step1_flag[0] = 0
                            print("ring_left")
                        else:
                            step1_flag[0] = 1
                            print("left and right correct")

                        if up_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                            sleep(1)
                            step1_flag[1] = 0
                            print("ring_down")
                        elif down_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                            sleep(1)
                            step1_flag[1] = 0
                            print("ring_up")
                        else:
                            step1_flag[1] = 1
                            print("up and down correct")
                        
                        if step1_flag == [1, 1]:
                            print("Next Step!")
                            step1_flag = [0, 0]
                            step += 1
                            drone.sendControlPosition16(8, 0, 0, 5, 0, 0)
                            sleep(3)

                    elif step == 2:

                        if bi_green[240, 320] == 255:
                            see_green = True

                        if see_green == True:
                            drone.sendControlPosition16(-7, 0, 0, 5, 0, 0)
                            sleep(5)
                            if ud_flag == 1:
                                drone.sendControlPosition16(0, 0, -2, 2, 0, 0)
                                sleep(2)
                            else:
                                drone.sendControlPosition16(0, 0, 2, 2, 0, 0)
                                sleep(2)
                            step -= 1
                            see_green = False
                        else:
                            step += 1

                    elif step == 3:
                        step3_flag = [0, 0]
                        
                        if bi_green[240, 320] == 255:
                            see_green = True
                            step -= 1

                        else:
                            for i in range(320):
                                if bi_green[240, 320-i] == 255:
                                    left_length = i
                                    break
                                else:
                                    left_length = i
                            for i in range(320):
                                if bi_green[240, 320 + i] == 255:
                                    right_length = i
                                    break
                                else:
                                    right_length = i
                            ring_width = abs(right_length - left_length)

                            for i in range(240):
                                if bi_green[240 - i, 320] == 255:
                                    up_length = i
                                    break
                                else:
                                    up_length = i
                            for i in range(240):
                                if bi_green[240 + i, 320] == 255:
                                    down_length = i
                                    break
                                else:
                                    down_length = i
                                    
                            ring_height = abs(down_length - up_length)

                            print(left_length, right_length)
                            print(up_length, down_length)
                            print(ring_width, ring_height)

                            if left_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                                sleep(1)
                                step3_flag[0] = 0
                                print("ring_right")
                            elif right_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                                sleep(1)
                                step3_flag[0] = 0
                                print("ring_left")
                            else:
                                step3_flag[0] = 1
                                print("left and right correct")

                            if up_length < ring_height * 0.45:
                                drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                                sleep(1)
                                step3_flag[1] = 0
                                print("ring_down")
                            elif down_length < ring_height * 0.4:
                                drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                                sleep(1)
                                step3_flag[1] = 0
                                print("ring_up")
                            else:
                                step3_flag[1] = 1
                                print("up and down correct")
                            
                            if step3_flag == [1, 1]:
                                bi_blue = blue_hsv(image)
                                if np.count_nonzero(bi_blue[:, :] > 127) > 1:
                                    print("phase_3 is Done!")
                                    drone.sendControlPosition16(0, 0, 0, 0, 0, 0)
                                    sleep(3)
                                    drone.sendControlPosition16(11, 0, 0, 5, 0, 0)
                                    sleep(3)
                                    phase_3 = 0
                                    step3_flag = [0, 0]
                                    step = 0
                                    drone.sendLanding()
                                    sleep(3)
                                    break
                            

                if time.time() - start_time > 180:
                    drone.close()
                    print("Time Over")
                    break

                rawCapture.truncate(0)
            
            cv2.destroyAllWindows()
            print("landing")
            drone.sendLanding()
            sleep(3)
            drone.close()
            break
            
        except Exception as e:
            print(e)
            #drone.sendLanding()
            drone.close()