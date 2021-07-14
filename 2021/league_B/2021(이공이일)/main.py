import cv2
import numpy as np
from e_drone.drone import *
from e_drone.protocol import *
from picamera.array import PiRGBArray
from picamera import PiCamera
import time

def initialize():
    drone = Drone()
    drone.open()
    return drone


def capture_img():
    camera = PiCamera()
    img = 'img.jpg'
    camera.resolution = (240, 240)
    camera.framerate = 32
    camera.rotation = 180
    camera.capture(img)
    camera.close()
    return img

def move_to_center(drone):
    h = -1
    lower_blue = np.array([100, 30, 30])
    upper_blue = np.array([110, 255, 255])
    while h < 2:
        try:
            img = cv2.imread(capture_img())
            img = cv2.GaussianBlur(img, (9, 9), 3)

            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
            mask = cv2.inRange(hsv, lower_blue, upper_blue)

            _, contours, hierarchy = cv2.findContours(mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
            cnt = contours[0]
            M = cv2.moments(cnt)

            cx = int(M['m10'] / (M['m00'] + 0.000000000000001))
            cy = int(M['m01'] / (M['m00'] + 0.000000000000001))
            h = len(hierarchy[0])

            if h >= 2:
                break

            while not check_y(drone):
                if cy < 140:
                    drone.sendControlPosition(0, 0, 0.1, 0.5, 0, 0)
                elif cy > 160:
                    drone.sendControlPosition(0, 0, -0.1, 0.5, 0, 0)
                else:
                    print('y ok y : ', cy)
                time.sleep(1)

            drone.sendControlWhile(0, 0, 0, 0, 1000)

            while not check_x(drone):
                if cx < 110:
                    drone.sendControlPosition(0, 0.1, 0, 0.5, 0, 0)
                elif cx > 130:
                    drone.sendControlPosition(0, -0.1, 0, 0.5, 0, 0)
                else:
                    print('x ok x : ', cx)
                time.sleep(1)
            drone.sendControlPosition(-0.3, 0, 0, 0.5, 0, 0)
            time.sleep(1)
        except Exception as e:
            drone.sendControlPosition(-0.3, 0, 0, 0.5, 0, 0)
            time.sleep(1)

def find_centroid(drone, flag):
    lower_blue = np.array([100, 30, 30])
    upper_blue = np.array([110, 255, 255])
    while True:
        try:
            img = cv2.imread(capture_img())
            img = cv2.GaussianBlur(img, (9, 9), 3)

            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
            mask = cv2.inRange(hsv, lower_blue, upper_blue)

            _, contours, hierarchy = cv2.findContours(mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

            if len(hierarchy[0]) <= 1 and flag == 1:
                print("go back")
                drone.sendControlPosition(-0.3, 0, 0, 0.5, 0, 0)
                time.sleep(1)

            elif len(hierarchy[0]) <= 1 and flag != 1:
                drone.sendControlPosition(-0.3, 0, 0, 0.5, 0, 0)
                move_to_center(drone)

            else:
                cnt = contours[0]
                M = cv2.moments(cnt)
                cx = int(M['m10'] / (M['m00'] + 0.000000000000001))
                cy = int(M['m01'] / (M['m00'] + 0.000000000000001))
                print(cx, cy)
                return cx, cy
        except Exception as e :
            drone.sendControlPosition(-0.3, 0, 0, 0.5, 0, 0)
            time.sleep(3)

def match_center(drone, flag):
    while not check_y(drone):
        cy = find_centroid(drone, flag)[1]
        if cy < 140:
            drone.sendControlPosition(0, 0, 0.1, 0.5, 0, 0)
        elif cy > 160:
            drone.sendControlPosition(0, 0, -0.1, 0.5, 0, 0)
        else:
            print('y ok y : ', cy)
        time.sleep(1)

    time.sleep(1)

    while not check_x(drone):
        cx = find_centroid(drone, flag)[0]
        if cx < 110:
            drone.sendControlPosition(0, 0.1, 0, 0.5, 0, 0)
        elif cx > 130:
            drone.sendControlPosition(0, -0.1, 0, 0.5, 0, 0)
        else:
            print('x ok x : ',cx)
        time.sleep(1)

    time.sleep(1)
    pass_obstacle(drone)

def check_x(drone):
    try:
        lower_blue = np.array([100, 30, 30])
        upper_blue = np.array([110, 255, 255])

        img = cv2.imread(capture_img())
        img = cv2.GaussianBlur(img, (9, 9), 3)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, lower_blue, upper_blue)
        _, contours, hierarchy = cv2.findContours(mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

        cnt = contours[0]
        M = cv2.moments(cnt)
        cx = int(M['m10'] / (M['m00'] + 0.000000000000001))
        cy = int(M['m01'] / (M['m00'] + 0.000000000000001))
        print('check_x : ', cx)

        if abs(cx - 120) <= 10:
            print('x true')
            return True
        else:
            return False
    except Exception as e:
        return False

def check_y(drone):
    try:
        lower_blue = np.array([100, 30, 30])
        upper_blue = np.array([110, 255, 255])

        img = cv2.imread(capture_img())
        img = cv2.GaussianBlur(img, (9, 9), 3)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, lower_blue, upper_blue)
        _, contours, hierarchy = cv2.findContours(mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

        cnt = contours[0]
        M = cv2.moments(cnt)
        cx = int(M['m10'] / (M['m00'] + 0.000000000000001))
        cy = int(M['m01'] / (M['m00'] + 0.000000000000001))
        print('check_y : ', cy)
        if abs(cy - 150) <= 10:
            print('y true')
            return True
        else:
            return False
    except Exception as e:
        return False

def find_redpoint():
    img = cv2.imread('img.jpg')
    upper_red = np.array([20, 255, 255])
    lower_red = np.array([0, 30, 0])
    img = cv2.GaussianBlur(img, (9, 9), 2.5)

    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, lower_red, upper_red)

    point_red = np.nonzero(mask)
    num_point_red = np.size(point_red)
    print('red : ', num_point_red)
    return num_point_red

def find_purplepoint():
    img = cv2.imread(capture_img())
    upper_purple = np.array([125, 255, 255])
    lower_purple = np.array([110, 0, 0])
    img = cv2.GaussianBlur(img, (9, 9), 2.5)

    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, lower_purple, upper_purple)
    point_purple = np.nonzero(mask)
    num_point_purple = np.size(point_purple)
    print('purple : ', num_point_purple)
    return num_point_purple

def pass_obstacle(drone):
    while True:
        if find_purplepoint() > 1000:
            print('detect purple point')
            drone.sendLanding()
            drone.close()
            return 0

        if find_redpoint() < 1000:
            drone.sendControlPosition(0.4, 0, 0, 0.5, 0, 0)
            time.sleep(1)
            print('not find red(purple) point')

        else:
            drone.sendControlPosition(0, 0, 0, 0, 90, 45)
            print('find red point')
            time.sleep(3)
            drone.sendControlWhile(0, 0, 0, 0, 1000)
            time.sleep(1)
            drone.sendControlPosition16(10, 0, 0, 5, 0, 0)
            time.sleep(2)
            return 0

drone = initialize()
drone.sendTakeOff()
time.sleep(2)

drone.sendControlWhile(0, 0, 0, 0, 1000)
time.sleep(1)
print('start')

flag = 1
match_center(drone, flag)
print('finish1')
time.sleep(3)

flag = 2
match_center(drone, flag)
print('finish2')
time.sleep(3)

flag = 3
match_center(drone, flag)
print('finish3')
drone.close()


