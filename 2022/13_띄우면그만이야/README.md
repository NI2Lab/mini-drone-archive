# **대회진행 전략**
**주행해야 하는 경기장의 거리를 주어지는 이미지 등으로 판단**
# **알고리즘 설명**
### 1. hsv변환을 통한 링 찾기
* frame에서 감지된 링의 픽셀이 많은 쪽으로 드론을 제어하면서 링을 찾음

 (1) 얻어낸 frame을 hsv변환, 임계값 통해 이진화
 
 (2) 링의 구멍을 채워서 채워진 값이 일정 수치를 넘으면 링을 감지했다고 판단함
 
 (3) 일정 수치를 넘지 못할 경우 이진화된 이미지의 좌우, 상하를 각각 비교하여 드론제어
 
 + ex)왼쪽과 오른쪽 중 오른쪽에 하얀색이 많으면 오른쪽으로 이동
### 2. 링에서 감지된 원을 통해 중심 알아내기
 * 원의 중심과 카메라 중심의 차이를 이용하여 드론 제어
 + 이 때 드론 카메라는 드론 하단에 있기 때문에 원의 중심이 관측된 값보다 높도록 조정
 
 (1) hsv변환, 이진화
 
 (2) 영상에서 원만 표시하여 regionprops를 통해 centeroid 값 얻어냄
 
 (3) 영상 속 원의 중심과 화면중심의 차이를 이용하여 드론 제어
 
 * ex)화면중심 : (480, 360) / 원의 중심 : (470, 280) => 화면중심이 좀 더 아래에 있으므로 위로 이동
### 3. 이동 후 측정된 마커에 따라서 링의 통과 여부 판단
* 이진화를 통해 측정된 마커의 값이 일정 수치를 넘으면 링을 통과하였다고 판단
* 통과했다고 판단되면 회전, 착륙 등 수행
* 통과했다고 판단되지 않으면 앞으로 이동제어

(1)원의 중심으로 이동하였으면 설정된 값만큼 앞으로 이동

(2)hsv변환 후 이진화된 마커의 이미지에서 얼마나 차지하는지에 따라 링의 통과여부를 판단

ex)이동 후 빨간색 마커의 값이 1500 측정 -> 통과했다고 판단하고 다음명령 수행
### 4. 통과 이후 명령 수행
* 만약 1단계라면 90도 회전, 2단계라면 120도 회전 후 대각선 이동, 3단계라면 착지 명령을 수행
# **소스코드 설명**
```
DroneObj=ryze();
cam=camera(DroneObj);
orimiddle=[480, 250];
stack=0;
takeoff(DroneObj);


for phase=1:1:3
```
* 1,2,3단계 모두 같은 링을 인식하고 통과하기 위해서 3번의 반복 실시

```
    while 1


        frame=snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);


        blue = (0.63<h)&(h<0.7)&(0.2<s)&(s<0.6);
```
* 크로마키(링)를 판별하기 위하여 hsv변환을 통한 이진화 작업
```
        blue(1,:) = 1;
        blue(720,:) = 1;

        threshold = imfill(blue,'holes');

        threshold = threshold - blue;
```
* 사각형이 인식이 안될경우 imfill값이 채워지지 않는 오류를 위해 이미지의 가장 위아래를 채워줌

