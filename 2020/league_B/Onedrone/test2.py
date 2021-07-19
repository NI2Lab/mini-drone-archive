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
    camera.resolution = (960, 720)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(960, 720))
    th_c = [5, 61, 102]
    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        print("start")
        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        H = img[:, :, 0]

        _, bi_H = cv2.threshold(H, th_c[0] - 5, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[0] + 4, 255, cv2.THRESH_BINARY_INV)
        R = cv2.bitwise_and(bi_H, bi_H_)

        _, bi_H = cv2.threshold(H, th_c[1] - 5, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[1] + 4, 255, cv2.THRESH_BINARY_INV)
        G = cv2.bitwise_and(bi_H, bi_H_)

        _, bi_H = cv2.threshold(H, th_c[2] - 5, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[2] + 4, 255, cv2.THRESH_BINARY_INV)
        B = cv2.bitwise_and(bi_H, bi_H_)
        print("mid")
        rawCapture.truncate(0)

        G = np.array(G)
        print("1")

        index = np.where(G == 255)
        print("2")
        new_A = np.array([])
        real_A = np.array([])
        new_B = np.array([])
        real_B = np.array([])
        print("3")
        place_x = 0
        place_y = 0
        F_x = 0
        F_y = 0
        direction = 0
        print("ok 1")
        print("rest")
        drone.sendControlWhile(0, 0, 0, 0, 2000)
        for i in range(np.min(index[0]), np.max(index[0])):
            if np.count_nonzero(index[0] == i) > 530:
                new_A = np.append(new_A, i)
        for i in range(1, np.size(new_A) - 1):
            if (new_A[i] - new_A[i - 1]) > 120:
                real_A = np.append(real_A, [new_A[i - 1], new_A[i]])
        print("rest")
        drone.sendControlWhile(0, 0, 0, 0, 2000)
        for i in range(np.min(index[1]), np.max(index[1])):
            if np.count_nonzero(index[1] == i) > 400:
                new_B = np.append(new_B, i)
        for i in range(1, np.size(new_B) - 1):
            if (new_B[i] - new_B[i - 1]) > 180:
                real_B = np.append(real_B, [new_B[i - 1], new_B[i]])
        F_x = int((np.sum(real_B) // 2))
        F_y = int((np.sum(real_A) // 2))
        print(F_x, end=" ")
        print(F_y)
        print("ok 2")

        R_s = np.sum(R == 255, axis=None)
        print(R_s)
        if F_x == 0 and F_y == 0:
            direction = -1

        if F_x < 450 and direction == -1:
            place_x = -1
        elif F_x > 510 and direction == -1:
            place_x = 1

        if F_y < 340 and direction == -1:
            place_y = -1
        elif F_y > 390 and direction == -1:
            place_y = 1

        if 450 <= F_x <= 510:
            place_x = 0
        if 330 <= F_y <= 390:
            place_y = 0
        if place_x == 0 and place_y == 0:
            direction = 2


        if direction == 0:
            print("Go front")
            drone.sendControlPosition16(5, 0, 0, 5, 0, 0)
        elif direction == -1:
            print("Stop")
            drone.sendControlWhile(0, 0, 0, 0, 5000)
        elif direction == 1:
            sleep(1)
            drone.sendControlPosition16(0, 0, 0, 0, 90, 30)
        elif direction == 2:
            print("landing")
            drone.sendLanding()
            drone.close()
            break

        if place_x == -1:
            print("Go right")
            drone.sendControlPosition16(0, -2, 0, 5, 0, 0)
        elif place_x == 1:
            print("Go left")
            drone.sendControlPosition16(0, 2, 0, 5, 0, 0)
        if place_y == -1:
            print("Go up")
            drone.sendControlPosition16(0, 0, -2, 5, 0, 0)
        elif place_y == 1:
            print("Go down")
            drone.sendControlPosition16(0, 0, 2, 5, 0, 0)

        if 460 <= F_x <= 495:
            place_x = 0
        if 340 <= F_y <= 375:
            place_y = 0
        print("ok 3")
        sleep(2)



except Exception as e:
    print(e)
    drone.sendLanding()
    drone.close()