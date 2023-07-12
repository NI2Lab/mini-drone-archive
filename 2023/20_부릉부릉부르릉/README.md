2023 미니드론 경진대회 [부릉부릉부르릉]
======================================
강진우
남기현
남유빈

대회 진행 전략
--------------

대회 맵 구성은 다음과 같다.   
> 1단계: 1m 이동하여 상하/좌우 길이가 변동되는 링 통과, 링에서 2m 뒤에 있는 표식을 확인해서 우측으로 90도 회전
>    > 2단계: 1m 이동하여 상하/좌우 길이가 변동되는 링 통과, 링에서 2m 뒤에 있는 표식을 확인해서 우측으로 90도 회전
>    >    > 3단계: 1m 이동하여 상하/좌우 길이가 변동되는 링 통과, 링에서 2m 뒤에 있는 표식을 확인해서 우측으로 45도 회전
>    >    >   >4단계: 1~3m 이동하면서 상하/좌우 길이와 각도가 변동되는 링의 1m 뒤에 있는 표식을 확인한 후 링에서 1m 앞에 있는 표식에 착지  

<br>

채점 1순위는 링 통과 개수 및 착지 여부(단계 통과 여부), 2순위는 시간이다.<br>
 이때, 각 단계마다 시간을 초과하지 않고 통과해야 해당 단계를 통과했다고 인정한다.

> * 1단계 링: 40초     
>> * 2단계 링: 40초 
>>> * 3단계 링: 60초 
>>>> * 4단계 착륙: 100초

> 총 시간: 4분
    
<br>


* **링 및 표식의 픽셀 수를 이용해 드론 제어:**

    - 1, 2, 3, 4단계 모두 파란 천을 픽셀 단위로 파악하고  그 안의 원의 반지름을 계산하여 원을 파악한다.

    - 1, 2, 3, 4단계 모두 상하좌우 원의 크기를 비교해 드론의 상하좌우 위치를 조절한다.

    - 1, 2, 3단계에서 천막의 사각형 형태를 검출해내어 원이 있는 천막만을 파악한다.

* **링 검출을 위한 드론 이동 전략:**
    - 천막의 사각형 형태의 픽셀을 계산하여 천막을 인식한 후 드론의 위치를 조정한다.

    - 각 단계에서 천막이 드론과 너무 가까우면 후진 후 다시 탐색한다. 
    
    - 천막이 한 쪽에만 치우쳐있거나 뒤의 다른 천막이 동시에 인식되어 사각형 모양이 인식되지 않으면 드론의 상하위치를 이동하는 방식으로 정확성과 속도를 높혔다.

* **4단계 각도 조절 전략:**
    - 2단계 통과 후 3단계 표식까지의 최적의 경로를 설정하기 위해 각도를 45도 돌린후 최적의 각도를 탐색한다.

    - 드론과 천막 간의 각도가 0도일 때가 최적의 각도이며, 이 때 드론이 천ㄱ을 제대로 된 사각형으로 인식하므로 이를 활용해 드론의 위치를 천막의 중앙으로 조정한다.
     
### 1단계 전략    
- 드론 이륙 후, 파란색 천에 뚫린 원을 정확하게 인식하기 위해 뒤로 이동하여 파란 천이 시야에 전부 들어오게 한다.
- 그 후 원의 중심을 정확히 찾는다.
- 중심을 통과하고 난 후 빨간색 표식을 탐지되면 드론을 90도 회전한다.
### 2단계 전략   
- 드론이 전진한 후 파란색 천에 뚫린 원을 정확하게 인식하기 위해 뒤로 이동하여 파란 천이 시야에 전부 들어오게 한다.
- 그 후 원의 중심을 정확히 찾는다.
- 중심을 통과하고 난 후 빨간색 표식을 탐지되면 드론을 90도 회전한다.
### 3단계 전략   
- 드론이 전진한 후 파란색 천에 뚫린 원을 정확하게 인식하기 위해 뒤로 이동하여 파란 천이 시야에 전부 들어오게 한다.
- 그 후 원의 중심을 정확히 찾는다.
- 중심을 통과하고 난 후 초록색 표식이 탐지되면 드론을 우측으로 45도 회전한다.
### 4단계 전략   
- 드론이 파란색 천에 뚫린 원을 감지하고 중심을 정확하게 찾는다.
- 드론의 수직, 수평 위치의 오차를 계산하여 정확한 각도를 조절해 원의 중심과 일치하게 한다.
- 원의 1m 뒤의 보라색 표식을 확인하면 드론이 탐지하고 있는 원의 크기를 파악하여 드론의 이동방향을 계산하고 링으로부터 1m 앞에 위치한 표식에 드론이 위치하면 표식에 정확히 착지한다.
     
