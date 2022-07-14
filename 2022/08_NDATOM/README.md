# 대회 진행 전략
대회 맵 구성은 다음과 같다.
> 1단계: 1-3m 이동하여 링 통과, 링에서 1m 뒤에 있는 표식에서 90도 회전
>    > 2단계: 1-3m 이동하면서 상하/앞뒤/좌우 변경된 링 통과, 링에서 1m 뒤에 있는 표식에서 120-150도 사이 회전
>    >    > 3단계: 1-3m 이동하면서 상하/앞뒤/좌우/각도 변경된 링 통과, 링에서 1m 뒤에 있는 표식에서 착지  
<Br>

채점 1순위는 링 통과 개수 및 착지 여부(단계 통과 여부), 2순위는 시간이다.


     이때, 시간을 초과하지 않고 통과해야 단계를 통과했다고 인정한다.

> * 1단계 링: 60초     
>> * 2단계 링: 90초 
>>> * 3단계 링: 130초 
>>>> * 착지: 20초


> 총 시간: 5분
    
<br>
     
### 1단계 전략 
드론을 띄우고, 표식에 가깝도록 전진하여 표식을 확인한다. 그리고 90도 회전한다.
### 2단계 전략
전진 후 파란 링의 중심을 찾고, 다시 전진하면서 표식에 가깝도록 전진하여 확인한다. 그리고 90도 회전한다.
### 3단계 전략
전진 후 45도 회전하고, 중심을 찾고 각도를 조절한 뒤 다시 중심을 찾는다. 그리고 표식에 가깝도록 전진하여 확인 뒤 착지한다.
     
<br>
     
