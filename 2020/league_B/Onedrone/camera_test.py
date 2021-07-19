from picamera.array import PiRGBArray
from picamera import PiCamera
import time
from cv2 import imshow, imwrite, waitKey, destroyAllWindows

camera = PiCamera()
camera.resolution = (640,480)
camera.framerate = 32
rawCapture = PiRGBArray(camera, size=(640,480))
i = 1
time.sleep(0.1)

for frame in camera.capture_continuous(rawCapture, format='bgr', use_video_port=True):
    image = frame.array

    imshow("Frame", image)
    key = waitKey(0) & 0xFF

    rawCapture.truncate(0)

    if key == ord("c"):
        continue

    elif key == ord("e"):
        imwrite("capture_{}.jpg".format(i), image)
        i += 1

    elif key == ord("q"):
        destroyAllWindows()
        break

