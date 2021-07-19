# Bleague_드론드론드로롱

## 시작하기
이 지침은 프로젝트를 설정하고 소프트웨어 작동 방식을 이해하는 데 도움이됨. 파일 구조와 각 파일의 기능을 볼 수 있음.

### 요구사항

*requirements.txt* 파일을 참조하거나 다음을 실행.

    pip install -r requirements.txt
    

## 대회진행 전략
1, 2, 3단계를 통과할때 Step을 나눠 이동하도록 함.

Step0은 초록색의 픽셀 수를 세어 링의 중점을 찾음. 
Step1은 화면 중심에 초록색이 있다면 링의 중점을 잡기 어려우므로 뒤로 1m만큼 후진하도록 함. 
Step2는 화면 중심을 기준으로 링 내부의 가로, 세로의 길이를 측정하여 비율에 따라 링의 중점을 잡음.


### 1단계, 2단계
링의 통과를 위해서는 링의 중점 탐색이 중요하므로 우선 픽셀의 개수를 세어 대략적인 링의 중심을 잡을 수 있도록 함.

링을 지나치지 않을 정도로 일정 거리 직진한 후 링의 중점을 잡고 빨간색 점을 탐지한 후 링을 통과함. 

링을 통과하였다면 드론을 좌회전시킴. 

### 3단계
2단계에서 좌회전을 한 후 3단계의 높이를 판단함. 

2단계 링의 높이를 기억해 놓고 2단계 링의 높이와 반대되는 방향으로 고도를 조절함. 

그 후 정면에 있는 링의 픽셀 개수를 세고 기준치보다 낮을 경우 좌우로 이동하여 링의 위치를 판별함.

## 알고리즘 설명
![algorithm](https://user-images.githubusercontent.com/65804253/87540477-b9c3ab80-c6da-11ea-89ed-854869c4dabc.png)

## 소스코드 설명
### 초록색을 HSV로 변환
초록색을 HSV로 변환을 하고 노이즈 발생을 줄이기 위하여 침식을 사용하였음.
```
def green_hsv(image):
    image_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
    H = image_hsv[:,:,0]
    S = image_hsv[:,:,1]
    V = image_hsv[:,:,2]
    _, bi_H = cv2.threshold(H, 60, 255, cv2.THRESH_BINARY)
    _, bi_H_ = cv2.threshold(H, 80, 255, cv2.THRESH_BINARY_INV)
    _, bi_S = cv2.threshold(S, 230, 255, cv2.THRESH_BINARY)
    _, bi_V = cv2.threshold(V, 15, 255, cv2.THRESH_BINARY)

    bi_H_r = cv2.bitwise_and(bi_H, bi_H_) 
    bi_H_r = cv2.bitwise_and(bi_H_r, bi_S)
    bi_H_r = cv2.bitwise_and(bi_H_r, bi_V)

    return bi_H_r
```

### 링 탐지
상, 하, 좌, 우 픽셀을 나눔.

phase_1 일때는 1단계, phase_2일때는 2단계, phase_3일때는 3단계

                 if phase_1 == 1:
                    bi_green = green_hsv(image)
                    see_green = False

                    left_pixel = np.count_nonzero(bi_green[:, 0:320] > 127)
                    right_pixel = np.count_nonzero(bi_green[:, 320:640] > 127)
                    up_pixel = np.count_nonzero(bi_green[0:240, :] > 127)
                    down_pixel = np.count_nonzero(bi_green[240:480, :] > 127)
                    
                    whole_pixel =  np.count_nonzero(bi_green[:, :] > 127)
                   
### Step0
초록색의 픽셀 수를 세어 링의 중점을 찾음. 

                    if step == 0:
                        step0_flag = [0, 0]
                        if left_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                            sleep(1)
                            step0_flag[0] = 0
                            print("ring_right")
                        elif right_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                            sleep(1)
                            step0_flag[0] = 0
                            print("ring_left")
                        else:
                            step0_flag[0] = 1
                            print("left and right correct")

                        if up_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                            sleep(1)
                            step0_flag[1] = 0
                            print("ring_down")
                        elif down_pixel < whole_pixel * 0.4:
                            drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                            sleep(1)
                            step0_flag[1] = 0
                            print("ring_up")
                        else:
                            step0_flag[1] = 1
                            print("up and down correct")
                            
픽셀의 수를 세어 중심을 찾았다면 1.3m만큼 직진함.
                        
                        if step0_flag == [1, 1]:
                            print("Next Step!")
                            step0_flag = [0, 0]
                            step += 1
                            drone.sendControlPosition16(13, 0, 0, 5, 0, 0)
                            sleep(3)
                            
<img src="https://user-images.githubusercontent.com/65804253/87548928-26917280-c6e8-11ea-8b22-bc820921e26c.gif" height="400px"></img>

### Step1
화면 중심에 초록색이 있다면 링의 중점을 잡기 어려우므로 뒤로 1m만큼 후진하도록 함. 

                   elif step == 1:

                        if bi_green[240, 320] == 255:
                            see_green = True
                        if see_green == True:
                            drone.sendControlPosition16(-10, 0, 0, 5, 0, 0)
                            sleep(3)
                            step -= 1
                        else:
                            step += 1
### Step2
화면 중심을 기준으로 링 내부의 가로, 세로의 길이를 측정하여 비율에 따라 링의 중점을 잡음.

                   elif step == 2:
                        step2_flag = [0, 0]
                        if bi_green[240, 320] == 255:
                            see_green = True
                            step -= 1

                        else:
                            for i in range(320):
                                if bi_green[240, 320 - i] == 255:
                                    left_length = i
                                    break
                                else:
                                    left_length = i
                            for i in range(320):
                                if bi_green[240, 320 + i] == 255:
                                    right_length = i
                                    break
                                else:
                                    right_length = i
                            ring_width = abs(right_length - left_length)

                            for i in range(240):
                                if bi_green[240 - i, 320] == 255:
                                    up_length = i
                                    break
                                else:
                                    up_length = i
                            for i in range(240):
                                if bi_green[240 + i, 320] == 255:
                                    down_length = i
                                    break
                                else:
                                    down_length = i
                            ring_height = abs(down_length - up_length)

                            print(left_length, right_length)
                            print(up_length, down_length)
                            print(ring_width, ring_height)

                            if left_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, -1, 0, 1, 0, 0)
                                sleep(1)
                                step2_flag[0] = 0
                                print("ring_right")
                            elif right_length < ring_width * 0.4:
                                drone.sendControlPosition16(0, 1, 0, 1, 0, 0)
                                sleep(1)
                                step2_flag[0] = 0
                                print("ring_left")
                            else:
                                step2_flag[0] = 1
                                print("left and right correct")

                            if up_length < ring_height * 0.4:
                                drone.sendControlPosition16(0, 0, -1, 1, 0, 0)
                                sleep(1)
                                step2_flag[1] = 0
                                print("ring_down")
                            elif down_length < ring_height * 0.4:
                                drone.sendControlPosition16(0, 0, 1, 1, 0, 0)
                                sleep(1)
                                step2_flag[1] = 0
                                print("ring_up")
                            else:
                                step2_flag[1] = 1
                                print("up and down correct")
                                
