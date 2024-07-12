# 인하에어로스페이스 기술 워크샵 

본 프로젝트에서는 드론이 촬영한 이미지의 노이즈를 제거하고, 정확한 이미지 분석을 통해 목표물을 식별하는 과정을 다음과 같은 절차를 통해 수행하였습니다.

## 대회 진행 전략

### 문제점
드론이 촬영하는 이미지는 노이즈가 너무 심하여 이를 해결하기 위한 이미지 보정 작업이 필요합니다. Preview를 실행했을 때 회색 화면이 이미지의 대부분을 차지하거나, 깜빡거리는 등의 문제가 발생하였습니다. 이러한 문제를 해결하기 위해 다음과 같은 처리 방법을 사용했습니다.

### 처리 방법

1. **연속 이미지 캡처 및 HSV 변환**
   - 제일 깔끔한 이미지를 찾아내기 위해 15장의 이미지를 연속적으로 캡처하여 모두 HSV 이미지로 변환했습니다. 
   - 변환된 이미지 중에서 원하는 색조(파란색)의 픽셀들이 가장 많은 이미지를 선택하여 이미지의 노이즈를 무시했습니다.

2. **이미지 블러 처리**
   - 캡처한 이미지가 깔끔하지 못하기 때문에, 원하는 색조의 픽셀을 추출할 때 불필요한 노이즈가 화면에 끼게 됩니다. 이를 지우기 위해 이미지를 블러 처리했습니다.

3. **객체 인식 및 밀도 분석**
   - 블러 처리한 이미지를 `bwconncomp` 함수와 `regionprops` 함수를 사용하여 연속된 픽셀들을 하나의 객체로 인식했습니다. 
   - 많은 픽셀을 가진 객체의 밀도가 높다고 인식하였고, 가장 높은 밀도의 세 개 정도의 객체만 추출하여 남은 잔여 노이즈를 제거했습니다.

4. **반복 처리 및 노이즈 제거**
   - 위의 2번과 3번 과정을 한 번 더 반복하여, 이미지에 남아있는 큰 객체(밀도가 큰 노이즈들)에 블러 처리를 하여 밀도를 낮추었습니다.
   - `bwconncomp` 함수와 `regionprops` 함수를 이용하여 분해된 노이즈들을 삭제했습니다.

위와 같은 원리로 밀도가 낮은(연속된 픽셀의 개수가 작은) 노이즈들과 밀도가 큰 노이즈들을 제거하였고, 깔끔해진 링의 사각형 테두리로부터 링의 중점을 찾았습니다.

