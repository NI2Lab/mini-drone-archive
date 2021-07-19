from e_drone.drone import *
from e_drone.protocol import *
from picamera.array import PiRGBArray
from picamera import PiCamera
import cv2
import numpy as np
from time import sleep

lower_green = (60, 150, 55)
upper_green = (80, 255, 255)

lower_red1 = (150, 30, 30)
upper_red1 = (190, 255, 255)
lower_red2 = (-10, 100, 55)
upper_red2 = (10, 255, 255)

lower_blue = (90, 190, 75)
upper_blue = (110, 255, 255)

drone = Drone()
drone.open()


def detect_color(img_hsv):
    img_mask_red1 = cv2.inRange(img_hsv, lower_red1, upper_red1)
    img_mask_red2 = cv2.inRange(img_hsv, lower_red2, upper_red2)
    img_mask_red = cv2.add(img_mask_red1, img_mask_red2)
    img_mask_blue = cv2.inRange(img_hsv, lower_blue, upper_blue)

    R = np.sum(img_mask_red == 255, axis=None)
    B = np.sum(img_mask_blue == 255, axis=None)

    if R > B:
        circle_color = 'red'
    else:
        circle_color = 'blue'
    return circle_color


def detect_circle(img_hsv, circle_color):
    if circle_color == 'red':
        img_mask_red1 = cv2.inRange(img_hsv, lower_red1, upper_red1)
        img_mask_red2 = cv2.inRange(img_hsv, lower_red2, upper_red2)
        img_mask_red = cv2.add(img_mask_red1, img_mask_red2)
        dilation_red = cv2.morphologyEx(img_mask_red, cv2.MORPH_CLOSE, np.ones((15, 15), np.uint8))
        dilation_red = cv2.dilate(dilation_red, np.ones((7, 7), np.uint8), iterations=1)
        dst_red = cv2.medianBlur(dilation_red, 7)
        circles = cv2.HoughCircles(dst_red, cv2.HOUGH_GRADIENT, 1, 50, param1=50, param2=10, minRadius=3, maxRadius=70)
    elif circle_color == 'blue':
        img_mask_blue = cv2.inRange(img_hsv, lower_blue, upper_blue)
        dilation_blue = cv2.morphologyEx(img_mask_blue, cv2.MORPH_CLOSE, np.ones((15, 15), np.uint8))
        dilation_blue = cv2.dilate(dilation_blue, np.ones((7, 7), np.uint8), iterations=1)
        dst_blue = cv2.medianBlur(dilation_blue, 7)
        circles = cv2.HoughCircles(dst_blue, cv2.HOUGH_GRADIENT, 1, 50, param1=50, param2=10, minRadius=3, maxRadius=70)

    if circles is not None:
        max_circle = max(circles[0, :, 2])
        for j in circles[0]:
            if int(max_circle) == int(j[2]):
                return j[0], j[1]
    else:
        return 0, 0