빨간색 점을 인식하여 링을 통과함.

                            if step2_flag == [1, 1]:
                                bi_red = red_hsv(image)
                                if np.count_nonzero(bi_red[:, :] > 127) > 1:
                                    print("phase_1 is Done!")
                                    drone.sendControlPosition16(12, 0, 0, 5, 0, 0)
                                    sleep(3)
                                    drone.sendControlPosition16(0, 0, 0, 0, 0, 0)
                                    sleep(2)
                                    drone.sendControlPosition16(0, 0, 0, 0, 90, 45)
                                    sleep(2)
                                    drone.sendControlPosition16(11, 0, 0, 5, 0, 0)
                                    sleep(3)
                                    phase_1 = 0
                                    phase_2 = 1
                                    step2_flag = [0, 0]
                                    step = 0
                                
                                
###
2단계의 반대 방향으로 고도 조절.


                        if first_sight == True:
                            if ud_flag == 0:
                                drone.sendControlPosition16(0, 0, 5, 5, 0, 0)
                                sleep(3)
                            else:
                                drone.sendControlPosition16(0, 0, -5, 5, 0, 0)
                                sleep(3)
                            first_sight = False
                            
                            
###
3단계에서 링의 위치를 찾기 위하여 좌우로 이동.


                        if lr_detection == False:
                            if np.count_nonzero(bi_green[:, :] > 127) > PHASE3_PIXEL:
                                step += 1
                                lr_detection = True
                            else:
                                if lr_flag == 0:
                                    drone.sendControlPosition16(0, -12, 0, 5, 0, 0)
                                    sleep(3)
                                    lr_flag += 1
                                else:
                                    drone.sendControlPosition16(0, 12, 0, 5, 0, 0)
                                    sleep(2)
                                    drone.sendControlPosition16(0, 0, 0, 0, 0, 0, )
                                    sleep(2)
                                    drone.sendControlPosition16(0, 12, 0, 5, 0, 0)
                                    sleep(2)
                                    lr_flag = 0
                                    step += 1
                                    lr_detection = True
                                    

###

###
                    
