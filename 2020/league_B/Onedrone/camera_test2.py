from picamera.array import PiRGBArray
from picamera import PiCamera
import cv2

camera = PiCamera()
camera.resolution = (960, 720)
camera.framerate = 32
rawCapture = PiRGBArray(camera, size=(960,720))

th_c = [61, 5, 102]
idx=0
for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
    img = frame.array
    img = cv2.flip(img, 0)
    img = cv2.flip(img, 1)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    print(th_c)
    H = img[:,:,0]
    _, bi_H = cv2.threshold(H,th_c[idx] - 5, 255, cv2.THRESH_BINARY)
    _, bi_H_ = cv2.threshold(H,th_c[idx] + 4, 255, cv2.THRESH_BINARY_INV)
    bi_H_r = cv2.bitwise_and(bi_H,bi_H_)

    cv2.imshow('bi_H', bi_H_r)
    key= cv2.waitKey(0) & 0xFF

    cv2.destroyAllWindows()
    rawCapture.truncate(0)
    if key == ord("."):
        th_c[idx] += 1
    elif key == ord(","):
        th_c[idx] -= 1
    else:
        idx += 1
        if idx>2:
            print(th_c)
            break