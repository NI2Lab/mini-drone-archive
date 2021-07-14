from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
import cv2
import numpy as np
from time import sleep
import math

time = 0

red = 10
blue = 105
purple = 105
icx = 320
icy = 240


leftboundary = 30
rightboundary = 30
leftboundary2 = 100
rightboundary2 = 100
upboundary = 30
downboundary = 30
count = 0

distance_threshold = 10
distance_threshold2 = 10
distance_threshold3 = 10

blue_area_threshold = 10000000
red_purple_area_threshold = 10000000

blueDetect = False
blueDistance = 10000


redDetect = False
redDetect2 = False
redDistance = 10000
redDistance2 = 10000

purpleDetect = False
purpleDistance = 10000

redDetect_end = False
redDetect2_end = False
purpleDetect_end = False
  
camera = PiCamera()
camera.resolution = (640, 480)
camera.framerate = 32
rawCapture = PiRGBArray(camera, size=(640, 480))
#time.sleep(0.1)

drone = Drone()
drone.open()

def blue_distance(max_area):
    blue_dis = blue_area_threshold / max_area
    return blue_dis

def red_distance(max_area):
    red_dis = red_purple_area_threshold / max_area
    return red_dis

def purple_distance(max_area):
    purple_dis = red_purple_area_threshold / max_area
    return purple_dis