**예시**
```
frame = snapshot(cam);
hsv = rgb2hsv(frame);
h = hsv(:,:,1);
s = hsv(:,:,2);
blue = (0.6<h)&(h<0.7)&(0.4<s)&(s<0.7);
blue = bwareafilt(blue, 1);
imshow(blue)
```
**blue**
![case](https://user-images.githubusercontent.com/69966103/178524552-422a97fe-9a66-416e-941e-be7ee6c86938.png)
```
bw2 = imfill(blue,'holes');
imshow(bw2)
```
**bw2**
![imfillerror](https://user-images.githubusercontent.com/69966103/178524885-53e57fd3-b37d-4f4a-b862-404caf1db193.png)
* **제대로 채워지지 않음**

=>
```
blue(1,:) = 1;
blue(3000,:) = 1;
bw2 = imfill(blue,'holes');
imshow(bw2)
```
**bw2**
![imfill](https://user-images.githubusercontent.com/69966103/178525216-47af4953-9374-4484-b128-2c7ca2fb5311.png)

* 링에서 원만을 인식하기 위해 링을 채워서 빼주는 알고리즘 실행

ex)#frame이미지

![sample1](https://user-images.githubusercontent.com/69966103/178519787-32cb695c-85f1-465b-bb16-07b7d8b667cb.jpg)

#이진화
![blue1](https://user-images.githubusercontent.com/69966103/178519960-8ce155e1-2a97-4f84-a7eb-7c8038845c2e.png)


#원 추출
![threshold](https://user-images.githubusercontent.com/69966103/178521977-7322ea5d-e8d5-4bb3-b3c2-e909b9fdf887.png)

```
        if phase==1
            circle = 50000;
        elseif phase==2
            circle = 30000;
        else
            circle = 30000;
        end
```
* 각 단계마다 드론으로부터 거리가 같지 않기 때문에 판단 픽셀 값 조정
```
        if sum(threshold,'all')>circle
            break;
        else

                if sum(imcrop(blue,[0, 0, 480, 720]),'all')-sum(imcrop(blue,[480, 0, 960, 720]),'all')>20000
                    moveleft(DroneObj,'distance',0.2,'speed',1);
                elseif sum(imcrop(blue,[480, 0, 960, 720]),'all')-sum(imcrop(blue,[0, 0, 480, 720]),'all')>20000
                    moveright(DroneObj,'distance',0.4,'speed',1);
                end

                if sum(imcrop(blue,[0, 0, 960, 360]),'all')-sum(imcrop(blue,[0, 360, 960, 720]),'all')>20000
                    moveup(DroneObj,'distance',0.2,'speed',1);
                elseif sum(imcrop(blue,[0, 360, 960, 720]),'all')-sum(imcrop(blue,[0, 0, 960, 360]),'all')>20000
                    movedown(DroneObj,'distance',0.2,'speed',1);
                end

        end
    end
```
* 원이라고 인식되는 값들이 일정수치를 넘으면 원을 찾아냈다고 판단
* 아닐 경우 이미지를 좌우상하로 나누어 값이 치우친 쪽으로 이동
```
    while 1

        frame=snapshot(cam);    

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);

        blue = (0.63<h)&(h<0.7)&(0.2<s)&(s<0.6);

        blue(1,:) = 1;
        blue(720,:) = 1;


        threshold = (imfill(blue,'holes'));


        threshold = logical(threshold - blue);

        threshold = (bwareafilt(threshold,1));
```
* 원을 식별한 이후 원의 중점을 찾아내는 활동
* **bwareafilt** = 중심좌표가 하나만 나올 수 있도록 가장 큰 영역만 남김
```
        stats = regionprops('table',threshold,'Centroid',...
        'MajorAxisLength','MinorAxisLength');

        dismiddle = stats.Centroid;        
```
* 영상에서 보인 원의 중심좌표를 얻어냄
```
        if dismiddle(1)-orimiddle(1)>=40
            moveright(DroneObj,'Distance',0.2,'speed',1);



        elseif orimiddle(1)-dismiddle(1)>=40
            moveleft(DroneObj,'Distance',0.2,'speed',1);

        end

        if dismiddle(2)-orimiddle(2)>=40
            movedown(DroneObj,'Distance',0.2,'speed',1);



        elseif orimiddle(2)-dismiddle(2)>=40
            moveup(DroneObj,'Distance',0.2,'speed',1);

        end

        if dismiddle(2)-orimiddle(2)<40 && orimiddle(2)-dismiddle(2)<40 && dismiddle(1)-orimiddle(1)<40 && orimiddle(1)-dismiddle(1)<40
            break;
        end

    end
```
* 이미지픽셀의 중심과 촬영된 원의 중심간의 차이만큼을 이동하여서 오차가 적으면 다음을 수행함
```
    if phase==1

        moveforward(DroneObj,'Distance',2,'speed',1);

        while 1

            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);

            red= ((0.93<h)&(h<1))|((0<h)&(h<0.03))&(0.5<s)&(s<0.9);
            red = bwareafilt(red,1);
            if sum(red,'all')>2000
                turn(DroneObj,deg2rad(90))
                break;

            else
                moveforward(DroneObj,'Speed',1,'Distance',0.2);

            end

        end
```
### 1단계
* 감지된 마커의 값이 일정부분을 넘으면 링을 통과했다고 인식하고 90도 회전
* 그렇지 않으면 덜 통과했다고 판단하고 앞으로 이동
```
        moveforward(DroneObj,'Distance',1,'speed',1);
```
* 다음 링을 인식하기 위해 앞으로 이동
```
    elseif phase==2
        moveforward(DroneObj,'Distance',1.5,'speed',1);

        while 1
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);

            green = (0.3<h)&(h<0.4)&(0.2<s)&(s<0.7);              


            if sum(green,'all')>2000

                turn(DroneObj,deg2rad(120))

                break;


            else
                moveforward(DroneObj,'distance',0.2)
            end
        end   
        moveforward(DroneObj,'distance',1.5,'speed',1);
```
### 2단계
* 감지된 마커의 값이 일정부분을 넘으면 링을 통과했다고 인식하고 120도 회전
* 그렇지 않으면 덜 통과했다고 판단하고 앞으로 이동
* 다음 링을 인식하기 위해 앞으로 이동
```
    elseif phase==3
        move(DroneObj,[1, -1, 0],'Speed',1)

        while 1

            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);

            purple= (0.74<h)&(h<0.84)&(0.325<s)&(s<0.8);
            purple = bwareafilt(purple,1);

            if sum(purple,'all')>2000
                land(DroneObj);
                break;
            else
                moveforward(DroneObj,'distance',0.2)

            end
        end
    end
end
```
### 3단계
* 2단계 링에 걸리지 않도록 대각선 이동을 통해 드론제어
* 감지된 마커의 값이 일정부분을 넘으면 링을 통과했다고 인식하고 착륙
* 그렇지 않으면 덜 통과했다고 판단하고 앞으로 이동
  