**대회 맵 구성과 비슷한 환경을 만들어 연습**<br>
![KakaoTalk_20220711_113637715](https://user-images.githubusercontent.com/103032180/178187069-9ce6c275-917b-4d44-9b45-9b5c5327a93e.jpg)



# 알고리즘 설명 및 소스코드 설명

# 1단계 알고리즘 및 소스코드 설명[Uploading 1m_center.mat…]()

드론 이륙 후,
```matlab                                                  
    image=snapshot(cameraObj);
    imageHSV=rgb2hsv(image);
    image1H = imageHSV(:,:,1);
    image1S = imageHSV(:,:,2);
    image1V = imageHSV(:,:,3);

    imageR_H = image1H <= 0.01 | image1H >= 0.97;
    imageR_S = image1S >= 0.95 & image1S <= 1.0;
    imageR_V = image1V >= 0.38 & image1V <= 0.41;
    imageR_combi = imageR_H & imageR_S & imageR_V;

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);
    
    image_only_B=image1B-image1R/2-image1G/2;
    bw2 = image_only_B > 55;
    [row2, col2] = find(bw2);
    
    bw_RB=bw2 | bw;
    imshow(bw_RB);
    stats = regionprops(bw);
    centerIdx=1;
    redOn=0;
    red_close=0;
    disp('length(row2) = ');
    disp(length(row2));
    if( length(row2) > 0)
        blueOn=1;
     
```
빨간색의 h, s, v 값을 통해서 빨간색만을 검출하고 R, G, B의 값을 조절하여 크로마키 천의 파란색을 검출한다. regionprops로 빨간색 표식의 속성을 찾는다.
```matlab
         if(~isempty(stats))
        centerIdx=1;
        for i = 1:numel(stats)
            if stats(i).Area>stats(centerIdx).Area
                centerIdx=i;
            end
        end
        
        if stats(centerIdx).Area > 3000
            disp("stage = 2");
            pause(1);
            stage1image=bw;
            turn(droneobj, deg2rad(90));
            pause(0.5);
            moveforward(droneobj,'WaitUntilDone',true,'distance',1);
%                 moveforward(droneobj,'WaitUntilDone',true,'distance',0.6);
            stage = 2;
            break;
        end

        if stats(centerIdx).Area > 1000
            red_close=1;
        end
        
        if red_close==1
            moveforward(droneobj,'WaitUntilDone',true,'distance',0.3);
            disp("moveforward 0.4 slow");
        else
            moveforward(droneobj,'WaitUntilDone',true,'distance',0.5);
            disp("moveforward 0.4 fast");
        end

        redOn=1;
    else
        redOn=0;
        red_close=0;
    end

    if red_close==1 && stage==1
        moveforward(droneobj,'WaitUntilDone',true,'distance',0.2);
        disp("moveforward 0.4 slow not box");
    elseif redOn==0 && stage==1
        moveforward(droneobj,0.8,'WaitUntilDone',true,'Speed',1);
        disp("moveforward 1");
    end
'''
     빨강색 표식을 검출하고 반복문을 사용하여 원하는 표식만 남긴다. 표식의 면적이 3000을 초과하면 stage2로 넘어간다. 표식의 면적이 1000을 초과하면 앞으로 천천히 가면서 표식을 검출한다. 
     
```matlab
if (length(row2) < 50 ||  length(col2) < 50) && red_close==0 && blueOn==1 %파랑이 없고 빨강도 없는 경우 앞으로 70cm가고 90도 오른쪽으로 회전 후 앞으로 1m 전진 후 stage 2로 넘어간다.
        stage=2;
        moveforward(droneobj,'WaitUntilDone',true,'distance',0.7);
        disp('if (length(row) < 50 || length(col) < 50) stage1 end');
        stage1image=bw;
        turn(droneobj, deg2rad(90));
        pause(0.5);
        moveforward(droneobj,'WaitUntilDone',true,'distance',1);
        break;
    end

reverseOn=0;
```
드론이 보는 표식의 크기에 따라 가까운지 먼지 판단하고, 표식이 없고 크로마키 천을 통과했을 경우 1m 직진 후 stage2로 넘어간다.
 
<br>

# 2단계 알고리즘 및 소스코드 설명
3가지 경우를 반복한다. 

### 첫 번째: 링과 드론이 가까워서 링의 파란 부분이 화면에 꽉 찰 때
* 원의 중심과 드론의 중심을 비교는 아이디어를 이용하여 중심을 찾는다.
<br>

링 배경 크로마키를 검출하는 알고리즘은 다음과 같다.

```matlab
    image=snapshot(cameraObj);
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B > 55;
    bw_origin=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        for i = 1:numel(stats)
            if stats(i).Area>stats(centerIdx).Area
                centerIdx=i; 
            end
        end
        rectangle('Position', stats(centerIdx).BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');

        bw(stats(centerIdx).BoundingBox(2):stats(centerIdx).BoundingBox(2)+stats(centerIdx).BoundingBox(4),stats(centerIdx).BoundingBox(1):stats(centerIdx).BoundingBox(1)+stats(centerIdx).BoundingBox(3))=1;
    end
    [row_origin, col_origin] = find(bw_origin); //bw_origin=bw;

    [row, col] = find(bw);
```
![1](https://user-images.githubusercontent.com/103023848/178750372-8dc5b423-5eee-45d9-9878-7e9abd61210c.jpg)

드론 이미지에서, 파란색 성분만을 검출한다.<br>
regionprops 함수로 속성 세트를 측정한다.<br>
가장 큰 면적을 찾는다.<br>
rectangle 함수로 사각형을 그린다.<br>
BOX 안을 모두 흰색(1)으로 만든다.<br>


<br>
중심을 찾는 알고리즘은 다음과 같다.
크로마키 천을 1, 배경을 0으로 하였을 때 1 값이 있는 좌표들의 평균점이 크로마키 천의 중심이다.

```matlab
            image=snapshot(cameraObj);
            image1R = image(:,:,1);
            image1G = image(:,:,2);
            image1B = image(:,:,3);
        
            image_only_B=image1B-image1R/2-image1G/2;
            bw = image_only_B > 55;
            bw=~bw; 
        
            bw = imerode(bw,se); 
    
            [row, col] = find(bw);
        
            rf=mean(row); 
            cf=mean(col);
            viscircles([cf rf],3);
```
![3](https://user-images.githubusercontent.com/103023848/178750662-50f4bd0e-016a-402f-9403-6398a6c3cc2a.jpg)

    
드론 이미지에서, 파란색 성분만을 검출<br>
반전시킨 뒤, imerode 함수로 원의 노이즈를 제거 <br>
반전시키는 이유는, 크로마키 천(1)이 드론과 가까워서 평균값을 찾는 것이 불가능할 때 원의 중심을 찾기 위함이다.
imerode로 침식시킨 것은, 모폴로지 연산 중에 close 연산을 구현하여 배경을 '0'으로 만들기 위함이다.
같은 방식으로 원의 중심을 찾는다.
     
<br>
중심으로 이동하는 알고리즘은 다음과 같다.

```matlab
      error_c=cf-targetcenter_full(1); 
             
            if abs(error_c)>margin2_full %양옆 판단, 에러가 특정 margin 밖에 있고 row가 맞춰지지 않았을 때 좀더 널널하게 판단
                if error_c>0
                    disp('right go convergence');
                    moveright(droneobj,'WaitUntilDone',true,'Distance',0.2);
                else
                    disp('left go convergence');
                    moveleft(droneobj,'WaitUntilDone',true,'Distance',0.2);
                end
            end
```
targetcenter_full은 [480 240]으로 정의되어 있다. <br>
찾은 중심값과 드론 전체화면의 중심과 비교하여 이동한다. <br>
이때, 드론의 최소 이동거리 20cm 문제로 중심점을 정확하게 맞추는 것이 어려우므로 margin값을 사용하여 드론이 원의 중심을 찾는 범위를 넓혀 원의 중심을 반복하여 벗어나는 오류를 방지한다.



이때, 안정적으로 중심을 찾는 알고리즘을 적용한다.
즉, 양옆 혹은 위아래 중 하나만 중심을 찾는 것이 아닌, 양옆과 위아래 모두 동시에 중심을 찾을 수 있도록 한다.
```matlab
%%
        if abs(error_r)>margin2_full_ud  %위아래 판단, 에러가 특정 margin 밖에 있고, Col을 맞출 때
            if error_r>0
                disp('down full');
               movedown(droneobj,'WaitUntilDone',true);
            else
                disp('up full');
              moveup(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop up down full');
            UDIn_full=UDIn_full+1;
        end
%%
        if abs(error_c)>margin2_full  %양옆 판단, 에러가 특정 margin 밖에 있고 row가 맞춰지지 않았을 때
            if error_c>0
                disp('right full');
                moveright(droneobj,'WaitUntilDone',true);
            else
                disp('left full');
                moveleft(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop right left full');
            RLIn_full=RLIn_full+1;
        end

%% 파랑생이 꽉 찼을 때 안정적으로 중심을 찾기 위해
% 양옆 혹은 위아래 하나만 중심을 찾았을 때
        if RLIn_full~=UDIn_full
            center_reset=1;
        end
        
        if center_reset==1
            UDIn_full=0;
            RLIn_full=0;
            center_reset=0;
        end
        
        if RLIn_full > 2 && UDIn_full > 2 
            fullgo=1;
            disp('fullgo=1');
        end

```
<br>

```matlab
if (length(row) < 50 || length(col) < 50)

```
중심을 찾았다면, 전진 후 표식의 크기로 종료 지점을 확인하고 3단계로 넘어간다.



### 두 번째: 링과 드론이 멀어서 링의 파란 부분이 화면에 꽉 차지 않을 때

중심을 찾고, 드론을 전진시켜 링과 드론이 가깝게(파란 부분이 화면에 꽉 차게) 만든 뒤, 원의 중심을 찾아 전진하는 알고리즘을 통해서 표식을 인식하고 stage3로 넘어간다.
     
     
## 3단계
* 90도 회전, 전진, 45도 회전한다.<br>
* 크로마키천의 중심으로 이동한다. <br>
* Yaw(각도)를 조절한다. <br>
* stage2의 알고리즘을 사용하여 3단계 표식을 인식후 착지한다. <br>
각도 조절 알고리즘은 다음과 같다.
```matlab
     image = snapshot(cameraObj);

        image1R = image(:,:,1);
        image1G = image(:,:,2);
        image1B = image(:,:,3);

        image_only_B = image1B-image1R/2-image1G/2;
        bw = image_only_B > 55;
        bw_origin = bw;


        stats = regionprops(bw);
        centerIdx=1;

        if(~isempty(stats))
            for i = 1:numel(stats)
                if stats(i).Area>stats(centerIdx).Area
                    centerIdx=i;
                end
            end
            rectangle('Position', stats(centerIdx).BoundingBox, ...
                'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            hold on;

            bw(stats(centerIdx).BoundingBox(2):stats(centerIdx).BoundingBox(2)+stats(centerIdx).BoundingBox(4),stats(centerIdx).BoundingBox(1):stats(centerIdx).BoundingBox(1)+stats(centerIdx).BoundingBox(3))=1;
        end

        [row_bounding, col_bounding] = find(bw);

        cf_B=mean(col_bounding);

        bw_origin1 = imfill(bw_origin,"holes");

        [row_origin, col_origin] = find(bw_origin1);

        cf_O=mean(col_origin);

        correcting_cf = cf_B - cf_O;
        disp('correcting_cf');
        disp(correcting_cf);

        if correcting_cf > 5
            disp("turn left 10");

            turn(droneobj, deg2rad(-10));
            disp(correcting_cf);

            Center_restart = 1;

        elseif correcting_cf > 2
            disp("turn right");

            turn(droneobj, deg2rad(-5));
            disp(correcting_cf);

            Center_restart = 1;
            
        elseif correcting_cf < -5
            disp("turn right");

            turn(droneobj, deg2rad(10));
            disp(correcting_cf);

            Center_restart = 1;

        elseif correcting_cf < -2
            disp("turn right");

            turn(droneobj, deg2rad(5));
            disp(correcting_cf);

            Center_restart = 1;

        else
            disp("correcting yaw")
            Center_restart = 1;
        end

    end
```
![2](https://user-images.githubusercontent.com/103023848/178750551-796b416d-4375-4209-a4c9-096389fc6691.jpg)

크로마키 천에 bounding box를 검출하고 속을 1로 채운 직사각형의 중심을 찾는다.<br>
크로마키 천의 구멍을 imfill 함수를 사용하여 1로 채운 사다리꼴의 중심을 찾는다.<br>
직사각형의 중심을 기준으로 두 중심을 비교하여 드론이 변경해야하는 각도를 판단한다.<br>

* 다시 2단계 알고리즘으로 중앙점 찾고 통과한다.









