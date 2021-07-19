from picamera.array import PiRGBArray
from picamera import PiCamera
import cv2
import numpy as np

camera = PiCamera()
camera.resolution = (960, 720)
camera.framerate = 32
rawCapture = PiRGBArray(camera, size=(960, 720))
th_c = [5, 61, 102]

for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
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
    G = np.array(G)
    rawCapture.truncate(0)
    index = np.where(G == 255)
    new_A = np.array([])
    real_A = np.array([])
    new_B = np.array([])
    real_B = np.array([])
    print(" ok 1 ")
    for i in range(np.min(index[0]), np.max(index[0])):
        if np.count_nonzero(index[0] == i) > 530:
            new_A = np.append(new_A, i)
    for i in range(1, np.size(new_A) - 1):
        if (new_A[i] - new_A[i - 1]) > 120:
            real_A = np.append(real_A, [new_A[i - 1], new_A[i]])
    for i in range(np.min(index[1]), np.max(index[1])):
        if np.count_nonzero(index[1] == i) > 400:
            new_B = np.append(new_B, i)
    for i in range(1, np.size(new_B) - 1):
        if (new_B[i] - new_B[i - 1]) > 180:
            real_B = np.append(real_B, [new_B[i - 1], new_B[i]])
    print("ok 2")
    print(int((np.sum(real_B) // 2)), end=" ")
    print(int(np.sum(real_A) // 2))
    R_s = np.sum(R == 255, axis=None)
    G_s = np.sum(G == 255, axis=None)
    B_s = np.sum(B == 255, axis=None)

    print(R_s)
    print(G_s)
    print(B_s)