<br>

**대회 맵 구성과 비슷한 환경을 만들어 연습**<br>
![111](picture/111.jpg)
![222](picture/222.jpg)

알고리즘 설명 및 소스코드 설명
------------------------------

#드론 객체 초기화
```matlab
    clear all;
close;
droneobj = ryze()
cameraObj = camera(droneobj);

stage=0;
targetcenter_notfull=[480 250];%[480 300];
targetcenter_full=[480 260];%[480 240];
count=0;
reverse_th=650000;
figure();hold on;
takeoff(droneobj);
print_on=1;
```
* 해당 작업을 통해 MATLAB의 작업공간을 초기화한다. Tello드론의 객체를 선언하고 드론의 카메라 객체를 선언한다. 그 후 각 변수들을 설정항 값으로 초기화한다.
* reverse_th=650000를 통해 역전 임계값을 설정하고 이미지를 시각적으로 표시하기 위해 그래픽 창을 생성 및 그래프를 그리기 위한 작업을 한다.
* 드론을 이륙시키고 print_on=1로 설정해 그림을 그리는 옵션을 설정한다.

#이륙 후, 드론의 높이 조정
```matlab
    % 원하는 높이만큼 띄우는 코드
dist=readHeight(droneobj); %0.2가 가장 극단적 %1.7
disp(dist);
uptarget=1.1-dist;

if uptarget>=0.2
    moveup(droneobj,'Distance',uptarget,'WaitUntilDone',true);
elseif uptarget <= -0.2
    movedown(droneobj,'Distance',abs(uptarget),'WaitUntilDone',true); 
end
```
* 이 코드는 readHeight 함수를 사용하여 현재 드론의 높이를 측정하고, 목표하는 높이에 도달하기 위해 필요한 거리를 계산하는 코드이다.
* 계산된 거리에 따라 드론은 위, 아래로 이동하여 목표한 높이에 도달하게 된다.

<br>

#변수 설정 및 초기값 할당
```matlab
    % 비행을 위해 바뀌는 변수
blue_full=0;
margin_notfull=[40,40]; % 가로, 세로
margin_full=[40,40];
hovering=100;
move_ref=[0,0];
convert_pixel2ply=[40,40];
rf=480;
cf=360;
reverseOn=0;
se = strel('disk',70);
center_in=0;
stage_in=0;
target_on=0;
stage_up_count=0;
large_circle_pre=100;
```
* 이 코드에서변수들을 설정하고 초기값을 할당해준다.<br>
* blue_full: 현재 탐지된 객체가 가득 찬 상태인지를 나타내는 플래그이다. 0은 빈 상태, 1은 가득 찬 상태를 뜻한다.
* margin_notfull: 객체가 가득 차지 않은 상태에서 이동할 때 사용되는 여유 공간의 크기를 의미한다. 가로와 세로의 픽셀 수를 포함한 배열로 나타낸다.
* margin_full: 객체가 가득 찬 상태에서 이동할 때 사용되는 여유 공간의 크기를 의미한다. 가로와 세로의 픽셀 수를 포함한 배열로 나타낸다.
* hovering: 드론이 호버링하는 높이.
* move_ref: 이동 명령을 저장하는 배열이다. [0,0]으로 초기화시켰으며, [1,0]은 위로 이동, [-1,0]은 아래로 이동, [0,1]은 오른쪽으로 이동, [0,-1]은 왼쪽으로 이동하는 것을 뜻한다.
* convert_pixel2ply: 픽셀을 실제 거리로 변환하는 데 사용되는 값이다. 가로와 세로의 픽셀 수를 포함한 배열로 나타낸다.
* rf: 이미지의 행에서 원의 중심으로 사용되는 값이다.
* cf: 이미지의 열에서 원의 중심으로 사용되는 값이다.
* reverseOn: 객체 탐지 시 원을 표시하기 위해 이진화 이미지를 반전시키는 데 사용되는 플래그이다. 0은 반전하지 않음, 1은 반전함을 뜻한다.
* se: 객체 경계 상자를 생성하기 위해 사용되는 요소이다.
* center_in: 이동 명령을 수행한 후 원의 중심에 도달했는지 여부를 나타내는 플래그이다. 0은 도달하지 않음, 1은 도달함을 뜻한다.
* stage_in: 스테이지 초기화를 수행했는지 여부를 나타내는 플래그이다. 0은 초기화하지 않음, 1은 초기화함을 뜻한다.
* target_on: 탐지된 객체의 유무를 나타내는 플래그이다. 0은 탐지되지 않음, 1은 탐지됨을 뜻한다.
* stage_up_count: 스테이지 1로 진입하기 전에 수행된 스테이지 0에서 드론의 이동 횟수를 나타낸다.
* large_circle_pre: 이전 프레임에서 탐지된 원의 반지름 값이다.

