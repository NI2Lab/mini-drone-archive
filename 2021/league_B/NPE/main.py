from picamera.array import PiRGBArray
from picamera import PiCamera
from e_drone.drone import *
from e_drone.protocol import *
from e_drone.system import *
from time import sleep
from cv2 import cvtColor, COLOR_BGR2HSV, threshold, THRESH_BINARY, THRESH_BINARY_INV, bitwise_and, flip, waitKey, \
    imshow, destroyAllWindows, imread, inRange, imwrite
import numpy as np


# 카메라 세팅
def cam_setting(picam):
    # picam 메뉴얼 URL : https://picamera.readthedocs.io/en/release-1.10/api_camera.html
    # 받아오는 카메라 해상도 설정
    picam.resolution = (640, 480)
    # 카메라의 프레임 설정
    picam.framerate = 32


# 드론 이륙
def f_takeOff(drone):
    drone.sendTakeOff()
    print("TakeOff")
    sleep(5)


# 빨간색 hsv로 변환
def red_hsv(image):
    image_hsv = cvtColor(image, COLOR_BGR2HSV)
    H = image_hsv[:, :, 0]
    _, bi_H = threshold(H, 172, 255, THRESH_BINARY)
    _, bi_H_ = threshold(H, 182, 255, THRESH_BINARY_INV)

    img_th = bitwise_and(bi_H, bi_H_)
    return img_th

def blue_hsv(image):
    image_hsv = cvtColor(image, COLOR_BGR2HSV)
    th_low = (90, 80, 70)
    th_high = (120, 255, 255)
    img_th = inRange(image_hsv, th_low, th_high)
    return img_th


def puple_hsv(image):
    image_hsv = cvtColor(image, COLOR_BGR2HSV)
    th_low = (50, 10, 50)
    th_high = (200, 200, 255)

    img_th = inRange(image_hsv, th_low, th_high)
    return img_th


