목차

1.주행 알고리즘

2.중심원 및 중심점 찾기 알고리즘

3.주행 알고리즘 설계 과정



1.주행알고리즘
------------------------------------------------------------------------------------------
코스에 따른 알고리즘을 크게 보면 다음과 같습니다.
![image](https://user-images.githubusercontent.com/103105656/178724592-aa1250bb-ab51-4872-b4be-5021a8dafbb5.png)


그리고 다음과 같이 코스를 만들어서 연습주행을 하였습니다
![image](https://user-images.githubusercontent.com/103105656/178649621-70f1fab8-8d1e-4228-930e-3f284c48a803.png)

2.중심원 및 중심점 찾기 알고리즘
------------------------------------------------------------------------------------------
처음에 중심원 및 중심점을 찾는 알고리즘에서 imfindcircles을 이용하여서 반지름을 찾고 원의 중심점을 찾으려고 하였습니다.

다만 이함수의 경우 반지름의 최대값의 숫자를 줄이면 속도가 빨라지기는 하였지만 상당히 느렸고 그리고
원이 살짝만 틀어져서 타원이 되면 원을 인식하지 못한다는 문제가 발생하였습니다.

---------------------------------------------------------------------------------------
```
get_frame = snapshot(cam);  %사진찍고

img_frame = rgb2hsv(get_frame);
h = img_frame(:,:,1);
s = img_frame(:,:,2);
v = img_frame(:,:,3);
% img_size = [size(img_frame,1), size(img_frame,2)];  % 이미지 행, 열 길이
img_blue = (h>0.575)&(h<0.75)&(s>0.4)&(v>0.2)&(v<0.9); %파란색인식
    
img_reblue = imcomplement(img_blue); %반전시키기

s = regionprops(img_reblue,'Centroid','Circularity','Area');
```
-------------------------------------------------------------------------------------
따라서 위의 코드와 같이 regionprops함수를 이용하여서 중심점과 중심원을 찾았습니다.

다만 이 경우 원만 인식하는것이 아닌 여러가지 구간이 인식될수있는데 regionprops함수를 통해
나온 구조체의 면적을 확인하고 면적이 400보다 작은 값들은 필요없는 것이라 판단하고 centroid
가 가장 큰값을 원으로 판단하여 사용하였습니다. 그 코드는 아래와 같습니다.

-------------------------------------------------------------------------------------
```
s = regionprops(img_reblue,'Centroid','Circularity','Area');

size_s = size(s,1); %size_s는 구조체 s의 크기

area_matrix = zeros(size_s,1);
circle_matrix = zeros(size_s,1);

for i_s = 1:size_s  % 하나씩 탐색하면서
    area_matrix(i_s) = s(i_s).Area;
    circle_matrix(i_s) = s(i_s).Circularity;
end

erase = area_matrix > 400;
circle = erase .* circle_matrix;
[~,cir_index] = max(circle);   %cir_max 는 Circularity 최댓값, cir_index는 최댓값의 인덱스

s_cir = s(cir_index);
```
-------------------------------------------------------------------------------------

3.주행 알고리즘 설계 과정
-------------------------------------------------------------------------------------

가장 처음에는 regionprops함수를 이용하여서 원의 지름을 구한 후 지름에 따른 떨어진 거리를
계산하여서 한번에 진행하려고 하였습니다. 다만 이 경우 지름과 관련해서 정확한 거리를 계산하는
방정식을 만드는 것이 상당히 힘들었고 똑바로 가라는 명령에도 똑바로 가지못하는 경우가 많아서
여러번 나눠서 가기로 결정하였습니다.

그래서 처음에는 원의 중심을 따라가다가 원형성이 0.85보다 낮아지면 사각형의 중심을 찾아서 움직이게 하였습니다. 그리고 사각형의 면적이 특정면적을 넘어가면 각도조정이나 착륙코드가 작동하게 설계하였습니다.

-------------------------------------------------------------------------------------
```
while(s_1.Circularity >= 0.85)   % 0.85 될때까지 앞으로 전진
    
    [frame_1_original, frame_1, s_1] = get_radian(acecam);
    track_circle1(ace, frame_1, s_1.Centroid);


    pause(0.05);
end



[~, s_1_red] = get_red(acecam);

while(s_1_red.Area < 2800)   % 빨강 앞 적당한 거리까지 전진
    [frame_1_red, s_1_red] = get_red(acecam);
    track_red(ace, frame_1_red, s_1_red.Centroid);
    pause(0.05);
end
```
-------------------------------------------------------------------------------------

다만 위의 코드와 같이 하였을때 아래와 같은 경우나 원이 살짝 찌그러지게 찍혀서 원의 선형성이 0.85보다 적게 측정되는 경우가 많았기 때문에 선형성을 0.5로 수정하여서 주행하였습니다. 선형성을 0.5로 수정하여도 결국 원이 가장 크게 선형성이 인식되기 때문에 큰문제는 없었습니다. 이렇게 수정하여도 여러번 나눠서 가기에 속도가 떨어져서 나눠지는 횟수를 줄이고자 원통과직전에 사각형의 면적에 따른 거리를 계산하여서 한번에 가게 코드를 수정하였습니다.
![image](https://user-images.githubusercontent.com/103105656/178669347-01954dd0-bb19-41cc-a37a-66f3fe29a507.png)

-------------------------------------------------------------------------------------
```
% 1단계 / 원 통과 직전
if (most_red.Area < 807) % 빨간색으로부터 거리가 1.15 ~ 1.25m 인 경우
    moveforward(ace, 'Distance', 0.7, 'Speed', 1) % 앞으로 0.7m 이동
elseif (most_red.Area < 1020) % 빨간색으로부터 거리가 1.05 ~ 1.15m 인 경우
    moveforward(ace, 'Distance', 0.6, 'Speed', 1) % 앞으로 0.6m 이동
elseif (most_red.Area < 1268) % 빨간색으로부터 거리가 0.95 ~ 1.05m 인 경우
    moveforward(ace, 'Distance', 0.5, 'Speed', 1) % 앞으로 0.5m 이동
elseif (most_red.Area < 1648) % 빨간색으로부터 거리가 0.85 ~ 0.95m 인 경우
    moveforward(ace, 'Distance', 0.4, 'Speed', 1) % 앞으로 0.4m 이동
elseif (most_red.Area < 2173) % 빨간색으로부터 거리가 0.75 ~ 0.85m 인 경우
    moveforward(ace, 'Distance', 0.3, 'Speed', 1) % 앞으로 0.3m 이동
elseif (most_red.Area < 2500) % 빨간색으로부터 거리가 0.65 ~ 0.75m 인 경우
    moveforward(ace, 'Distance', 0.2, 'Speed', 1) % 앞으로 0.2m 이동
end
```
-------------------------------------------------------------------------------------

그리고 두번째 원과 세번째원의 경우 각도가 바뀐후에 원이 바로 인식되는 경우와 원이 바로 인식되지 않는 경우를 나눠서 코드를 작성하였습니다.

원이 바로인식된 경우 좌우를 원의 중심에 맞출경우 옆에 원에 부딫칠 가능성이 있기때문에 옆에 원이 부딫치지 않을 정도로 드론을 앞으로 직진시킨후 원이 보인다면 원의 중심을 따라서 원이 보이지 않는다면 드론의 화면 양 끝 오른쪽에만 파란색이 인식된다면 오른쪽으로 왼쪽에만 파란색이 인식된다면 쪽으로 가게 코드를 작성하여서 원을 찾게 하였습니다. 위와 아래도 마찬가지로 코드를 작성하였습니다.

-------------------------------------------------------------------------------------
```
function [] = blue_line_LR(ace,frame_2_original)  %오른쪽 왼쪽 파랑색 선따라서 이동
 left = any(frame_2_original(:,1));
 right = any(frame_2_original(:,960));

    if (xor(left,right)==0)  % 움직일 필요 없는 경우
    
    elseif (left == 1)  % 왼쪽으로 움직여야할때
   moveleft(ace,'Distance',0.2);
    elseif (right == 1) % 오른쪽으로 움직여야 할때
    moveright(ace,'Distance',0.2);
    end

end

function[] = blue_line_UD(ace,frame_2_original) %아래쪽 위쪽 파랑색 선따라서 이동

 top = any(frame_2_original(1,:));
 bottom = any(frame_2_original(720,:));
 left = any(frame_2_original(:,1));
 right = any(frame_2_original(:,960));
 if (xor(top,bottom)==0)  % 움직일 필요 없는 경우
    
    elseif (top == 1)  % 위쪽으로 움직여야할때
    moveup(ace,'Distance',0.2);
     elseif (bottom ==1)  % 아래쪽으로 움직여야 할때
    movedown(ace,'Distance',0.2);     
 end

if (xor(top,bottom)==0&&xor(left,right)==0)
    moveforward(ace, 'Distance', 0.2);
end

end
```
-------------------------------------------------------------------------------------

그다음에는 원의 선형성이 높을때까지는 원의 중심을 따라 이동하다가 이후 사각형면적을 통해서 원을 통과합니다. 원이 바로 인식되지 않은경우에는 드론이 직진하지 않고 위로올라가서 원을 탐색하여 원을 가운데에 둔 이후에 앞으로 간후 원이 바로 인식된 경우와 마찬가지로 원을 통과합니다.

세번째원의 경우에도 두번째원과 마찬가지로 이동하지만 마지막에 보라색을 인식하고 움직일때 보라색이 사라진다면 각도를 조정하여서 보라색을 추가적으로 찾게 코딩하였습니다.

-------------------------------------------------------------------------------------
```
if(purple_sum<2) %보라색이 각도 때문에 안보이면
                        while(purple_sum>15)
                        turn(ace,deg2rad(5));%140도
                        pause(0.05);
                        [frame_2_purple, s_2_purple,purple_sum] = get_purple(acecam);
                        turn(ace,deg2rad(5));%145도
                        pause(0.05);
                        [frame_2_purple, s_2_purple,purple_sum] = get_purple(acecam);
                        turn(ace,deg2rad(5));%150도
                        pause(0.05);
                        [frame_2_purple, s_2_purple,purple_sum] = get_purple(acecam);
                        turn(ace,deg2rad(-20));%130도
                        pause(0.05);
                        [frame_2_purple, s_2_purple,purple_sum] = get_purple(acecam);
                        turn(ace,deg2rad(-5));%125도
                        pause(0.05);
                        [frame_2_purple, s_2_purple,purple_sum] = get_purple(acecam);
                        turn(ace,deg2rad(-5));%120도
                        pause(0.05);
                        [frame_2_purple, s_2_purple,purple_sum] = get_purple(acecam);
                        end
```                        
-------------------------------------------------------------------------------------


요약하자면, 최종적인 코드는 첫번째원의 경우 원의 중심을 찾아가다가 원의 선형성이 낮아지면 빨간색의 면적을 바탕으로 한번에 빨강색앞으로 이동하여서 시간을 단축시킵니다. 그리고 두번째 세번쨰원의 경우 회전후 바로 원이 보이는지 보이지 않는지 확인한 후 원이 보이면 앞으로 보이지 않으면 위로 올라가서 원을 탐색하고  원의 중심을 따라가다가 원의 선형성이 작아지면 사각형의 면적을 통해 원을 통과합니다.