<br>

#stage0 동작
```matlab
    while(stage==0)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull);
        stage_in=1;
        center_in=0;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        disp("stage0 init");
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);

    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
        if move_ref(1)==1
            stage_up_count=stage_up_count+1;
        elseif move_ref(1)==-1
            stage_up_count=stage_up_count-1;
        end
    end
%         
    if center_in
        stage=goThroughCircle(droneobj,stage,2.3);
        stage_in=0;
    end
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
    
end
```
* stage 내부의 초기 변수를 설정한다.
* stage_in 변수가 0일 때, targetcenter_full 값을 stage_init() 함수를 사용하여 초기화한다. 이 함수는 이전 스테이지의 결과와 다양한 매개변수를 사용하여 목표의 중심 좌표를 설정한다.
* count 변수를 증가시켜 다음 단계로 넘어가게 한다.
* image=snapshot(cameraObj);를 통해 드론 카메라에서 이미지를 캡처한다. 그 후 이미지를 전처리하여 탐지하기 쉬운 형태로 변환한다.
* bw_fill_rectangle() 함수를 사용하여 객체를 탐지하고 bw_fill 이미지를 채운다/
* stats = regionprops(bw)를 사용해 탐지된 객체의 속성을 추출한다.
* 객체가 탐지된 경우, target_on 변수를 1로 설정한다/
* detectObject() 함수를 사용하여 이미지에서 객체를 탐지하게 한다. 이 함수는 이진화된 이미지에서 객체 경계를 찾고, 경계 상자를 그리며, 중심 좌표를 반환한다.
* 탐지된 객체가 없는 경우, 이미지와 "No Object Detected" 메시지를 표시하고 stage를 다시 0으로 설정하여 루프를 다시 반복하게 한다.
* 탐지된 객체가 있는 경우, 객체의 중심 좌표를 targetcenter 변수에 저장한다.
* 원의 중심 좌표와 목표 중심 좌표 사이의 오차를 계산한다.
* 오차가 임계값 reverse_th보다 큰 경우 goWhere_circle() 함수를 사용하여 원 주변으로 어떻게 이동할지 정한다.
* 그렇지 않은 경우 goWhere() 함수를 사용하여 드론의 이동 방향을 결정한다.
* 파란색 사각형을 인식하고 이 사각형의 중심을 viscircles 함수를 사용해 빨간 원으로 시각화 하고 현재 드론의 위치를 파란 사각형으로 시각화한다.
* 이미지를 표시한다.필요한 시각화 작업을 수행한다.
* 오차가 임계값 threshold보다 작은 경우, stage를 1로 설정하여 다음 스테이지로 진행한다.

<br>