## 알고리즘 설명
![코드구성](https://github.com/aerospacejaehoonyang/Inha_aerospace/blob/master/%EC%9D%B8%ED%95%98%EC%97%90%EC%96%B4%EB%A1%9C%EC%8A%A4%ED%8E%98%EC%9D%B4%EC%8A%A4_%EA%B2%B0%EC%8A%B9%EC%BD%94%EB%93%9C/%EC%BD%94%EB%93%9C%20%EA%B5%AC%EC%84%B1.png)
### 이미지에 있는 노이즈를 제거하여 링의 중점을 찾았고, 드론을 링의 중점 앞에 위치하도록 제어하였습니다. 그리고 링 앞에 있는 색상 타겟별로 주어진 임무를 수행하게 하였습니다. 색상 타겟별로 주어진 임무는 아래와 같습니다.

![색상마커 알고리즘](https://github.com/aerospacejaehoonyang/Inha_aerospace/blob/master/%EC%9D%B8%ED%95%98%EC%97%90%EC%96%B4%EB%A1%9C%EC%8A%A4%ED%8E%98%EC%9D%B4%EC%8A%A4_%EA%B2%B0%EC%8A%B9%EC%BD%94%EB%93%9C/%EC%83%89%EC%83%81%EB%A7%88%EC%BB%A4%20%EC%95%8C%EA%B3%A0%EB%A6%AC%EC%A6%98.png)

## 소스 코드 설명

### 드론 연결 및 초기 설정
```matlab
%% Bobby
%Bobby on
bobby = ryze();             %드론 연결
bobbycam = camera(bobby);   %드론 카메라 연결
%preview(bobbycam)          %드론 preview On

% Bobby takeoff
takeoff(bobby)              %드론 takeoff
moveup(bobby,'Distance',0.2)%시야각 확장
```
#### Tello 드론을 컴퓨터와 연결하고, 이미지를 수월하게 인식하기 위해 take off 이후 뒤로 이동하였습니다.

### 최적 이미지 탐색
```
%30장의 snapsht 촬영, blue 색조픽셀이 가장 많은 이미지 검출(파랑1,빨강2,초록3,보라4)
color = 1;
max_cap = 25;
img_vec = zeros(720,960,max_cap);
black = zeros(720,960);
pause(1)
    for i = 1:max_cap
        img = snapshot(bobbycam);
        hsv_img = rgb2hsv(img); % RGB 이미지를 HSV 이미지로 변환
        H = hsv_img(:,:,1);     % HSV 데이터의 색조 추출
        img_ = ((H>0.588)&(H<0.665));
        if isempty(img)
            mark_sum(i) = 0;        
        else
            mark_sum(i) = sum(img_,'all');
            img_vec(:,:,i) = img_;
        end
    end     
    [~,ind] = max(mark_sum);
     blue=img_vec(:,:,ind);
```
#### 드론이 이미지를 25장 캡처하여 그중에서 가장 원하는 색조의 픽셀 수가 많은 이미지를 추출합니다.

### 이미지 중점 탐색
```
%% Cam의 center
[cam_length_x,cam_length_y] = size(blue);
cam_center_x =round(0.5*cam_length_y);
cam_center_y =round(0.5*cam_length_x)-150;  %실제 드론의 위치와 snapshot의 위치를 보정함
```
#### 이미지의 크기를 읽어서 이미지의 중점을 찾습니다.

### 이미지 수축
```
%% 이미지 수축
%이미지의 블러 효율을 높이기 위해 imresize 함수를 사용하여 이미지의 해상도를 낮춤
C_shrink =0.8;    %이미지를 C_shrink 만큼 수축시킴
img_cont = imresize(blue, [round(cam_length_x*C_shrink),round(cam_length_y*C_shrink)]);
```
#### 이미지의 해상도를 낮추어서 이미지 블러처리 속도를 단축시킵니다.

### 이미지 블러 처리
```
function blured_img = image_blur(target_color,Cb)

image_size = size(target_color);
for i = 1:image_size(1)
    colum = target_color(i,:);
    for j = ((Cb/2) + 1) : length(colum) - (Cb/2)
        if sum(colum(j - (Cb*0.5):j + (Cb*0.5))) >= Cb
            target_color(i,j) = 1;
        elseif sum(colum(j - (Cb*0.5):j + (Cb*0.5))) < Cb*0.85
            target_color(i,j) = 0;
        end
    end
end
for j = 1:image_size(2)
    row =target_color(:,j);
    for i = ((Cb/2) + 1) : length(row) - (Cb/2)
        if sum(row(i - (Cb*0.5): i + (Cb*0.5))) >= Cb
            target_color(i,j) = 1;
        elseif sum(row(i - (Cb*0.5): i + (Cb*0.5))) < Cb*0.85
            target_color(i,j) = 0;
        end
    end
end
blured_img = target_color;
end
```
#### HSV 이미지의 파란색 색조로 변환된 논리형 행렬에서, 모든 행벡터와 열벡터를 추출하여 흐릿하게 처리합니다. 밀도가 낮은 노이즈들의 크기를 더욱 작게 만듭니다.

### 객체 선정으로 노이즈 제거
```
CC = bwconncomp(blured_img,4);
stats =regionprops(CC,'Area');
Areas = [stats.Area];
img = false(size(blured_img));

for i = 1:3
    [~,ind]=max(Areas);
    img(CC.PixelIdxList{ind}) = true;
    Areas(ind) = NaN;
end
```
#### bwconncomp 함수와 regionprops 함수를 사용하여, 연속된 이미지들을 하나의 객체로 인식하게 하였고, 가장 많은 픽셀을 가진 3개의 객체들만 남겨 밀도가 높은 객체만 유지합니다.

### 링의 사각형 모서리 위치 탐색
```
%% 링의 모서리의 위치 탐색
[crow,ccol] = find(img==1);  %블러처리한 링의 끝단 부분을 탐색

% 가림막 링의 모서리 위치들(해상도 변경 이전 점들)
edge_top_target = min(crow)*(1/C_shrink);
edge_bottom_target = max(crow)*(1/C_shrink);
edge_left_target = min(ccol)*(1/C_shrink);
edge_right_target = max(ccol)*(1/C_shrink);
edge_horizon_center = mean(ccol)*(1/C_shrink);
edge_vertical_center = mean(crow)*(1/C_shrink);
```
#### 링의 사각형 형상에서, 이미지의 모서리에 위치한 점들을 추출하고, 그 점들의 중점을 임시적인 링의 중점으로 설정합니다.

### 이미지 크롭
```
%% 이미지 crop
% 표적(링) 이외의 노이즈들을 무시하고, 링의 내부를 탐색하기 위해 표적의 테두리를 기준으로
% 이미지를 crop함
C_crop = 1;     %crop 비율계수
croped_img = imcrop(blue, [edge_left_target*C_crop,edge_top_target,abs(edge_right_target-edge_left_target)/C_crop,abs(edge_top_target-edge_bottom_target)]);

```

#### 링의 모서리에 위치한 점들을 기준으로 이미지를 크롭하여 링 천막 외부의 불필요한 노이즈들을 무시합니다.

### 링의 테두리 계산
```
%% 링의 테두리 계산
% crop, blur 된 이미지의 center
horizon_center = edge_horizon_center - edge_left_target ;
vertical_center = edge_vertical_center - edge_top_target;

row_ = double(crop_blured_img(floor(vertical_center),:));
col_ = double(crop_blured_img(:,floor(horizon_center)));

cir_right = find(row_(floor(horizon_center):end) == 1, 1, "first") + horizon_center;
fliped_row = flip(row_(1:floor(horizon_center)));
cir_left = -find(fliped_row == 1, 1, 'first') + horizon_center;

cir_bottom = find(col_(floor(vertical_center):end) == 1, 1, 'first') + vertical_center;
fliped_col = flip(col_(1:floor(vertical_center)));
cir_top = -find(fliped_col == 1, "first") + vertical_center;

```
#### 링의 사각형 모서리 위치를 탐색하고, 링의 중점을 계산합니다. 링의 사각형 모서리에 위치한 점들의 중점으로부터 시작하여, 수평축과 수직축으로 링의 원형 테두리에 가장 먼저 닿는 점들을 링의 원형 모양 위에 있는 점들로 인식하였습니다. 그리고 각각의 점들의 중점을 링의 중심이 되도록 계산하였습니다.

### 드론제어
```
%% 드론 제어

critical_distance = 60;      %[pixel]

% 제어 종료조건
if (abs(x_distance) < critical_distance-5) && (abs(y_distance) < critical_distance )
    fprintf("bobby found center of ring!\n")
    break
end

if target_num >1
    x_distance = center_x - cam_center_x;
    if abs(x_distance) > critical_distance*1.2
        if sign(x_distance) == -1
            turn(bobby,deg2rad(-7)) 
        elseif sign(x_distance) == 1
            turn(bobby,deg2rad(7))
        end
    end
end

% x축 위치 조정
if abs(x_distance) > critical_distance 
    if sign(x_distance) ==-1
        moveleft(bobby,'Distance',0.2)
        fprintf("move left\n")
    elseif sign(x_distance) == 1
        moveright(bobby,'Distance',0.2)
        fprintf("move right\n")
    end
end

% y축 위치 조정
if abs(y_distance) > critical_distance
    if sign(y_distance) == -1
        moveup(bobby,'Distance',0.3)
        movedown(bobby,'Distance',0.2)
        fprintf("move up\n")
    elseif sign(y_distance) == 1
        movedown(bobby,'Distance',0.2)
        fprintf("move down\n")
    end
end

% 링 위의 점4개를 찾지 못한다면 뒤로 이동하여 다시 탐색함.
if sum(red,'all') <= 691200*0.004
    fprintf("center of the ring cannot be found!\n");
    imshow(blue)
    moveup(bobby,'Distance',0.2,'Speed',1)
end
```
#### 링의 중점으로부터 드론의 카메라 중점까지의 거리를 계산하여, 거리의 부호로부터 드론이 움직일 방향을 결정하였습니다. 거리가 임계 거리보다 큰 경우에는 드론의 각도를 조정하고, x축과 y축 위치를 조정하여 링의 중심으로 정렬시켰습니다.

### 색상 마크 인식 (빨간색)
```
%% 색상 마크 인식 (빨간색)
color = target_num;

for i = 1:max_cap
    img = snapshot(bobbycam);
    hsv_img = rgb2hsv(img); % RGB 이미지를 HSV 이미지로 변환
    H = hsv_img(:,:,1);     % HSV 데이터의 색조 추출
    
    if (color == 1) || (color == 4) 
        img_ = ((H>0)&(H<0.03)) | ((H>0.93)&(H<1)); % red
    elseif color == 2
        img_ = ((H>0.35)&(H<0.37));   % green
    elseif color == 3
        img_ = ((H>0.69)&(H<0.74));   % purple
    end
    
    if ~isempty(img)
        mark_sum(i) = sum(img_,'all');
        img_vec(:,:,i) = img_;
    end
end     

[~,ind] = max(mark_sum);
red=img_vec(:,:,ind);

CC = bwconncomp(red,8);
stats =regionprops(CC,'Area');
Areas = [stats.Area];
red = false(size(red));
[~,ind]=max(Areas);
red(CC.PixelIdxList{ind}) = true;

% 빨간색 표적의 중점 탐색
[r_row,r_col] = find(red==1);
red_center_x = mean(r_col);
red_center_y = mean(r_row);

% 이미지에 빨간색 중점 표시
hold on
imshow(red)
plot(red_center_x, red_center_y,'Marker','+','MarkerSize',8,'Color','r')
```
#### 드론이 이미지를 30장 캡처하여, 가장 적절한 이미지를 추출하도록 하였습니다. 추출된 이미지에서 빨간색 픽셀만을 추출하고, 그 중에서 가장 큰 객체를 빨간색 타겟으로 설정하였습니다. 추출된 빨간색 타겟의 중점을 계산하고 이미지에 표시하였습니다.

