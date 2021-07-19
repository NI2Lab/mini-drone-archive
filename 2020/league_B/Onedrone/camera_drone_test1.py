from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
from time import sleep
import numpy as np
import cv2

drone = Drone()
drone.open()
try:
    drone.sendTakeOff()
    sleep(5)
    camera = PiCamera()
    camera.resolution = (640, 480)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(640, 480))
    th_c = [4, 52, 112]
    direction = 0

    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        H = img[:, :, 0]

        _, bi_H = cv2.threshold(H, th_c[0] - 12, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[0] + 12, 255, cv2.THRESH_BINARY_INV)
        R = cv2.bitwise_and(bi_H, bi_H_)

        _, bi_H = cv2.threshold(H, th_c[1] - 12, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[1] + 12, 255, cv2.THRESH_BINARY_INV)
        G = cv2.bitwise_and(bi_H, bi_H_)

        _, bi_H = cv2.threshold(H, th_c[2] - 12, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[2] + 12, 255, cv2.THRESH_BINARY_INV)
        B = cv2.bitwise_and(bi_H, bi_H_)

        rawCapture.truncate(0)

        R = np.sum(R == 255, axis=None)
        G = np.sum(G == 255, axis=None)
        B = np.sum(B == 255, axis=None)

        if sum([R,G,B]) < 100000:
            print('R: {}, G: {}, B: {}'.format(R,G,B))
            if R > 10000 and direction == 0:
                direction += 1
                print('direction: ', direction)

            elif G > 14000 and direction == 1:
                direction -= 1
                print('direction: ', direction)

            elif B > 10000 and direction == 0:
                print('Landing')
                drone.sendLanding()
                drone.close()
                break

            if direction == 0:
                drone.sendControlPosition16(0, -2, 0, 5, 0, 0)
                print('->')

            elif direction == 1:
                drone.sendControlPosition16(0, 0, 2, 5, 0, 0)
                print('^')
         sleep(3)

except Exception as e:
    print(e)
    drone.sendLanding()
    drone.close()