def detect_rect(img_hsv):
    try:
        img_mask_green = cv2.inRange(img_hsv, lower_green, upper_green)
        dst3 = cv2.medianBlur(img_mask_green, 15)

        _, contours, hierarchy = cv2.findContours(dst3, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

        area_temp = 640 * 480
        area_temp2 = 0

        for cnt in contours:
            epsilon = 0.01 * cv2.arcLength(cnt, True)
            approx = cv2.approxPolyDP(cnt, epsilon, True)
            area = cv2.contourArea(approx)
            mmt = cv2.moments(approx)
            cx = int(mmt['m10'] / mmt['m00'])
            cy = int(mmt['m01'] / mmt['m00'])

            if (8000 < area) and (area < area_temp):
                area_temp = area
                pt_temp = (cx, cy)

            if (8000 < area) and (area > area_temp2):
                area_temp2 = area
                approx_temp = approx

        if len(approx_temp) == 4:
            approx_list = [tuple(approx_temp[0, 0]), tuple(approx_temp[1, 0]), tuple(approx_temp[2, 0]),
                           tuple(approx_temp[3, 0])]
            approx_list.sort()
            left_length = abs(approx_list[0][1] - approx_list[1][1])
            right_length = abs(approx_list[2][1] - approx_list[3][1])
        else:
            left_length = 0
            right_length = 0

        return pt_temp, left_length, right_length

    except Exception as e:
        return 'fail'


try:
    drone.sendTakeOff()
    sleep(5)
    camera = PiCamera()
    camera.resolution = (640, 480)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(640, 480))

    circle_color = 'red'
    mode1 = False
    mode2 = True
    mode3 = False

    ring_range = 40

    i = 0
    no_ring_cnt = 0
    drone.sendControlPosition16(7, 0, 0, 5, 0, 0)
    sleep(3)

    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        i = i + 1

        rawCapture.truncate(0)

        if mode1:
            drone.sendControlPosition16(13, 0, 0, 5, 0, 0)
            sleep(5)
            mode1 = False
            mode2 = True
        elif mode2:
            if 'fail' == detect_rect(img_hsv):
                continue
            else:
                pt_temp, left_length, right_length = detect_rect(img_hsv)
                if pt_temp[1] > 480 - 90+20:
                    drone.sendControlPosition16(0, 0, -7, 5, 0, 0)
                    sleep(3)
                elif pt_temp[1] < 90+20:
                    drone.sendControlPosition16(0, 0, 7, 5, 0, 0)
                    sleep(3)
                else:
                    if pt_temp[1] > 480 - 130+20:
                        drone.sendControlPosition16(0, 0, -3, 5, 0, 0)
                        sleep(1)
                    elif pt_temp[1] < 130+20:
                        drone.sendControlPosition16(0, 0, 3, 5, 0, 0)
                        sleep(1)
                    elif pt_temp[0] < 100:
                        drone.sendControlPosition16(0, 11, 0, 5, 0, 0)
                        sleep(5)
                    elif pt_temp[0] > 640 - 100:
                        drone.sendControlPosition16(0, -11, 0, 5, 0, 0)
                        sleep(5)
                    else:
                        if pt_temp[1] > 240 + ring_range + 30:
                            drone.sendControlPosition16(0, 0, -1, 5, 0, 0)
                            sleep(0.5)
                        elif pt_temp[1] < 240 - ring_range + 30:
                            drone.sendControlPosition16(0, 0, 1, 5, 0, 0)
                            sleep(0.5)
                        elif pt_temp[0] > 320 + ring_range:
                            drone.sendControlPosition16(0, -1, 0, 5, 0, 0)
                            sleep(0.5)
                        elif pt_temp[0] < 320 - ring_range:
                            drone.sendControlPosition16(0, 1, 0, 5, 0, 0)
                            sleep(0.5)
                        else:
                            if left_length - right_length > 21:
                                drone.sendControlPosition16(0, 0, 0, 0, 8, 20)
                                sleep(3)
                            elif right_length - left_length > 21:
                                drone.sendControlPosition16(0, 0, 0, 0, -8, 20)
                                sleep(3)
                            else:
                                drone.sendControlPosition16(8, 0, 0, 5, 0, 0)
                                sleep(3)
                                mode2 = False
                                mode3 = True

        elif mode3:
            circle_color = detect_color(img_hsv)
            circle_x, circle_y = detect_circle(img_hsv, circle_color)
            if circle_x == 0:
                continue
            else:
                if circle_x > 320 + 40:
                    drone.sendControlPosition16(0, -1, 0, 5, 0, 0)
                    sleep(0.5)
                elif circle_x < 320 - 40:
                    drone.sendControlPosition16(0, 1, 0, 5, 0, 0)
                    sleep(0.5)
                else:
                    sleep(1)
                    drone.sendControlPosition16(10, 0, 0, 5, 0, 0)
                    sleep(6)
                    if circle_color == 'blue':
                        sleep(1)
                        drone.sendLanding()
                        drone.close()
                        break
                    elif circle_color == 'red':
                        drone.sendControlPosition16(0, 0, 0, 0, 90, 20)
                        sleep(6)
                        mode3 = False
                        mode1 = True

except Exception as e:
    drone.sendLanding()
    drone.close()