#stage1 동작
```matlab
    while(stage==1)
    if stage_in==0
        disp("previous up count="+stage_up_count);
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_up_count=0;
        stage_in=1;
        center_in=0;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        disp("stage1 init");
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);
        
    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
    end
%         
    if center_in
        stage=goThroughCircle(droneobj,stage,2.4);
        stage_in=0;
    end
    
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
    
    
end
```
* stage1에서는 드론이 촬영한 이미지에서 사각형 객체를 탐지하고 이의 중심을 찾아 이동 명령을 생성하여 드론이 해당 객체의 중심에 접근하도록 한다.
* stage_in==0이면 stage_init 함수를 호출하여 초기 설정을 수행하고, stage_in, center_in, targetcenter_full, targetcenter_notfull 변수를 설정한다.
* bw_show=bw_fill;: 경계 상자를 채운 이진 이미지를 시각화하기 위해 bw_show 변수에 할당하고 imshow(bw_show)를 통해 이진 이미지를 출력한다;
* 드론 카메라에서 이미지를 캡처한 후 이미지의 RGB 채널을 추출하고 파란색 채널에서 빨간색 채널과 녹색 채널의 절반을 제거하여 파란색 이미지를 생성한다.
* image_only_B >63을 사용해 설정한 임계값 이상인 픽셀만을 포함하는 이진 이미지를 생성한다.
* 객체의 경계 상자를 채우기 위한 이진 이미지를 생성하고 stats = regionprops(bw)를 사용해 이진 이미지에서 객체의 속성을 추출한다.
* 파란색 사각형을 인식하고 이 사각형의 중심을 viscircles 함수를 사용해 빨간 원으로 시각화 하고 현재 드론의 위치를 파란 사각형으로 시각화하여 두 경계 상자의 위치를 비교한다.
* 이때 드론의 실제 위치보다 좀 더 위로 설정해 드론의 카메라 위치에 의해 생기는 오차를 최소화 한다.
* if(~isempty(stats)): 객체가 탐지된 경우 실행된다. target_on 변수를 1로 설정하고, bw_fill_rectangle 함수를 호출하여 경계 상자를 채운다.
* 객체가 탐지되지 않은 경우 target_on 변수를 0으로 설정한다.
* 채워진 경계 상자의 픽셀 수가 일정 임계값을 넘으면 blue_full 변수를 1로 설정한다.
* 경계 상자의 픽셀 수가 임계값보다 작은 경우 blue_full 변수를 0으로 설정한다.
* blue_full이 0이고 target_on이 1인 경우, goWhere 함수를 호출하여 이동 방향을 결정한다.
* blue_full이 1인 경우, bw 이미지를 반전시키고, goWhere 함수를 호출하여 드론의 이동 방향을 결정한다.
* 사각형의 중심에 드론이 도달한 경우, goThroughCircle 함수를 호출하여 드론이 원을 통과하고 stage 변수를 업데이트합니다.
* 드론이 원을 통과한 후 빨간 표식을 탐지하면 드론이 우측으로 90도 회전한다.
* 이후 stage의 변수값을 올려 다음 단계로 넘어간다.

* **stage 1 이미지**<br>
![stage1_1](picture/stage1_1.png)
- 드론의 중심 위치와 원의 중심이 맞지 않음으로 up과 left 출력
![stage1_2](picture/stage1_2.png)
- 드론의 중심 위치와 원의 중심이 맞지 않음으로 up만 출력
![stage1_3](picture/stage1_3.png)
- 드론의 중심과 원의 중심이 일치하므로 전진 시행

<br>

#stage2 동작
```matlab
    while(stage==2)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_in=1;
        center_in=0;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        disp("stage2 init");
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw;
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats))
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);

    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
    end
%         
    if center_in
        stage=goThroughCircle(droneobj,stage,2);
        stage_in=0;
    end
    
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
    
    
end
```
* stage1과 동일한 동작을 수행한다.

* **stage 2 이미지**<br>
![stage2_1](picture/stage2_1.png)
- 드론이 완전한 사각형을 인지하지 못하므로 down 출력
![stage2_2](picture/stage2_2.png)
- 드론이 완전한 사각형을 인지하지 못하므로 down 출력
![stage2_3](picture/stage2_3.png)
- 드론의 중심과 원의 중심이 일치하지 않으므로 down, right 출력
![stage2_4](picture/stage2_4.png)
- 드론의 중심과 원의 중심이 일치하지 않으므로 down, right 출력
![stage2_5](picture/stage2_5.png)
- 드론의 중심과 원의 중심이 일치하지 않으므로 left만 출력
![stage2_6](picture/stage2_6.png)
- 드론의 중심과 원의 중심이 일치하지 않으므로 right만 출력
![stage2_7](picture/stage2_7.png)
- 드론의 중심과 원의 중심이 일치하므로 전진 함수 수행

<br>