def _blue_detect(H):
    _, bi_H = cv2.threshold(H, blue - 6, 255, cv2.THRESH_BINARY)
    _, bi_H_ = cv2.threshold(H, blue + 6, 255, cv2.THRESH_BINARY_INV)
    binary = cv2.bitwise_and(bi_H, bi_H_)
    binary = cv2.medianBlur(binary, 7)
    binary = cv2.bitwise_not(binary)
    binary = cv2.medianBlur(binary, 7)
        
    # get center of ring
    _, contours, _ = cv2.findContours(binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    circle = []
    circularity = 0
    max_circularity = 0
    max_area = 0
    blueDetect = True
    _blue_distance = 0
    print(type(contours))
    if contours is not None:
        for con in contours:
            perimeter = cv2.arcLength(con, True)
            area = cv2.contourArea(con)
            if area > 1000:
                if perimeter == 0:
                    break
                circularity = 4 * math.pi * (area / (perimeter * perimeter))
                if circularity > max_circularity:
                    max_circularity = circularity
                    circle = con
                    max_area = area

            mmt = cv2.moments(circle)
            if mmt['m00'] != 0:
                cxb = int(mmt['m10']/mmt['m00'])
                cyb = int(mmt['m01']/mmt['m00'])
            else:
                cxb, cyb = 0, 0
            # print(2 * math.sqrt(max_area/math.pi))

            _blue_distance = blue_distance(max_area)

    if _blue_distance > 100:
        blueDetect = True
    else:
        blueDetect = False

    return blueDetect, cxb, cyb, _blue_distance

def _red_detect(H):
    _, re_H = cv2.threshold(H, red - 6, 255, cv2.THRESH_BINARY)
    _, re_H_ = cv2.threshold(H, red + 6, 255, cv2.THRESH_BINARY_INV)
    binary2 = cv2.bitwise_and(re_H, re_H_)
    binary2 = cv2.medianBlur(binary2, 7)
    #binary2 = cv2.bitwise_not(binary2)
    binary2 = cv2.medianBlur(binary2, 7)
    _redDetect = True
    red_dis = 10000
    cxr, cyr = 320, 240

    # get center of red mark
    _, contours, _ = cv2.findContours(binary2, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    circle = []
    circularity = 0
    max_circularity = 0
    max_area = 0
    blueDetect = True
    _red_distance = 0
    print(type(contours))
    if contours is not None:
        for con in contours:
            perimeter = cv2.arcLength(con, True)
            area = cv2.contourArea(con)
            if area > 1000:
                if perimeter == 0:
                    break
                circularity = 4 * math.pi * (area / (perimeter * perimeter))
                if circularity > max_circularity:
                    max_circularity = circularity
                    circle = con
                    max_area = area

            mmt = cv2.moments(circle)
            if mmt['m00'] != 0:
                cxr = int(mmt['m10']/mmt['m00'])
                cyr = int(mmt['m01']/mmt['m00'])
            # print(2 * math.sqrt(max_area/math.pi))

            _red_distance = red_distance(max_area)

    if _red_distance > 100:
        redDetect = True
    else:
        redDetect = False

    return redDetect, cxr, cyr, _red_distance

def _purple_detect(H):
    _, re_H = cv2.threshold(H, purple - 6, 255, cv2.THRESH_BINARY)
    _, re_H_ = cv2.threshold(H, purple + 6, 255, cv2.THRESH_BINARY_INV)
    binary2 = cv2.bitwise_and(re_H, re_H_)
    binary2 = cv2.medianBlur(binary2, 7)
    #binary2 = cv2.bitwise_not(binary2)
    binary2 = cv2.medianBlur(binary2, 7)
    _redDetect = True
    red_dis = 10000
    cxp, cyp = 320, 240

    # get center of red mark
    _, contours, _ = cv2.findContours(binary2, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    circle = []
    circularity = 0
    max_circularity = 0
    max_area = 0
    purpleDetect = True
    _purple_distance = 0
    print(type(contours))
    if contours is not None:
        for con in contours:
            perimeter = cv2.arcLength(con, True)
            area = cv2.contourArea(con)
            if area > 1000:
                if perimeter == 0:
                    break
                circularity = 4 * math.pi * (area / (perimeter * perimeter))
                if circularity > max_circularity:
                    max_circularity = circularity
                    circle = con
                    max_area = area

            mmt = cv2.moments(circle)
            if mmt['m00'] != 0:
                cxp = int(mmt['m10']/mmt['m00'])
                cyp = int(mmt['m01']/mmt['m00'])
            # print(2 * math.sqrt(max_area/math.pi))

            _purple_distance = purple_distance(max_area)

    if _purple_distance > 100:
        purpleDetect = True
    else:
        purpleDetect = False

    return purpleDetect, cxp, cyp, _purple_distance

try:

    drone.sendTakeOff()
    sleep(10)

    drone.sendControlPosition16(25, 0, 0, 5, 0, 0)
    sleep(10)

    drone.sendControlPosition16(0, 0, 0, 0, 90, 30)
    sleep(10)

    drone.sendControlPosition16(10, 0, 0, 5, 0, 0)
    sleep(10)

    #get Image from drone
    for frame in camera.capture_continuous(rawCapture, format='bgr', use_video_port=True):

        print("------------------------------------------------------------------------")
        cx, cy = 320, 240
        print("time: ", time)

        
        image = frame.array
        image = cv2.flip(image, 0)
        image = cv2.flip(image, 1)
        print(image.shape)
        
        # Convert image to HSV
        HSV = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        H = HSV[:, :, 0]

        # move drone
        done = 0
        if cx < icx - leftboundary:
            if cx < leftboundary2:
                print("<----")
            else:
                print("<-")
            done += 1
        elif cx > icx + rightboundary:
            if cx > rightboundary2:
                print("---->")
            else:
                print("->")
            done += 1

        if cy < icy - upboundary:
            print("up")
            done += 1

        elif cy > icy + downboundary:
            print("down")
            done += 1
        

        if done > 0:
            count = 0
        else :
            count +=1
            print(count)

        if count > 3:
            print("done")


        # Devide phase
        if blueDetect == False:
            if redDetect == True:
                if redDistance > distance_threshold:
                    print("red Distance > distance Threshold")
                else:
                    print("red Detect 2")
                    redDetect = False
                    redDetect_end = True
            
            elif redDetect2 == True:
                if redDistance2 > distance_threshold2:
                    print("red Distance > distance Threshold")
                else:
                    print("red Detect 2")
                    redDetect2 = False
                    redDetect2_end = True

            elif purpleDetect == True:
                if purpleDistance > distance_threshold3:
                    print("purple distance > Threshold")
                else:
                    purpleDetect = False
                    purpleDetect_end = True
                    print("Landing")



        key = cv2.waitKey(1) & 0xFF
        rawCapture.truncate(0)
        print("------------------------------------------------------------------------")
        time += 0.2

        if key == ord("q"):
            cv2.destroyAllWindows()
            break

except Exception as e:
    print(e)
