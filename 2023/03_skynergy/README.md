# skynergy
### sky + energy를 합친 단어로 하늘의 나는 에너지를 뜻 합니다.
### 저희는 바나나떡찌와 찰떡찌로 이루어진 팀 입니다.
![image](https://image.homeplus.kr/td/0724556e-0fc7-45ac-9808-69855a638081)
# 목차
1. 전반적인 설계
2. 주요 알고리즘 설명
3. 소스 코드 설명

# 전반적인 설계
## 1단계
1. 뒤로 이동하면서 원을 탐색
2. 찾은 원의 중심을 탐색 후 이동
3. 앞으로 2m + back_sum 만큼 이동
4. 빨간색 네모 탐색 후 90도 회전
## 2단계
- 1단계와 동일
## 3단계
1. 뒤로 이동하면서 원을 탐색
2. 찾은 원의 중심을 탐색 후 중심으로 이동
3. 앞으로 2m + back_sum 만큼 전진 이동
4. 초록색 네모 탐색 후 45도 회전 이동
## 4단계
1. 전진 하면서 원을 탐색
2. 찾은 원의 중심을 탐색 후 중심으로 이동
3. 앞으로 2m - front_sum 만큼 전진 이동
4. 보라색 네모 탐색 후 착륙

# 주요 알고리즘
## 원 탐색 알고리즘
1. 이미지를 HSV 색 공간으로 변환
2. 파란색 영역만 남기고 나머지는 검은색으로 설정
3. Canny 에지 감지 적용
4. regionprops의 Area, Centroid, MajorAxisLength을 통한 영역 추정
5. 임계값과 주축을 통한 사각형 판별
## 사각형 탐색 알고리즘
1. 이미지를 HSV 색 공간으로 변환
2. 빨간색, 초록색, 보라색 영역만 남기고 나머지는 검은색으로 설정
3. Canny 에지 감지 적용
4. regionprops의 Area,Centroid 통한 영역 추정
5. 임계값을 통한 사각형 판별
## 중심 탐색 알고리즘
1. 원과 사각형의 Centroid 값을 추출
2. 이미지의 중심 값을 추출
3. 이미지의 중심에서 도형의 중심 값의 차이 계산
4. 차이의 부호를 통해 방향을 조정
5. 차이의 값 만큼 이동

# 소스 코드
```matlab
% 필요한 라이브러리 로드  
import matlab.io.*   
import cv.*  
drone = ryze();  
takeoff(drone);  
cameraObj = camera(drone);  
%preview(cameraObj);  
angle = [-5,10,-15,20,-10];  
moveback(drone, Distance=0.4);  
pause(1);  
```

필요한 라이브러리 로드하고 객체를 선언한다.  그 후 드론을 이륙시키고 카메라를 선언한다.  그 후 드론을 후진시켜 원과의 거리를 확보해 원을 찾기쉽게 한다.  

```matlab
% 1단계 
while 1  
    moveup(drone,Distance=0.2);  
    pause(2);  
    [frame,ts] = snapshot(cameraObj);  
    pause(1);  
    [is_cc,x,y] = serch_circle(frame);  
    disp(is_cc);  
    if is_cc  
        img_size = size(frame);  
        ct = img_size(1:2) / 2;  
        x_move = ceil(ct(2)-x)/30;  
        y_move = ceil(ct(1)-y)/30;  
        xm = x_move/100;  
        ym = y_move/100;  
        if xm > 0.1  
            moveright(drone,Distance=xm);  
        elseif xm < -0.1  
            moveleft(drone,Distance=abs(xm));  
        end  
        pause(2);  
        if  ym > 0.1  
            moveup(drone,Distance=ym);  
        elseif ym < -0.1  
            movedown(drone,Distance=abs(ym));  
        end  
        pause(2);  
        break  
    end  
end  
moveforward(drone,Distance=2.4);  
pause(2);  

[frame,ts] = snapshot(cameraObj);  
if red_detection(frame)  
    turn(drone,deg2rad(90));  
end  
pause(1);
```

1단계 통과하기 위한 소스코드이다.  드론을 조금씩 위로 이동시키면서 카메라로 원을 찾는다.  원을 찾으면 이미지의 중심을 계산한 후 x축과 y축을 이동시킨다.  그 후 드론이 링을 통과하도록 앞으로 이동시키고 앞의 빨간색 표식을 인식하게 한다.  표식을 인식한 후 시계방향으로 90도 회전시킨다.  

```matlab
% 2단계   
moveback(drone,Distance=0.5);  
pause(2);  
movedown(drone,Distance=0.5);  
pause(2);  
while 1  
    moveup(drone,Distance=0.2);  
    pause(2);  
    [frame,ts] = snapshot(cameraObj);  
    pause(1);  
    [is_cc,x,y] = serch_circle(frame);  
    disp(is_cc);  
    if is_cc  
        img_size = size(frame);  % 이미지 크기 얻기  
        ct = img_size(1:2) / 2;  % 이미지의 중심 좌표 계산  
        x_move = ceil(ct(2)-x)/30;  
        y_move = ceil(ct(1)-y)/30;  
        xm = x_move/100;  
        ym = y_move/100;  
        if xm > 0.1  
            moveright(drone,Distance=xm);  
        elseif xm < -0.1  
            moveleft(drone,Distance=abs(xm));  
        end  
        pause(2);  
        if  ym > 0.1  
            moveup(drone,Distance=ym);  
        elseif ym < -0.1  
            movedown(drone,Distance=abs(ym));  
        end  
        pause(2);  
        break  
    end  
end  
moveforward(drone,Distance=2.5);  
pause(2);  
[frame,ts] = snapshot(cameraObj);  
if red_detection(frame)  
    turn(drone,deg2rad(90));  
end  
pause(1);
```

2단계를 통과하기 위한 소스코드이다.  다시 링을 찾기 위해서 드론은 뒤로, 아래로 이동시켜 원을 찾기 쉽게 한다. 그 후 드론을 조금씩 위로 이동시켜 원을 찾는다. 원을 찾아 이동하는 방식은 1단계와 동일하다.  

```matlab
% 3단계
moveback(drone,Distance=0.5);
pause(1);
while 1
    moveup(drone,Distance=0.2);
    pause(2);
    [frame,ts] = snapshot(cameraObj);
    pause(1);
    [is_cc,x,y] = serch_circle(frame);
    disp(is_cc);
    if is_cc
        img_size = size(frame);  % 이미지 크기 얻기
        ct = img_size(1:2) / 2;  % 이미지의 중심 좌표 계산
        x_move = ceil(ct(2)-x)/30;
        y_move = ceil(ct(1)-y)/30;
        xm = x_move/100;
        ym = y_move/100;
        if xm > 0.1
            moveright(drone,Distance=xm);
        elseif xm < -0.1
            moveleft(drone,Distance=abs(xm));
        end
        pause(2);
        if  ym > 0.1
            moveup(drone,Distance=ym);
        elseif ym < -0.1
            movedown(drone,Distance=abs(ym));
        end
        pause(2);
        break
    end
end
moveforward(drone,Distance=2.5);
pause(2);
```
3단계를 통과하기 위한 소스코드이다. 1,2단계와 동일한 과정으로 원을 찾고 중심으로 이동한다. 3단계는 각도 회전후 착륙을 하는 것이 목표이므로 적절한 각도를 회전 후 앞으로 전진시킨후 착륙시킨다.  

```matlab

   % 이미지를 HSV 색 공간으로 변환
    hsvImage = rgb2hsv(image);
    
    % 하늘색 범위 지정 (HSV)
    lowerblue = [0.5, 0.15, 0.4];
    upperblue = [0.65, 1, 1];
    
    % 하늘색 영역 마스크 생성
    blueMask = (hsvImage(:,:,1) >= lowerblue(1) & hsvImage(:,:,1) <= upperblue(1) ...
        & hsvImage(:,:,2) >= lowerblue(2) & hsvImage(:,:,2) <= upperblue(2) ...
        & hsvImage(:,:,3) >= lowerblue(3) & hsvImage(:,:,3) <= upperblue(3));
    
    % 초록색 영역만 남기고 나머지는 검은색으로 설정
    resultImage = image;
    resultImage(repmat(~blueMask, [1 1 3])) = 0;
    
    % Canny 에지 감지 적용
    grayImage = rgb2gray(resultImage);
    threshold = [0.05 0.15]; % 에지 감지 임계값 설정
    sigma = 10; % 가우시안 필터의 표준 편차 설정
    cannyImage = edge(grayImage, 'Canny', threshold, sigma);
    bw = bwareaopen(cannyImage,9);
    bw = imfill(bw,'holes');  
```
드론으로 받은 이미지를 처리하는 소스코드이다. 파란색의 링을 인식해야하므로 파란색을 감지하고 edge를 딴 후 원안을 채우는 imfill함수를 사용했다.  

```matlab
[B,L] = bwboundaries(bw,'noholes');
    % % 두 번째 이미지 보여주기
    % figure;  % 새 창에서 이미지 표시
    % imshow(cannyImage);
    % title('이미지 1'); 

    % figure;  % 새 창에서 이미지 표시
    imshow(label2rgb(L,@jet,[.5 .5 .5]));
    % title('이미지 2'); 
    hold on
    for k = 1:length(B)
      boundary = B{k};
      plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
    end
    stats = regionprops(L,'Area','Centroid','MajorAxisLength','MinorAxisLength');
    
    threshold = 0.88;
    
    % loop over the boundaries
    for k = 1:length(B)
    
      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};
    
      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));
      
      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;
      diameter = stats(k).MajorAxisLength;
      
      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;

      % display the results
      metric_string = sprintf('%2.2f',metric);
    
      % mark objects above the threshold with a black circle
      if metric > threshold && diameter > 100
          is_Circle = 1;
          centroid = stats(k).Centroid;
          x = centroid(1);
          y = centroid(2);
          plot(x,y,'ko');
          disp(diameter);
          plot(centroid(1),centroid(2),'ko');
      end
      text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
       'FontSize',14,'FontWeight','bold')
    end
end  
```

파란색 원을 찾기 위해서 임계값을 설정하고 중심을 찾고 표시하는 코드소스이다.  

```matlab
function ct_move(dn,xm,ym)
    xm = xm/100;
    ym = ym/100;
    pause(2);
    if xm > 0.1
        moveright(dn,Distance=xm);
    elseif xm < -0.1
        moveleft(dn,Distance=abs(xm));
    end
    pause(2);
    if  ym > 0.1
        moveup(dn,Distance=ym);
    elseif ym < -0.1
        movedown(dn,Distance=abs(ym));
    end
    pause(2);
end  
```

x방향과 y방향을 조절하는 소스코드이다. 일정기준을 넘거나 넘지 못했을 경우를 나누어 이동할수있도록 했다.  

```matlab
function is_red = red_detection(image)

    is_red = 0;

    image = rgb2hsv(image);
    
    h = image(:,:,1);
    detect_h = ((h >= 0.9) | (h <= 0.05));
    
    s = image(:,:,2);
    detect_s = (s >= 0.2) & (s <= 1);
    
    v = image(:,:,3);
    detect_v = (v >= 0.2) & (v <= 1);
    
    detect_Rdot = detect_h & detect_s & detect_v;
    
    canny_img = edge(detect_Rdot, 'Canny', 0.9, 8);
    
    fill_img = imfill(canny_img, 'holes');
    figure;
    imshow(fill_img);  
```

    빨간색 영역을 감지하는 소스코드이다. 이것을 변형하여 초록색과 보라색도 감지할수있게 했다.  

```matlab
    function is_green = green_detection(image)

    is_green = 0;

    image = rgb2hsv(image);
    
    h = image(:,:,1);
    detect_h = (h >= 0.25) & (h <= 0.45);
    
    s = image(:,:,2);
    detect_s = (s >= 0.2) & (s <= 1);
    
    v = image(:,:,3);
    detect_v = (v >= 0.2) & (v <= 1);  
```

    초록색을 감지하는 소스코드이다.  

```matlab
    function is_purple = purple_detection(image)

    is_purple = 0;

    image = rgb2hsv(image);
    
    h = image(:,:,1);
    detect_h = (h >= 0.7) & (h <= 0.9);
    
    s = image(:,:,2);
    detect_s = (s >= 0.2) & (s <= 1);
    
    v = image(:,:,3);
    detect_v = (v >= 0.2) & (v <= 1);  
```

    보라색을 감지하는 소스코드이다.