#stage3 동작 
```matlab
    while(stage==3)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_in=1;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        center_in=0;
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw;
    % bw_fill(:,:)=0;
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);

    % centers
    % radii
    % if hovering<0
    %     hovering=hovering-1;
    %     continue;
    % elseif hovering==0
    %     hovering=hovering-1;
    %     disp("hovering end")
    % end
        
    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
    end
%         
    if center_in
        % stage=goLand(droneobj,stage,image);
        stage=goThroughCircle(droneobj,stage,1);
        stage_in=0;
    end
    
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
end
```
* stage1과 동일한 동작을 수행한다.
* 그러나 원을 통과한 후 초록색 표식을 탐지하게 되면 드론을 우측으로 45도 회전시킨다.

* **stage 3 이미지**<br>
![stage3_1](picture/stage3_1.png)
- 원의 중심이 정확히 안 찾아지므로 드론의 위치 조정
![stage3_2](picture/stage3_2.png)
- 드론의 중심과 원의 중심이 일치하므로 전진 함수 수행

<br>

#stage4 동작
```matlab
    while(stage==4)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_in=1;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        center_in=0;
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw;
    % bw_fill(:,:)=0;
    bw_show=bw;

    % stats = regionprops(bw);   
    % centerIdx=1;
    % 
    % if(~isempty(stats)) 
    %     target_on=1;
    %     bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    % else
    %     target_on=0;
    % end
    % [row_fill, col_fill] = find(bw_fill);
    % 
    % [row, col] = find(bw);
    
    if (~isempty(bw))
        [centers,radii]=imfindcircles(bw,[100,400],"ObjectPolarity","dark","Sensitivity",0.98);
    end
    centerIdx=1;
    find_circle=0;
    if (~isempty(radii))
        find_circle=1;
        for i = 1:numel(radii)
            if radii(i)>radii(centerIdx)
                centerIdx=i;
            end 
        end
        if numel(radii)==1
            cf=centers(1);
            rf=centers(2);
        else
            cf=centers(centerIdx,1);
            rf=centers(centerIdx,2);
        end
        if abs(large_circle_pre-radii(centerIdx))>50
            find_circle=0;
        end
        large_circle_pre=radii(centerIdx);

        disp("large radii="+radii(centerIdx));
    end
    go=0;
    if find_circle==1
        [move_ref,center_in]=goWhere_circle(rf,cf,targetcenter_notfull,convert_pixel2ply,margin_notfull);
        if mean(abs(move_ref))
            move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
        end
        
        
        if radii(centerIdx)> 185 && radii(centerIdx) < 215
            stage=stage+1;
            stage_in=0;
        elseif radii(centerIdx) >= 215
            go=-1;
        else
            go=1;
        end
    end

    if center_in
        if go==1
            moveforward(droneobj,'WaitUntilDone',true,'distance',0.21);
        else
            moveback(droneobj,'WaitUntilDone',true,'distance',0.21);
        end
        % move(droneobj, [go*0.2 0 0],"WaitUntilDone",true,"Speed",1);
    end


    % 
    % if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
    %     blue_full=1;
    % else
    %     blue_full=0;
    %     % bw_show=bw_fill;
    % end
    % 
    % if blue_full==0 && target_on==1
    %     [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    % elseif blue_full==1
    % 
    %     reverseOn=1;
    %     bw=~bw;
    % 
    %     bw = imerode(bw,se); %밖으로 미는것
    %     % bw = imdilate(bw,se); %안으로 미는것
    % 
    %     [row, col] = find(bw);
    %     [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
    % 
    % 
    %     bw_show=bw;
    % end
    
%         
    
    
    if print_on==1
        imshow(bw_show);
        if (~isempty(centers)) && find_circle==1
            if numel(radii)==1
                viscircles(centers,radii);
            else
                viscircles(centers(centerIdx,:),radii(centerIdx,:));
            end
        end     
        viscircles([cf,rf],3,'Color','red');
        
        rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
            targetcenter_notfull(2)-margin_notfull(2), ...
            margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
      
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end

end
```
* stage 1에서 수행한 것과 같이 파란색 사각형 객체를 찾고 이 객체의 중점을 찾아서 이동한다.
* 그 후에 원을 찾는 알고리즘인 imfindcircles 함수를 사용해 원을 탐지한다. 탐지된 원의 중심좌표와 반지름을 얻는다.
* 이 과정에서 가장 큰 반지름을 가진 원의 중심 좌표를 찾는다.
* 탐지된 원이 존재하고 가장 큰 반지름을 가진 원을 찾았을 경우, 중심 좌표와 반지름을 업데이트 한다.
* 드론을 앞으로 전진시키고 다시 원을 탐지한다.
* 새롭게 찾은 원의 반지름과 이전에 찾은 반지름과의 차이가 50보다 크면, 원을 찾지 못한 것으로 간주한다.
* 원을 찾았다면 goWhere_circle 함수를 호출하여 드론이 원의 중심에 접근하도록 이동 방향을 결정한다.
* 원의 반지름이 215보다 크면 go 변수를 -1로 설정하여 드론을 뒤로 이동하게 한다.
* 원의 반지름이 185보다 작으면 go 변수를 1로 설정하여 드론을 앞으로 이동하게 한다.
* 원의 반지름이 185보다 크고 215보다 작으면 stage 값을 1 증가시켜 다음 스테이지로 넘어간다.