if __name__ == "__main__":  # 이 파일을 직접 실행했을 경우 __name__ = "__main__"이 됨
    # 파이캠 설정
    picam = PiCamera()
    cam_setting(picam)
    rawCapture = PiRGBArray(picam, size=(640, 480))
    # drone 인스턴스 선언
    drone = Drone()
    # drone 인스턴스 시작
    drone.open()
    # 변수 설정
    # ---------------------------------
    phase_1_1 = 1
    phase_1_2 = 0
    step = 0
    check = [0, 0]
    back = 0
    wc = True
    cnt = 0
    find_num = 0
    already = 0
    red_find = 0
    find_ring = 0

    # 이륙
    f_takeOff(drone)

    try:
        while (wc):

            for frame in picam.capture_continuous(rawCapture, format='bgr', \
                                                  use_video_port=True):

                # image 변수에 frame의 배열 저장 - Numpy 형식
                image = frame.array
                sleep(0.01)

                # 영상 x, y축 반전
                image = flip(image, 0)
                image = flip(image, 1)

                rawCapture.truncate(0)

                bi_red = red_hsv(image)
                bi_pup = puple_hsv(image)

                # 첫번째 링일 때
                if phase_1_1 == 1:
                    bi_blue = blue_hsv(image)
                    value_th = np.where(bi_blue[:, :] == 255)
                    #파란색 링을 찾는데 링이 일정이상 안보이면 상하좌우로 움직이면서 링을 찾는거지
                    if np.sum(bi_blue) / 255 < 30000:
                        if find_ring == 0:
                            drone.sendControlPosition16(0, 0,-3, 5, 0, 0)
                            print("find ring , go to down")
                            find_ring = 1
                            sleep(2)
                        elif find_ring == 1 :
                            drone.sendControlPosition16(0, 3, 0, 5, 0, 0)
                            print("find ring , go to left")
                            find_ring = 2
                            sleep(2)
                        elif find_ring == 2 :
                            drone.sendControlPosition16(0, -2, 0, 5, 0, 0)
                            sleep(2)
                            drone.sendControlPosition16(0, -2, 0, 5, 0, 0)
                            print("find ring , go to right")
                            find_ring = 3
                            sleep(2)
                        elif find_ring == 3:
                            drone.sendControlPosition16(0, 0, 1, 5, 0, 0)
                            print("find ring , go to up")
                            find_ring= 0
                            sleep(2)
                    #링이 일정이상 보인다? -> 그때부터 연산 시작
                    else:
                        min_x1 = np.min(value_th[1])
                        max_x1 = np.max(value_th[1])
                        min_y1 = np.min(value_th[0])
                        max_y1 = np.max(value_th[0])

                        center_x1 = int((min_x1 + max_x1) / 2)
                        center_y1 = int((min_y1 + max_y1) / 2)

                        center_min_x = 640
                        center_max_x = 0
                        center_min_y = 480
                        center_max_y = 0

                        for i in range(center_x1, max_x1 - 5):
                            if bi_blue[center_y1][i] == 255 and i > center_max_x:
                                center_max_x = i
                                break
                        if center_max_x == 0:
                            center_max_x = 639

                        for i in range(center_x1, min_x1, -1):
                            if bi_blue[center_y1][i] == 255 and i < center_min_x:
                                center_min_x = i
                                break
                        if center_min_x == 640:
                            center_min_x = 1

                        for j in range(center_y1, min_y1, -1):
                            if bi_blue[j][center_x1] == 255 and j < center_min_y:
                                center_min_y = j
                                break
                        if center_min_y == 480:
                            center_min_y = 1

                        for j in range(center_y1, max_y1):
                            if bi_blue[j][center_x1] == 255 and j > center_max_y:
                                center_max_y = j
                                break
                        if center_max_y == 0:
                            center_max_y = 479

                        center_x2 = int((center_min_x + center_max_x) / 2)
                        center_y2 = int((center_min_y + center_max_y) / 2)

                        rad_up = center_y2 - center_min_y
                        rad_down = center_max_y - center_y2
                        rad_left = center_x2 - center_min_x
                        rad_right = center_max_x - center_x2

                        if rad_up > rad_down + 30:
                            drone.sendControlPosition16(0, 0, 2, 5, 0, 0)
                            print("circle is on the top")
                            sleep(1)
                        elif rad_down > rad_up + 30:
                            drone.sendControlPosition16(0, 0, -2, 5, 0, 0)
                            print("circle is under the drone")
                            sleep(1)

                        if rad_left > rad_right + 30:
                            drone.sendControlPosition16(0, 2, 0, 5, 0, 0)
                            print("circle is on the left")
                            sleep(1)
                        elif rad_right > rad_left + 30:
                            drone.sendControlPosition16(0, -2, 0, 5, 0, 0)
                            sleep(1)
                            print("circle is on the right")
                        #첫번째 링일 경우
                        if cnt == 0:
                            if center_x2 < 305:  # 중점이 왼쪽에 있다. -> 왼쪽으로 가야한다.
                                drone.sendControlPosition16(0, 1, 0, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to left")
                                print(f"find_num : {find_num}")

                            elif center_x2 > 335:  # 중점이 오른쪽에 있다. -> 오른쪽으로 가야한다.
                                drone.sendControlPosition16(0, -1, 0, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to right")
                                print(f"find_num : {find_num}")

                            elif center_x2 >= 305 and center_x2 <= 335:
                                check[0] = 1

                            if center_y2 < 225:  # 중점이 아래에있다 - > 위로 가야한다.
                                drone.sendControlPosition16(0, 0, 1, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to up")
                                print(f"find_num : {find_num}")

                            elif center_y2 > 255:  # 중점이 위에 있다. -> 아래로 가야한다.
                                drone.sendControlPosition16(0, 0, -1, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to down")
                                print(f"find_num : {find_num}")

                            elif center_y2 >= 225 and center_y2 <= 255:
                                check = [1, 1]
                        # end of first fly detection
                        #빨간색을 아직 못봤고 2,3번째 링을 찾을경우
                        elif red_find == 0 and cnt != 0:
                            if center_x2 < 305:  # 중점이 왼쪽에 있다. -> 왼쪽으로 가야한다.
                                drone.sendControlPosition16(0, 1, 0, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to left")
                                print(center_x2, center_y2)
                                print(f"find_num : {find_num}")

                            elif center_x2 > 335:  # 중점이 오른쪽에 있다. -> 오른쪽으로 가야한다.
                                drone.sendControlPosition16(0, -1, 0, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to right")
                                print(center_x2, center_y2)
                                print(f"find_num : {find_num}")

                            elif center_x2 >= 305 and center_x2 <= 335:
                                check[0] = 1

                            if center_y2 < 225:  # 중점이 아래에있다 - > 위로 가야한다.
                                drone.sendControlPosition16(0, 0, 1, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to up")
                                print(center_x2, center_y2)
                                print(f"find_num : {find_num}")

                            elif center_y2 > 255:  # 중점이 위에 있다. -> 아래로 가야한다.
                                drone.sendControlPosition16(0, 0, -1, 5, 0, 0)
                                sleep(3)
                                find_num = find_num + 1
                                print("go to down")
                                print(center_x2, center_y2)
                                print(f"find_num : {find_num}")

                            elif center_y2 >= 225 and center_y2 <= 255:
                                check[1] = 1

                        #아직 직진을 한번도 안한 상태
                        if step == 0:
                            # 첫번째 링에서 4번정도 찾으면 그냥 가라
                            if cnt == 0  and find_num >= 4:
                                print("go to forward 18 find >=4")
                                drone.sendControlPosition16(18, 0, 0, 6, 0, 0)
                                sleep(5)
                                phase_1_1 = 0
                                phase_1_2 = 1
                                cnt = cnt + 1
                                step = 0
                                find_num = 0
                                check = [0, 0]
                                already = 1
                            # 2,3번째 링도 8번 찾으면 가라
                            elif cnt != 0 and find_num >= 8:
                                print("go to forward 25 find>=8")
                                print(center_x2, center_y2)
                                drone.sendControlPosition16(25, 0, 0, 6, 0, 0)
                                sleep(5)
                                phase_1_1 = 0
                                phase_1_2 = 1
                                cnt = cnt + 1
                                find_num = 0
                                check = [0, 0]


                            # find가 4,8을 넘기전에 찾으면 직진  첫번째 링에선 1.8m직진
                            if check == [1, 1]  and cnt == 0:
                                print("go to forward 18")
                                print(center_x2, center_y2)
                                drone.sendControlPosition16(18, 0, 0, 6, 0, 0)
                                sleep(5)
                                phase_1_1 = 0
                                phase_1_2 = 1
                                cnt = cnt + 1
                                find_num = 0
                                check = [0, 0]


                            # 2,3번째 링에선 2.5m직진
                            elif check == [1, 1]  and cnt != 0:
                                print("go to forward 25")
                                print(center_x2, center_y2)
                                drone.sendControlPosition16(25, 0, 0, 6, 0, 0)
                                sleep(5)
                                phase_1_1 = 0
                                phase_1_2 = 1
                                cnt = cnt + 1
                                find_num = 0
                                check = [0, 0]
                        #이미 직진을 한번 했다면 조금만 직진 (전처럼 1.8미터나 2.5미터 직진하면 박을테니까)
                        elif step >= 1 :
                            # 이미 한번 직진했다면 1.1m만 직진
                            if check == [1, 1]:
                                sleep(3)
                                print("go to forward 11 ")
                                print(center_x2, center_y2)
                                drone.sendControlPosition16(11, 0, 0, 5, 0, 0)
                                sleep(3)
                                phase_1_1 = 0
                                phase_1_2 = 1
                                cnt = cnt + 1
                                find_num = 0
                                step = 0
                                check = [0, 0]

                # end of phase 1_1
                #파란색 링 통과 후
                if phase_1_2 == 1:
                    bi_red = red_hsv(image)
                    bi_pup = puple_hsv(image)
                    bi_blue = blue_hsv(image)
                    #파란색 링이 아직도 일정이상 보인다? -> 페이즈1로 돌아가서 다시 링 중점찾고
                    #여기서 step이 증가되니까 다시 직진할때 거리는 위에서 말했듯이 조금만 직진하겠지?
                    if np.sum(bi_blue) / 255 > 30000:
                        phase_1_1 = 1
                        phase_1_2 = 0
                        step = step + 1
                        find_num = 0
                        print(" back to phase 1 ")
                        drone.sendControlPosition16(-2, 0, 0, 5, 0, 0)
                        sleep(3)
                    #파란색 링이 안보일때 이제 레드를 찾는다
                    else:
                        sleep(4)
                        value_th_red = np.where(bi_red[:, :] == 255)
                        if np.sum(value_th_red) != 0:
                            min_x1_red = np.min(value_th_red[1])
                        else:
                            min_x1_red = 0

                        #빨간색표식이 왼쪽에 보이면 왼쪽으로 이동
                        if min_x1_red < 300:
                            print("red on the left")
                            drone.sendControlPosition16(-1, 0, 0, 5, 0, 0)
                            sleep(2)
                        #빨간색이 일정이상 안보일때 직진
                        if np.sum(bi_red) < 20000 and cnt < 3:
                            drone.sendControlPosition16(2, 0, 0, 5, 0, 0)
                            print("go to red")
                            sleep(2)
                        #일정읻상 보이고 마지막 링이 아닐때
                        elif np.sum(bi_red) >= 20000 and cnt < 3:
                            if cnt != 3:
                                value_th_red = np.where(bi_red[:, :] == 255)
                                min_x1_red = np.min(value_th_red[1])
                                max_x1_red = np.max(value_th_red[1])
                                #빨간색 표식의 크기가 작으면 다시직진
                                if max_x1_red - min_x1_red < 25:
                                    sleep(2)
                                    print("red is far")
                                    drone.sendControlPosition16(1, 0, 0, 5, 0, 0)
                                    red_find = 1
                                #크기가 크면 좌회전 실시
                                else:
                                    print("turn left")
                                    sleep(2)
                                    drone.sendControlPosition16(0, 0, 0, 0, 90, 20)
                                    sleep(4)
                                    drone.sendControlPosition16(10, 0, 0, 6, 0, 0)
                                    sleep(4)
                                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)
                                    sleep(2)
                                    phase_1_1 = 1
                                    phase_1_2 = 0
                                    step = 0
                                    already = 0
                                    red_find = 0
                                    find_ring = 0
                        #3번째 링을 통과했으면 보라색을 찾는다.
                        elif cnt >= 3:

                            bi_pup = puple_hsv(image)
                            value_th_pup = np.where(bi_pup[:, :] == 255)

                            min_x1_pup = np.min(value_th_pup[1])
                            max_x1_pup = np.max(value_th_pup[1])

                            if max_x1_pup - min_x1_pup < 25:
                                sleep(2)
                                drone.sendControlPosition16(1, 0, 0, 5, 0, 0)
                                print("puple is far")
                            else:
                                print("Landing")
                                # 녹화 종료
                                drone.sendLanding()
                                sleep(5)
                                drone.close()
                                wc = False



    except Exception as e:
        print(e)
        drone.sendStop()
        sleep(2)
        picam.stop_recording()
        drone.close()


