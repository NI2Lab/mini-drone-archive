from time import sleep
from e_drone.drone import *
from e_drone.protocol import *
from picamera.array import PiRGBArray
from picamera import PiCamera
import cv2
import numpy as np


def findcenter(n, second):
    img = cv2.imread(f'{n}.jpg')
    result = ''
    img = cv2.flip(img, 0)  # 1은 좌우 반전, 0은 상하 반전
    img = cv2.flip(img, 1)  # 1은 좌우 반전, 0은 상하 반전
    h, w, c = img.shape
    x, y = w / 2, h / 2
    y = y + 20

    # BGR을 HSV모드로 전환
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # HSV에서 BGR로 가정할 범위를 정의함
    lower_green = (50, 150, 50)
    upper_green = (80, 255, 255)

    # HSV 이미지에서 blue, green, red만 추추하기 위한 임계값
    img_mask_green = cv2.inRange(img_hsv, lower_green, upper_green)

    # mask와 원본 이미지를 비트 연산함
    img_result_green = cv2.bitwise_and(img, img, mask=img_mask_green)

    # GrayScale
    gray = cv2.cvtColor(img_result_green, cv2.COLOR_BGR2GRAY)

    # 테두리에 닿는 부분 있는지 검출
    N = 7
    direction = np.zeros((4, N))
    px_x = np.ones((N, 1))
    px_y = np.ones((N, 1))
    px_w = np.linspace(0, w - 1, N).reshape(N, 1)
    px_h = np.linspace(0, h - 1, N).reshape(N, 1)

    px_up = tuple(map(tuple, np.hstack([px_y * 0, px_w]).astype(np.int64)))
    px_down = tuple(map(tuple, np.hstack([px_y * (h - 1), px_w]).astype(np.int64)))
    px_left = tuple(map(tuple, np.hstack([px_h, px_x * 0]).astype(np.int64)))
    px_right = tuple(map(tuple, np.hstack([px_h, px_x * (w - 1)]).astype(np.int64)))

    for i in range(N):
        if gray[px_up[i]] > 0:
            direction[0, i] = 1
        if gray[px_down[i]] > 0:
            direction[1, i] = 1
        if gray[px_left[i]] > 0:
            direction[2, i] = 1
        if gray[px_right[i]] > 0:
            direction[3, i] = 1

    # 테두리 검출된 상하좌우에 따라 방향 찾기
    sum_direction = direction.sum(axis=1)
    if sum_direction[0] > 1:
        result += 'u'
    if sum_direction[1] > 1:
        result += 'd'
    if sum_direction[2] > 1:
        result += 'l'
    if sum_direction[3] > 1:
        result += 'r'

    # 이진화 & 캐니엣지 & 컨투어
    dst = cv2.medianBlur(gray, 9)  # Median Blur
    ret, thr = cv2.threshold(dst, 1, 255, cv2.THRESH_BINARY)
    img_canny = cv2.Canny(thr, 50, 150)
    _,contours, hierarchy = cv2.findContours(img_canny, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    # 컨투어 일정 길이 이상인 것만 다시 저장
    p = w / 4
    a = []
    for i in contours:
        length = cv2.arcLength(i, closed=True)
        if length > p:
            a += [i]

    a = np.array(a)

    # 컨투어 다시 저장한 것중에 가장 넓이 작은 거 선택
    min_area = w * h
    min_index = 0
    change = False
    for i in range(len(a)):
        contourArea = cv2.contourArea(a[i])
        if contourArea > (min_area / 10):
            if min_area > contourArea:
                min_area = contourArea
                min_index = i
                change = True

    # 컨투어 사각형으로 중심 찾기
    try:
        if second and not change:       # 2단계에서만 왼쪽에 인식한 컨투어는 제외
            b = []
            if not change:
                for i in range(a.shape[0]):
                    xx, yy, ww, hh = cv2.boundingRect(a[i])
                    # 오른쪽에 잡히는것만 다시 저장
                    if int(xx + ww / 2) > x:
                        b += [a[i]]
            min_area2 = w * h
            min_index2 = 0
            for i in range(len(b)):
                contourArea = cv2.contourArea(b[i])
                if min_area2 > contourArea:
                    min_area2 = contourArea
                    min_index2 = i

            xx, yy, ww, hh = cv2.boundingRect(b[min_index2])
            c_x = int(xx + ww / 2)
            c_y = int(yy + hh / 2)

        else:               # 1, 3단계
            xx, yy, ww, hh = cv2.boundingRect(a[min_index])
            c_x = int(xx + ww / 2)
            c_y = int(yy + hh / 2)

            # 하단부 검출일때
            if 'u' in result:
                if 'd' not in result:
                    if a.shape[0] == 2:
                        if not change and min_index == 0:  # 바뀌지 않고 0번째 인덱스일 때
                            xx, yy, ww, hh = cv2.boundingRect(a[1])
                            cv2.rectangle(img, (xx, yy), (xx + ww, yy + hh), (0, 0, 255), 2)
                            c_x = int(xx + ww / 2)
                            c_y = int(yy + hh / 2)

        return [x - c_x, y - c_y]

    except Exception as e:
        print(e)
        return [w,h]


def find_bluecircle(n):
    img = cv2.imread(f'{n}_circle.jpg')
    img = cv2.flip(img, 0)  # 1은 좌우 반전, 0은 상하 반전
    img = cv2.flip(img, 1)  # 1은 좌우 반전, 0은 상하 반전

    # BGR을 HSV모드로 전환
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # HSV에서 BGR로 가정할 범위를 정의함
    lower_blue = (90, 180, 80)
    upper_blue = (110, 255, 255)

    # HSV 이미지에서 blue, green, red만 추추하기 위한 임계값
    img_mask_blue = cv2.inRange(img_hsv, lower_blue, upper_blue)

    # mask와 원본 이미지를 비트 연산함
    img_result_blue = cv2.bitwise_and(img, img, mask=img_mask_blue)

    # 이진화 & 캐니엣지
    gray = cv2.cvtColor(img_result_blue, cv2.COLOR_BGR2GRAY)
    dst = cv2.medianBlur(gray, 9)  # Median Blur
    ret, thr = cv2.threshold(dst, 1, 255, cv2.THRESH_BINARY)
    img_canny = cv2.Canny(thr, 50, 150)

    # 원 검출
    circles = cv2.HoughCircles(img_canny, cv2.HOUGH_GRADIENT, 1, 100, param1=250, param2=10, minRadius=10, maxRadius=40)
    # (이미지,방법,해상도비율,최소거리,캐니에지 임계값,중심임계값, 최소반지름,최대반지름)

    # 원 그리기
    if circles is not None:
        circles = np.uint16(np.around(circles))
        for i in circles[0]:
            mission = True
    else:
        mission = False
    return mission


def find_redcircle(n):
    img = cv2.imread(f'{n}_circle.jpg')
    img = cv2.flip(img, 0)  # 1은 좌우 반전, 0은 상하 반전
    img = cv2.flip(img, 1)  # 1은 좌우 반전, 0은 상하 반전

    # BGR을 HSV모드로 전환
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # HSV에서 BGR로 가정할 범위를 정의함
    lower_red1 = (0, 100, 40)
    upper_red1 = (10, 255, 255)

    lower_red2 = (150, 50, 50)
    upper_red2 = (180, 180, 165)

    # HSV 이미지에서 blue, green, red만 추추하기 위한 임계값
    img_mask_red1 = cv2.inRange(img_hsv, lower_red1, upper_red1)
    img_mask_red2 = cv2.inRange(img_hsv, lower_red2, upper_red2)

    # mask와 원본 이미지를 비트 연산함
    img_result_red1 = cv2.bitwise_and(img, img, mask=img_mask_red1)
    img_result_red2 = cv2.bitwise_and(img, img, mask=img_mask_red2)
    img_result_red = cv2.bitwise_or(img_result_red1, img_result_red2)

    # 이진화 & 캐니엣지
    gray = cv2.cvtColor(img_result_red, cv2.COLOR_BGR2GRAY)
    dst = cv2.medianBlur(gray, 9)  # Median Blur
    ret, thr = cv2.threshold(dst, 1, 255, cv2.THRESH_BINARY)
    img_canny = cv2.Canny(thr, 50, 150)

    # 원 검출
    circles = cv2.HoughCircles(img_canny, cv2.HOUGH_GRADIENT, 1, 100, param1=250, param2=10, minRadius=20, maxRadius=40)
    # (이미지,방법,해상도비율,최소거리,캐니에지 임계값,중심임계값, 최소반지름,최대반지름)

    # 원 그리기
    if circles is not None:
        circles = np.uint16(np.around(circles))
        for i in circles[0]:
            mission = True

    else:
        mission = False
    return mission


# main
drone = Drone()
drone.open()
try:
    drone.sendTakeOff()
    sleep(5)

    camera = PiCamera()
    camera.resolution = (640, 480)  # (2592,1944) # 사진 크기 조금 크게 해봐야할듯
    camera.start_preview()
    time.sleep(2)

    finish = False  # 파란원 찾는 flag
    left_turn = False  # 빨간원 찾는 flag
    n = 0  # 사진 저장 위해서
    second = False  # 2단계 첫번째 상황인지 확인하는 flag
    step = 1  # 현재 단계를 저장
    y_move = 0  # y값 변화 저장
    height = np.zeros(3)

    # 처음 출발점에서 1m 직진
    drone.sendControlPosition16(5, 0, 0, 5, 0, 0)  # 앞으로 50cm
    sleep(1)
    drone.sendControlPosition16(5, 0, 0, 5, 0, 0)  # 앞으로 50cm
    sleep(1)

    while (not finish):

        if step == 1:  # 1단계
            drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
            camera.capture(f'{n}.jpg')
            sleep(1)

            result = findcenter(n, second)

            # 중심값 찾기 전 만약 에러가 난 상태면 현재 상태 유지 후 다시 사진 찍기
            if result[0] == 640 and result[1] == 480:
                continue

            # 중심값 찾기
            if result[0] > 30:
                drone.sendControlPosition16(0, 1, 0, 5, 0, 0)  # 왼쪽으로 10cm
                sleep(1)
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
            elif result[0] < -30:
                drone.sendControlPosition16(0, -1, 0, 5, 0, 0)  # 오른쪽으로 10cm
                sleep(1)
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
            else:
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
                else:
                    # 링 통과
                    height[0] = y_move
                    drone.sendControlPosition16(5, 0, 0, 5, 0, 0)  # 앞으로 50cm
                    sleep(1)
                    drone.sendControlPosition16(8, 0, 0, 5, 0, 0)  # 앞으로 80cm
                    sleep(1)
 
                    while (not left_turn):
                        n += 1
                        drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
                        camera.capture(f'{n}_circle.jpg')
                        sleep(1)
                        left_turn = find_redcircle(n)
                        if left_turn:
                            step += 1

                            drone.sendControlPosition16(0, 0, 0, 0, 90, 30)  # 좌회전
                            sleep(6)

                            drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
                            sleep(1)

                            drone.sendControlPosition16(6, 0, 0, 5, 0, 0)  # 앞으로 60cm
                            sleep(1)
                            drone.sendControlPosition16(10, 0, 0, 5, 0, 0)  # 앞으로 100cm
                            sleep(5)

                            n+=1
                            second = True
                            drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
                            camera.capture(f'{n}.jpg')
                            sleep(1)

                            result = findcenter(n, second)

                            # 중심값 찾기 전 만약 에러가 난 상태면 현재 상태 유지 후 다시 사진 찍기
                            if result[0] == 640 and result[1] == 480:
                                second = False
                                continue

                            # 중심값 찾기
                            if result[1] >= 30:
                                drone.sendControlPosition16(0, 0, 3, 5, 0, 0)  # 위로 30cm
                                sleep(1)
                                y_move += 3
                                if result[0] >= 30:
                                    drone.sendControlPosition16(0, 3, 0, 5, 0, 0)  # 왼쪽으로 30cm
                                    sleep(1)
                                elif result[0] <= -30:
                                    drone.sendControlPosition16(0, -3, 0, 5, 0, 0)  # 오른쪽으로 30cm
                                    sleep(1)
                            elif result[1] <= -30:
                                drone.sendControlPosition16(0, 0, -3, 5, 0, 0)  # 아래로 30cm
                                sleep(1)
                                y_move += -3
                                if result[0] >= 30:
                                    drone.sendControlPosition16(0, 3, 0, 5, 0, 0)  # 왼쪽으로 30cm
                                    sleep(1)
                                elif result[0] <= -30:
                                    drone.sendControlPosition16(0, -3, 0, 5, 0, 0)  # 오른쪽으로 30cm
                                    sleep(1)
                            else:
                                if result[0] >= 30:
                                    drone.sendControlPosition16(0, 3, 0, 5, 0, 0)  # 왼쪽으로 30cm
                                    sleep(1)
                                elif result[0] <= -30:
                                    drone.sendControlPosition16(0, -3, 0, 5, 0, 0)  # 오른쪽으로 30cm
                                    sleep(1)

                            left_turn = False
                            second = False
                            break
                        else:
                            drone.sendControlPosition16(1, 0, 0, 5, 0, 0)  # 앞으로 10cm
                            sleep(1)

        elif step == 2:  # 2단계
            drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
            camera.capture(f'{n}.jpg')
            sleep(1)

            result = findcenter(n, second)

            # 중심값 찾기 전 만약 에러가 난 상태면 현재 상태 유지 후 다시 사진 찍기
            if result[0] == 640 and result[1] == 480:
                continue

            # 중심값 찾기
            if result[0] > 30:
                drone.sendControlPosition16(0, 1, 0, 5, 0, 0)  # 왼쪽으로 10cm
                sleep(1)
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
            elif result[0] < -30:
                drone.sendControlPosition16(0, -1, 0, 5, 0, 0)  # 오른쪽으로 10cm
                sleep(1)
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
            else:
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
                else:
                    # 링 통과
                    height[1] = y_move
                    height[2] = height[1] - height[0]
                    drone.sendControlPosition16(5, 0, 0, 5, 0, 0)  # 앞으로 50cm
                    sleep(1)
                    drone.sendControlPosition16(8, 0, 0, 5, 0, 0)  # 앞으로 80cm
                    sleep(1)
                    while (not left_turn):
                        n += 1
                        drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
                        camera.capture(f'{n}_circle.jpg')
                        sleep(1)
                        left_turn = find_redcircle(n)
                        if left_turn:
                            step += 1

                            drone.sendControlPosition16(0, 0, 0, 0, 90, 30)  # 좌회전
                            sleep(6)

                            drone.sendControlPosition16(6, 0, 0, 5, 0, 0)  # 앞으로 60cm
                            sleep(1)
                            drone.sendControlPosition16(10, 0, 0, 5, 0, 0)  # 앞으로 100cm
                            sleep(5)

                            # 1단계, 2단계 차이로 3단계 높이 조정
                            height_change = -(height[2])
                            drone.sendControlPosition16(0, 0, int(round(height_change)), 5, 0, 0)
                            sleep(1)
                            y_move += int(round(height_change))
                            
                            n += 1
                            drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
                            camera.capture(f'{n}.jpg')
                            sleep(1)

                            result = findcenter(n,second)

                            if result[0] == 640 and result[1] == 480:
                                drone.sendControlPosition16(0, -7, 0, 5, 0, 0)  # 오른쪽으로 70cm
                                sleep(1)
                                break

                            # 3단계 좌우 조정
                            if result[0] >= 0:
                                drone.sendControlPosition16(0, 5, 0, 5, 0, 0)  # 왼쪽으로 50cm
                                sleep(1)
                            else:
                                drone.sendControlPosition16(0, -5, 0, 5, 0, 0)  # 오른쪽으로 50cm
                                sleep(1)
                            break
                        else:
                            drone.sendControlPosition16(1, 0, 0, 5, 0, 0)  # 앞으로 10cm
                            sleep(1)

        elif step == 3:  # 3단계
            drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
            camera.capture(f'{n}.jpg')
            sleep(1)

            result = findcenter(n, second)

            # 중심값 찾기 전 만약 에러가 난 상태면 현재 상태 유지 후 다시 사진 찍기
            if result[0] == 640 and result[1] == 480:
                continue

            # 중심값 찾기
            if result[0] > 30:
                drone.sendControlPosition16(0, 1, 0, 5, 0, 0)  # 왼쪽으로 10cm
                sleep(1)
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
            elif result[0] < -30:
                drone.sendControlPosition16(0, -1, 0, 5, 0, 0)  # 오른쪽으로 10cm
                sleep(1)
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
            else:
                if result[1] > 50:
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # 위로 10cm
                    sleep(1)
                    y_move += 1
                elif result[1] > 30:
                    drone.sendControlWhile(0, 0, 0, 5, 1000)
                    sleep(3)
                elif result[1] < -50:
                    y_move += -1
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  # 아래로 10cm
                    sleep(1)
                elif result[1] < -30:
                    drone.sendControlWhile(0, 0, 0, -5, 1000)
                    sleep(3)
                else:
                    # 링 통과
                    drone.sendControlPosition16(5, 0, 0, 5, 0, 0)  # 앞으로 50cm
                    sleep(1)
                    drone.sendControlPosition16(9, 0, 0, 5, 0, 0)  # 앞으로 90cm
                    sleep(1)

                    while (not finish):
                        n += 1
                        drone.sendControlWhile(0, 0, 0, 0, 1000)  # 호버링
                        camera.capture(f'{n}_circle.jpg')
                        sleep(1)
                        finish = find_bluecircle(n)
                        if finish:
                            step += 1
                            break
                        else:
                            drone.sendControlPosition16(1, 0, 0, 5, 0, 0)  # 앞으로 10cm
                            sleep(1)


        n += 1

    drone.sendLanding()
    sleep(5)
    drone.close()

except Exception as e:
    print(e)
    drone.sendLanding()
    drone.close()