* **stage 4 이미지**<br>
![stage4_1](picture/stage4_1.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_2](picture/stage4_2.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_3](picture/stage4_3.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_4](picture/stage4_4.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_5](picture/stage4_5.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_6](picture/stage4_6.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_7](picture/stage4_7.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_8](picture/stage4_8.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_9](picture/stage4_9.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_10](picture/stage4_10.png)
- 드론이 원하는 크기의 원을 찾지 못한 상태에서 드론과 원의 중심이 일치하지 않으므로 위치 조정
![stage4_11](picture/stage4_11.png)
- 원과 드론의 중심을 맞추기 위해 드론 위치 조정
![stage4_12](picture/stage4_12.png)
- 원과 드론의 중심을 맞추기 위해 드론 위치 조정
![stage4_13](picture/stage4_13.png)
- 원과 드론의 중심을 맞추기 위해 드론 위치 조정
![stage4_14](picture/stage4_14.png)
- 원과 드론의 중심을 맞추기 위해 드론 위치 조정
![stage4_15](picture/stage4_15.png)
- 드론이 이상적인 원의 크기를 찾았으므로 다음 단계로 넘어감

<br>

#stage5 동작
```matlab
    while(stage==5)

    disp("stage=5");
    land(droneobj);
    % abort(droneobj);
end
```
* stage가 5라면 stage=5를 출력하고 드론을 착륙한다.

<br>

#bw_fill_rectangle 함수
```matlab
   function bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx)
    for i = 1:numel(stats)
        if stats(i).Area>stats(centerIdx).Area
            centerIdx=i;
        end
    end
    rectangle('Position', stats(centerIdx).BoundingBox, ...
        'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');

    stat_int=uint16(stats(centerIdx).BoundingBox);
    bw_fill(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
end
```
* 사각형을 사용하여 bw_fill 이미지를 채우는 함수다.
* 이 함수는 주어진 통계 정보와 중심 인덱스를 기반으로 가장 큰 영역을 선택하고 해당 영역을 bw_fill 이미지로 채운다.
* 인식한 사각형을 파란 점선으로 표시하여 시각적으로 확인할 수 있게 한다.

<br>

#goLand 함수
```matlab    
    function stage=goLand(droneobj,stage,image)
    

    moveforward(droneobj,'WaitUntilDone',true,'distance',0.5,'Speed',1);
    disp("moveforward");
    stage=stage+1;
end
```
* 이 함수는 드론을 전진시키며 "moveforward"를 출력하는 함수다.

<br>

#goWhere_circle 함수
```matlab
    function [move_ref,center_in]=goWhere_circle(rf,cf,targetcenter,convert_pixel2ply,margin)
    
    error_r=rf-targetcenter(2);
    error_c=cf-targetcenter(1);
    move_ref(1)=0;
    move_ref(2)=0;
    center_r=0;
    center_c=0;
    center_in=0;
    if abs(error_r)>margin(2) %위아래 판단, 에러가 특정 margin 밖에 있을 때
        if error_r>0
            disp('down');
            move_ref(1)=-1;
            center_r=0;
        else
            disp('up');
            move_ref(1)=1;
            center_r=0;
        end
    else
        disp('stop up down');
        center_r=1;
        % UDIn_notfull=UDIn_notfull+1;
    end
    
    if abs(error_c)>margin(1) %양옆 판단, 에러가 특정 margin 밖에 있을 때
        if error_c>0
            disp('right');
            move_ref(2)=1;
            center_c=0;
        else
            disp('left');
            move_ref(2)=-1;
            center_c=0;
        end
    else
        disp('stop right left');
        center_c=1;
        % RLIn_notfull=RLIn_notfull+1;
    end

    if center_c && center_r
        center_in=1;
    end
end
```    
* 원형 객체를 향해 이동하기 위한 이동 벡터를 계산하는 함수다.
* 이 함수는 현재 드론과 객체 중심 간의 오차를 계산하고, 오차에 기반하여 이동 벡터를 생성한다. 
* 이동 벡터는 위/아래 방향과 좌/우 방향의 이동을 나타내며, 드론이 객체의 중심으로 이동하게 한다.
* 드론이 객체의 중심에 있다고 판단되면 드론의 이동을 멈춘다.

<br>

#goWhere 함수
```matlab    
    function [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter,convert_pixel2ply,margin)
    rf=mean(row);
    cf=mean(col);
    %viscircles([cf rf],3);

    error_r=rf-targetcenter(2);
    error_c=cf-targetcenter(1);
    move_ref(1)=0;
    move_ref(2)=0;
    center_r=0;
    center_c=0;
    center_in=0;
    if abs(error_r)>margin(2) %위아래 판단, 에러가 특정 margin 밖에 있을 때
        if error_r>0
            disp('down');
            move_ref(1)=-1;
            center_r=0;
        else
            disp('up');
            move_ref(1)=1;
            center_r=0;
        end
    else
        disp('stop up down');
        center_r=1;
        % UDIn_notfull=UDIn_notfull+1;
    end
    
    if abs(error_c)>margin(1) %양옆 판단, 에러가 특정 margin 밖에 있을 때
        if error_c>0
            disp('right');
            move_ref(2)=1;
            center_c=0;
        else
            disp('left');
            move_ref(2)=-1;
            center_c=0;
        end
    else
        disp('stop right left');
        center_c=1;
        % RLIn_notfull=RLIn_notfull+1;
    end

    if center_c && center_r
        center_in=1;
    end
end
```
* 사각형 객체를 향해 이동하기 위한 이동 벡터를 계산하는 함수다.
* 이 함수는 현재 드론과 객체 중심 간의 오차를 계산하고, 오차에 기반하여 이동 벡터를 생성한다.
* 이동 벡터는 위/아래 방향과 좌/우 방향의 이동을 나타내며, 드론이 객체의 중심으로 이동하도록 제어한다.
* 드론이 객체의 중심에 있다고 판단되면 드론의 이동을 멈춘다.

<br>

#goThroughCircle 함수
```matlab    
    function stage=goThroughCircle(droneobj,stage,dis)
    moveforward(droneobj,'WaitUntilDone',true,'distance',dis,'Speed',1);
    disp("moveforward");
    stage=stage+1;
end
```
* 드론을 전진시켜 원을 통과하도록 하는 함수다.
* 이 함수는 드론을 지정된 거리만큼 전진시키고, stage 변수를 +1한 후 stage값을 반환한다.

<br>

#stage_init 함수
```matlab    
    function [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count)
    switch stage
        case 0
            moveback(droneobj,'WaitUntilDone',true,'distance',0.5);
        case 1
            turn(droneobj,deg2rad(90));
            moveback(droneobj,'WaitUntilDone',true,'distance',0.6);
            if(stage_up_count>2)
                move(droneobj, [0 0 0.4],"WaitUntilDone",true,"Speed",0.1);
            end
            targetcenter_notfull(1)=480;
            targetcenter_notfull(2)=260;
        case 2
            turn(droneobj,deg2rad(90));
            moveback(droneobj,'WaitUntilDone',true,'distance',0.5);
        case 3
            turn(droneobj,deg2rad(45));
            moveforward(droneobj,'WaitUntilDone',true,'distance',1);
        case 4
            targetcenter_notfull(1)=480;
            targetcenter_notfull(2)=260;
        otherwise
            disp("other");
    end
        
end
```
* 각 단계를 초기화하기 위한 함수다. 
* 이 함수는 주어진 stage에 따라 드론의 이동 및 목표 중심 위치를 초기화한다. 
* 각 단계의 초기화 작업에는 드론의 이동과 목표 객체의 중심 위치가 설정된다.
* 초기화 작업을 마치면 업데이트된 targetcenter_full 및 targetcenter_notfull 변수와 stage_up_count 값을 반환한다.


