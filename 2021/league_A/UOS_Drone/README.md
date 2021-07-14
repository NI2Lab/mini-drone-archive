# 대회 진행 전략
#### 1. 영상처리

>1-1. HSV 색공간 사용
>>색상 값 만을 나타내는 RGB 색공간과는 달리 HSV 색공간은 색상(Hue) 뿐만 아니라 채도(Saturation) 및 명도(Value)의 값도 추가로 설정해줄 수 있어 이미지의 조명 변화에 더 유연하게 대처 가능하므로 HSV 색공간을 사용함
>>
<img src="https://user-images.githubusercontent.com/63180713/125638009-74b234cb-7a93-454b-9616-a296bf4dbadb.png" width="480" height="360">
<img src="https://user-images.githubusercontent.com/63180713/125638021-102dc7da-0a28-4a05-875a-f615513cfe3f.png" width="480" height="360">

>1-2. 모폴로지 닫힌 연산 사용
>>팽창 후 침식 연산을 진행하는 모폴로지 닫힌 연산을 사용하여 구멍의 이진 이미지로부터 작은 값의 픽셀을 갖는 노이즈를 제거하여 보다 매끄러운 영상을 추출해 냄.
<img src="https://user-images.githubusercontent.com/63180713/125638101-db5b29df-ef8c-42a9-a049-b023d6c02825.png" width="480" height="360"> 
<img src="https://user-images.githubusercontent.com/63180713/125638109-f9459d48-2dea-44fd-9551-25e273e11035.png" width="480" height="360"> 

>1-3. 원형률 속성 사용
>>매트랩의 regionprops() 함수를 사용하여 이진 이미지로부터 영역들을 추출해낸 후, 구멍이 원의 형태라는 것을 이용해 원형률 속성값을 계산하여 추출된 많은 영역들 중 가장 적합한 구멍을 찾아냄. 또한 추가적으로 해당 함수를 통해 구멍과 표식 영역에 대해 넓이와 중심점과 같은 속성값을 추출해 냄.

#### 2. 제어

>2-1. 단계별 3가지 미션
>드론의 자율 비행을 보다 쉽게 하기 위해 단계 내의 3가지 미션을 다음과 같이 정의함.
>>
>>mission 1 : 구멍 영역의 중심 좌표를 추출하여 접근하도록 드론 제어
>>
>>mission 2 : 표식 영역의 넓이가 300 픽셀이 넘어가면 구멍 영역의 중심 좌표 대신 표식 영역의 중심 좌표를 추출하여 구멍을 통과하도록 드론 제어
>>
>>mission 3 : 구멍 통과 후 표식 영역의 넓이가 3000 픽셀이 넘어가면 다음 단계로 넘어가도록 드론 제어

>2-2. move() 함수 사용
>>기존의 movefoward(), moveright() 등 정해진 방향으로 제어하는 함수를 이용하게 되면 제어 가능한 최소 거리가 0.2m이기 때문에 세밀한 제어가 불가능하다고 판단함. 따라서 드론 기준의 상대 좌표로 제어하는 함수인 move() 함수를 사용하여 비교적 세밀한 제어가 필요한 드론의 좌우 방향 제어에 대해 0.1m의 값으로 정교한 제어를 진행함(move() 함수의 경우 이동시킬 좌표 [x y z] 값 중 하나만 0.2가 넘으면 제어가 가능함).

>2-3. 탐색 알고리즘
>>드론의 자율주행에서 호버링에 의해 발생되는 불안정한 비행 현상이 발생할 경우 추적하던 구멍 또는 표식을 잃어버리게 되므로 달팽이 모양으로 비행하는 추가적인 탐색 알고리즘을 통해 다시 재추적 할 수 있게 제어함. 구멍을 잃을 때와 표식을 잃을 때의 경우를 분리하여 탐색하는 범위를 더 효율적으로 선택했고, 드론의 높이 정보를 가져와 최소 및 최대 범위의 높이를 초과하여 비행하지 않도록 제한함.

# 알고리즘 설명

#### 0. 알고리즘 순서도

<img src="https://user-images.githubusercontent.com/63180713/125631786-72bd5c3b-06dc-425e-a6eb-3e054c58e4dc.png" width="720" height="480">

#### 1. 드론의 카메라에서 촬영되는 영상의 frame 저장

>드론의 전면 카메라에서 촬영한 영상에서 frame을 이미지로 가져옴.
          frame=snapshot(cameraObj);
<img src="https://user-images.githubusercontent.com/82210800/125578764-57107b42-a223-42cb-accd-a2f8b51734aa.PNG" width="480" height="360">
      
#### 2. frame을 RGB 색공간에서 HSV 색공간으로 변환   

>이미지 frame을 hsv_img로 변환
          hsv_img=rgb2hsv(frame);
          h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);
          
#### 3. HSV 색공간에서 구멍 및 표식의 이진 이미지 가져오기     

>3-1. 구멍
>>파란색의 영역만 추출함
          mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
<img src="https://user-images.githubusercontent.com/82210800/125580245-66703a2e-487b-479b-add8-3d4b56c86b81.png" width="480" height="360"> 

>>구멍을 객체화하기 위해 반전 및 모폴로지 닫기 연산을 통해 노이즈 제거
          hole=imcomplement(mask);
          se=strel('disk',10);
          hole=imclose(hole,se);                  
<img src="https://user-images.githubusercontent.com/82210800/125580684-02ac2838-17cc-42df-9670-160365b91f11.png" width="480" height="360"> 

>3-2. 표식
>>빨간색 또는 보라색 영역만 추출함
          rect=((0.95<h)|(h<0.05))&(0.4<s)&(s<=1); //RED
          rect=(0.7<h)&(h<0.8)&(0.2<s)&(s<=0.8);  //Purple
          (사진 추가)
          
#### 4. 구멍 및 표식의 이진 이미지로부터 영역 설정

>4-1. 구멍
>>구멍의 이진 이미지로부터 영역을 찾고 넓이, 중심점, 원형률 속성 추출 및 노이즈 제거
>>
          stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
          A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.8);
          stats_h(A,:) = [];
          
>4-2. 표식
>>표식의 이진 이미지로부터 영역을 찾고 넓이, 중심점= 속성 추출 및 노이즈 제거
>>
          stats_r=regionprops('table', rect, 'Area', 'Centroid');
          B=find(stats_r.Area <= 300);
          stats_r(B,:) = [];
          
#### 5. 영역으로부터 구멍 및 표식 판단 후 중심 좌표 추출

>5-1. 구멍
>>남은 영역들 중 원형률이 가장 큰 영역을 구멍으로 판단, 중심 좌표 추출
>>
          [~,Ih]=max(stats_h.Circularity);
          cx_h=round(stats_h.Centroid(Ih,1)); cy_h=round(stats_h.Centroid(Ih,2));
          
>5-1. 표식
>>남은 영역들 중 넓이가 가장 큰 영역을 표식으로 판단, 중심 좌표 추출
>>
          [~,Ir]=max(stats_r.Area);
          x_r=round(stats_r.Centroid(Ir,1)); cy_r=round(stats_r.Centroid(Ir,2));
          
<img src="https://user-images.githubusercontent.com/63180713/125638426-d5a2728d-43ab-4778-ac2a-2bb28ddea319.png" width="480" height="360"> 
<img src="https://user-images.githubusercontent.com/63180713/125638464-0d9cf0da-dfda-4149-8bd3-e5c2f43b5dec.png" width="480" height="360"> 

#### 6. 각 단계(step)마다 3가지 미션(mission) 수행

>6-1. 1단계
>>mission1 : 출발점으로부터 구멍 영역을 추적
>>mission2 : 표식의 넓이가 300 픽셀 초과일 때, 구멍 통과
>>mission3 : 표식의 넓이가 3000 픽셀 이상일 때, 드론 회전 후 단계 종료

>6-2. 2단계
>>mission1 : 1단계 종료 지점으로부터 2단계 구멍 영역을 추적
>>mission2 : 표식의 넓이가 300 픽셀 초과일 때, 구멍 통과
>>mission3 : 표식의 넓이가 3000 픽셀 이상일 때, 드론 회전 후 단계 종료
          
>6-3. 3단계
>>mission1 : 2단계 종료 지점으로부터 3단계 구멍 영역을 추적
>>mission2 : 표식의 넓이가 300 픽셀 초과일 때, 구멍 통과
>>mission3 : 표식의 넓이가 3000 픽셀 이상일 때, 드론 착륙
                    
#### 7. 구멍과 표식을 잃었을 때의 탐색 알고리즘

>드론의 높이 정보를 가져와 최소-최대 구간을 설정 후 달팽이 모양으로 드론을 이동시키며 원하는 표적 추적
>
          [height,~]=readHeight(droneObj)
          switch search
                    case 1
                      moveup(droneObj,'Distance', 0.3*up);
                      pause(0.1);
                      if height+0.3*up<1.7
                          up=up+2;
                      end
                      search=2;
                      continue;
                    case 2
                      moveright(droneObj,'Distance', 0.8*right);
                      pause(0.1);
                      right=right+2;
                      search=3;
                      continue;
                    case 3
                      movedown(droneObj,'Distance', 0.3*down);
                      pause(0.1);
                      if height-0.3*down>0.3
                          down=down+2;
                      end
                      search=4;
                      continue;
                    case 4
                      moveleft(droneObj,'Distance', 0.8*left);
                      pause(0.1);
                      left=left+2;
                      search=1;
                      continue;
          end

# 소스 코드 설명

#### 1. 변수 및 객체 선언, 이륙
          function main
              diff=0;                 % 구멍 또는 표식의 허용 범위
              x=0; y=0;               % 구멍 또는 표식의 기준 좌표
              cx_h=0; cy_h=0;         % 구멍의 픽셀 좌표
              cx_r=0; cy_r=0;         % 표식의 픽셀 좌표

              step=1; mission=1;         % 단계 및 미션 절차를 나타내는 변수(step : 1-3 단계, mission : 1-3 미션)
              search=1; up=1; right=1; down=2; left=2;    % 구멍 또는 표식을 찾는 탐색 알고리즘 변수

              droneObj=ryze();        % 드론 객체 선언
              cameraObj=camera(droneObj); % 카메라 객체 선언

              takeoff(droneObj);      % 이륙
              pause(0.1);

              while 1
                  switch step
#### 2. 1단계
                     %% 1단계
                      case 1
                          % 프레임을 가져와 RGB 색공간을 HSV 색공간으로 변환
                          frame=snapshot(cameraObj);
                          hsv_img=rgb2hsv(frame);
                          h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);

                          % 특정 범위를 설정하여 파란색 천과 빨간색 표식을 이진화
                          mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
                          hole=imcomplement(mask);
                          se=strel('disk',10);        % 노이즈 제거를 위해 모폴로지 닫기 연산 수행
                          hole=imclose(hole,se);

                          rect=((0.95<h)|(h<0.05))&(0.4<s)&(s<=1)&(0.3<v)&(v<=1);

                          % 구멍의 이진 이미지를 영역으로 분할하여 넓이, 중심점, 원형률 속성을 구함
                          % 구멍이 원인 성질을 이용하여 영역의 넓이가 작거나 원형률이 작은 영역을 제거함
                          stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                          A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.8);
                          stats_h(A,:) = [];

                          % 표식의 이진 이미지를 영역으로 분할하여 넓이, 중심점 속성을 구함
                          % 영역의 넓이가 작은 영역을 제거함
                          stats_r=regionprops('table', rect, 'Area', 'Centroid');
                          B=find(stats_r.Area <= 300);
                          stats_r(B,:) = [];

                          % 구멍의 이진 이미지 내 영역이 존재하고 미션 1일 때
                          if size(stats_h, 1)>0 && mission==1
                              % 원형률이 가장 큰 영역을 구멍으로 판단하고 중심 좌표를 가져옴
                              [~,Ih]=max(stats_h.Circularity);
                              cx_h=round(stats_h.Centroid(Ih,1)); cy_h=round(stats_h.Centroid(Ih,2));
                              search=1;
                          else
                              % 미션 1에서 구멍의 이진 이미지 내 영역을 찾지 못했을 경우 탐색하는 알고리즘
                              if mission==1
                                  if search==1
                                      [height,~]=readHeight(droneObj)
                                  end
                                  switch search
                                      case 1
                                          moveup(droneObj,'Distance', 0.5*up);
                                          pause(0.1);
                                          if height+0.3*up<1.7
                                              up=up+2;
                                          end
                                          search=2;
                                          continue;
                                      case 2
                                          moveright(droneObj,'Distance', 0.5*right);
                                          pause(0.1);
                                          right=right+2;
                                          search=3;
                                          continue;
                                      case 3
                                          movedown(droneObj,'Distance', 0.5*down);
                                          pause(0.1);
                                          if height-0.3*down>0.3
                                              down=down+2;
                                          end
                                          search=4;
                                          continue;
                                      case 4
                                          moveleft(droneObj,'Distance', 0.5*left);
                                          pause(0.1);
                                          left=left+2;
                                          search=1;
                                          continue;
                                  end
                              end
                          end

                          % 표식의 이진 이미지에서 영역이 존재할 경우
                          if size(stats_r, 1)>0
                              % 영역의 넓이가 가장 넓은 영역을 표식으로 판단하고 중심 좌표를 가져옴
                              [~,Ir]=max(stats_r.Area);
                              cx_r=round(stats_r.Centroid(Ir,1)); cy_r=round(stats_r.Centroid(Ir,2));
                              search=1;
                              % 미션 1에서 표식 영역의 넓이가 300~3000 사이일 때 미션 2로 전환
                              if mission==1 && 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                                  mission=2;

                              % 미션 2 또는 3에서 표식 영역의 넓이가 3000 이상일 때, 2단계로 넘어감
                              elseif mission>1 && stats_r.Area(Ir)>=3000
                                  turn(droneObj, deg2rad(-90));
                                  pause(0.1);
                                  moveforward(droneObj,'Distance', 1.1, 'speed', 1);
                                  step=step+1;
                                  mission=1;
                                  continue;
                              end

                          % 미션 2 또는 3에서 표식의 이진 이미지 내에서 영역을 찾지 못했을 경우 탐색하는 알고리즘
                          elseif mission>1
                              if search==1
                                  [height,~]=readHeight(droneObj)
                              end
                              switch search
                                  case 1
                                      moveup(droneObj,'Distance', 0.3*up);
                                      pause(0.1);
                                      if height+0.3*up<1.7
                                          up=up+2;
                                      end
                                      search=2;
                                      continue;
                                  case 2
                                      moveright(droneObj,'Distance', 0.3*right);
                                      pause(0.1);
                                      right=right+2;
                                      search=3;
                                      continue;
                                  case 3
                                      movedown(droneObj,'Distance', 0.3*down);
                                      pause(0.1);
                                      if height-0.3*down>0.3
                                          down=down+2;
                                      end
                                      search=4;
                                      continue;
                                  case 4
                                      moveleft(droneObj,'Distance', 0.3*left);
                                      pause(0.1);
                                      left=left+2;
                                      search=1;
                                      continue;
                              end
                          end

                          % 미션 1에서 찾은 영역이 존재하면 구멍의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                          if mission==1 && size(stats_h, 1)>0
                              cx=cx_h; cy=cy_h;
                              x=480; y=225;
                              diff=20;
                              disp("hole");
                          % 미션 2 또는 3에서 찾은 영역이 존재하면 표식의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                          elseif mission>1 && size(stats_r, 1)>0
                              cx=cx_r; cy=cy_r;
                              x=480; y=190;
                              diff=15;
                              stats_r.Area(Ir)
                              disp("rect");
                          else
                          % 아무런 영역도 존재하지 않을 때 예외 처리
                              cx=-1; cy=-1;
                          end

                          if cx>=0 && cy>=0
                              % 기준 좌표가 존재할 때 기준 좌표와 픽셀 좌표가 벗어난 방향으로 드론을 제어
                              dx=0; dy=cx-x; dz=cy-y;
                              if dy>diff && dz>diff
                                  dy=0.1; dz=0.2;
                              elseif dy>diff && dz<-diff
                                  dy=0.1; dz=-0.2;
                              elseif dy<-diff && dz>diff
                                  dy=-0.1; dz=0.2;
                              elseif dy<-diff && dz<-diff
                                  dy=-0.1; dz=-0.2;
                              else
                                  % 기준 좌표와 픽셀 좌표가 허용 범위 내에 존재할 때
                                  % 미션 1의 경우 조금씩 앞으로 제어
                                  if mission==1
                                      dx=0.3; dy=0; dz=0.1;
                                  % 미션 2의 경우 구멍을 통과하고 미션 3으로 전환
                                  elseif mission==2
                                      pause(0.2);
                                      moveforward(droneObj,'Distance', 1.2, 'speed', 1);
                                      mission=3;
                                      continue;
                                  % 미션 3의 경우 조금씩 앞으로 제어
                                  else
                                      dx=0.2; dy=0; dz=0.1;
                                  end
                              end
                              move(droneObj,[dx dy dz]);
                              pause(0.1);
                          end

                          % 프레임, 구멍, 표식 영상 및 중 좌표 표시
                          subplot(2,2,1)
                          imshow(frame)

                          subplot(2,2,2)
                          imshow(hole)
                          hold on
                          if size(stats_h, 1)>0
                              plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                          end
                          hold off

                          subplot(2,2,3)
                          imshow(rect)
                          hold on
                          if size(stats_r, 1)>0
                              plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                          end
                          hold off

#### 3. 2단계
                     %% 2단계
                      case 2
                          % 프레임을 가져와 RGB 색공간을 HSV 색공간으로 변환
                          frame=snapshot(cameraObj);
                          hsv_img=rgb2hsv(frame);
                          h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);

                          % 특정 범위를 설정하여 파란색 천과 빨간색 표식을 이진화
                          mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
                          hole=imcomplement(mask);
                          se=strel('disk',10);        % 노이즈 제거를 위해 모폴로지 닫기 연산 수행
                          hole=imclose(hole,se);

                          rect=((0.95<h)|(h<0.05))&(0.4<s)&(s<=1)&(0.3<v)&(v<=1);

                          % 구멍의 이진 이미지를 영역으로 분할하여 넓이, 중심점, 원형률 속성을 구함
                          % 구멍이 원인 성질을 이용하여 영역의 넓이가 작거나 원형률이 작은 영역을 제거함
                          stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                          A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.8);
                          stats_h(A,:) = [];

                          % 표식의 이진 이미지를 영역으로 분할하여 넓이, 중심점 속성을 구함
                          % 영역의 넓이가 작은 영역을 제거함
                          stats_r=regionprops('table', rect, 'Area', 'Centroid');
                          B=find(stats_r.Area <= 300);
                          stats_r(B,:) = [];

                          % 구멍의 이진 이미지 내 영역이 존재하고 미션 1일 때
                          if size(stats_h, 1)>0 && mission==1
                              % 원형률이 가장 큰 영역을 구멍으로 판단하고 중심 좌표를 가져옴
                              [~,Ih]=max(stats_h.Circularity);
                              cx_h=round(stats_h.Centroid(Ih,1)); cy_h=round(stats_h.Centroid(Ih,2));
                              search=1;
                          else
                              % 미션 1에서 구멍의 이진 이미지 내 영역을 찾지 못했을 경우 탐색하는 알고리즘
                              if mission==1
                                  if search==1
                                      [height,~]=readHeight(droneObj)
                                  end
                                  switch search
                                      case 1
                                          moveup(droneObj,'Distance', 0.3*up);
                                          pause(0.1);
                                          if height+0.3*up<1.7
                                              up=up+2;
                                          end
                                          search=2;
                                          continue;
                                      case 2
                                          moveright(droneObj,'Distance', 0.8*right);
                                          pause(0.1);
                                          right=right+2;
                                          search=3;
                                          continue;
                                      case 3
                                          movedown(droneObj,'Distance', 0.3*down);
                                          pause(0.1);
                                          if height-0.3*down>0.3
                                              down=down+2;
                                          end
                                          search=4;
                                          continue;
                                      case 4
                                          moveleft(droneObj,'Distance', 0.8*left);
                                          pause(0.1);
                                          left=left+2;
                                          search=1;
                                          continue;
                                  end
                              end
                          end

                          % 표식의 이진 이미지에서 영역이 존재할 경우
                          if size(stats_r, 1)>0
                              % 영역의 넓이가 가장 넓은 영역을 표식으로 판단하고 중심 좌표를 가져옴
                              [~,Ir]=max(stats_r.Area);
                              cx_r=round(stats_r.Centroid(Ir,1)); cy_r=round(stats_r.Centroid(Ir,2));
                              search=1;
                              % 미션 1에서 표식 영역의 넓이가 300~3000 사이일 때 미션 2로 전환
                              if mission==1 && 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                                  mission=2;

                              % 미션 2 또는 3에서 표식 영역의 넓이가 3000 이상일 때, 3단계로 넘어감
                              elseif mission>1 && stats_r.Area(Ir)>=3000
                                  turn(droneObj, deg2rad(-90));
                                  pause(0.1);
                                  moveforward(droneObj,'Distance', 1.1, 'speed', 1);
                                  step=step+1;
                                  mission=1;
                                  continue;
                              end

                          % 미션 2 또는 3에서 표식의 이진 이미지 내에서 영역을 찾지 못했을 경우 탐색하는 알고리즘
                          elseif mission>1
                              if search==1
                                  [height,~]=readHeight(droneObj)
                              end
                              switch search
                                  case 1
                                      moveup(droneObj,'Distance', 0.3*up);
                                      pause(0.1);
                                      if height+0.3*up<1.7
                                          up=up+2;
                                      end
                                      search=2;
                                      continue;
                                  case 2
                                      moveright(droneObj,'Distance', 0.3*right);
                                      pause(0.1);
                                      right=right+2;
                                      search=3;
                                      continue;
                                  case 3
                                      movedown(droneObj,'Distance', 0.3*down);
                                      pause(0.1);
                                      if height-0.3*down>0.3
                                          down=down+2;
                                      end
                                      search=4;
                                      continue;
                                  case 4
                                      moveleft(droneObj,'Distance', 0.3*left);
                                      pause(0.1);
                                      left=left+2;
                                      search=1;
                                      continue;
                              end
                          end

                          % 미션 1에서 찾은 영역이 존재하면 구멍의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                          if mission==1 && size(stats_h, 1)>0
                              cx=cx_h; cy=cy_h;
                              x=480; y=225;
                              diff=15;
                              disp("hole");
                          % 미션 2 또는 3에서 찾은 영역이 존재하면 표식의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                          elseif mission>1 && size(stats_r, 1)>0
                              cx=cx_r; cy=cy_r;
                              x=480; y=190;
                              diff=10;
                              stats_r.Area(Ir)
                              disp("rect");
                          else
                          % 아무런 영역도 존재하지 않을 때 예외 처리
                              cx=-1; cy=-1;
                          end

                          if cx>=0 && cy>=0
                              % 기준 좌표가 존재할 때 기준 좌표와 픽셀 좌표가 벗어난 방향으로 드론을 제어
                              dx=0; dy=cx-x; dz=cy-y;
                              if dy>diff && dz>diff
                                  dy=0.1; dz=0.2;
                              elseif dy>diff && dz<-diff
                                  dy=0.1; dz=-0.2;
                              elseif dy<-diff && dz>diff
                                  dy=-0.1; dz=0.2;
                              elseif dy<-diff && dz<-diff
                                  dy=-0.1; dz=-0.2;
                              else
                                  % 기준 좌표와 픽셀 좌표가 허용 범위 내에 존재할 때
                                  % 미션 1의 경우 조금씩 앞으로 제어
                                  if mission==1
                                      dx=0.3; dy=0; dz=0.1;
                                  % 미션 2의 경우 구멍을 통과하고 미션 3으로 전환
                                  elseif mission==2
                                      pause(0.2);
                                      moveforward(droneObj,'Distance', 1.2, 'speed', 1);
                                      mission=3;
                                      continue;
                                  % 미션 3의 경우 조금씩 앞으로 제어
                                  else
                                      dx=0.2; dy=0; dz=0.1;
                                  end
                              end
                              move(droneObj,[dx dy dz]);
                              pause(0.1);
                          end

                          % 프레임, 구멍, 표식 영상 및 중 좌표 표시
                          subplot(2,2,1)
                          imshow(frame)

                          subplot(2,2,2)
                          imshow(hole)
                          hold on
                          if size(stats_h, 1)>0
                              plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                          end
                          hold off

                          subplot(2,2,3)
                          imshow(rect)
                          hold on
                          if size(stats_r, 1)>0
                              plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                          end
                          hold off

#### 4. 3단계
                     %% 3단계
                      case 3
                          % 프레임을 가져와 RGB 색공간을 HSV 색공간으로 변환
                          frame=snapshot(cameraObj);
                          hsv_img=rgb2hsv(frame);
                          h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);

                          % 특정 범위를 설정하여 파란색 천과 보라색 표식을 이진화
                          mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
                          hole=imcomplement(mask);
                          se=strel('disk',10);        % 노이즈 제거를 위해 모폴로지 닫기 연산 수행
                          hole=imclose(hole,se);

                          rect=(0.7<h)&(h<0.8)&(0.2<s)&(s<=0.8)&(0.2<v)&(v<=1);

                          % 구멍의 이진 이미지를 영역으로 분할하여 넓이, 중심점, 원형률 속성을 구함
                          % 구멍이 원인 성질을 이용하여 영역의 넓이가 작거나 원형률이 작은 영역을 제거함
                          stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                          A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.8);
                          stats_h(A,:) = [];

                          % 표식의 이진 이미지를 영역으로 분할하여 넓이, 중심점 속성을 구함
                          % 영역의 넓이가 작은 영역을 제거함
                          stats_r=regionprops('table', rect, 'Area', 'Centroid');
                          B=find(stats_r.Area <= 300);
                          stats_r(B,:) = [];

                          % 구멍의 이진 이미지 내 영역이 존재하고 미션 1일 때
                          if size(stats_h, 1)>0 && mission==1
                              % 원형률이 가장 큰 영역을 구멍으로 판단하고 중심 좌표를 가져옴
                              [~,Ih]=max(stats_h.Circularity);
                              cx_h=round(stats_h.Centroid(Ih,1)); cy_h=round(stats_h.Centroid(Ih,2));
                              search=1;
                          else
                              % 미션 1에서 구멍의 이진 이미지 내 영역을 찾지 못했을 경우 탐색하는 알고리즘
                              if mission==1
                                  if search==1
                                      [height,~]=readHeight(droneObj)
                                  end
                                  switch search
                                      case 1
                                          moveup(droneObj,'Distance', 0.3*up);
                                          pause(0.1);
                                          if height+0.3*up<1.7
                                              up=up+2;
                                          end
                                          search=2;
                                          continue;
                                      case 2
                                          moveright(droneObj,'Distance', 0.8*right);
                                          pause(0.1);
                                          right=right+2;
                                          search=3;
                                          continue;
                                      case 3
                                          movedown(droneObj,'Distance', 0.3*down);
                                          pause(0.1);
                                          if height-0.3*down>0.3
                                              down=down+2;
                                          end
                                          search=4;
                                          continue;
                                      case 4
                                          moveleft(droneObj,'Distance', 0.8*left);
                                          pause(0.1);
                                          left=left+2;
                                          search=1;
                                          continue;
                                  end
                              end
                          end

                          % 표식의 이진 이미지에서 영역이 존재할 경우
                          if size(stats_r, 1)>0
                              % 영역의 넓이가 가장 넓은 영역을 표식으로 판단하고 중심 좌표를 가져옴
                              [~,Ir]=max(stats_r.Area);
                              cx_r=round(stats_r.Centroid(Ir,1)); cy_r=round(stats_r.Centroid(Ir,2));
                              search=1;
                              % 미션 1에서 표식 영역의 넓이가 300~3000 사이일 때 미션 2로 전환
                              if mission==1 && 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                                  mission=2;

                              % 미션 2 또는 3에서 표식 영역의 넓이가 3000 이상일 때, 전체 루프를 빠져나감
                              elseif mission>1 && stats_r.Area(Ir)>=3000
                                  break
                              end

                          % 미션 2 또는 3에서 표식의 이진 이미지 내에서 영역을 찾지 못했을 경우 탐색하는 알고리즘
                          elseif mission>1
                              if search==1
                                  [height,~]=readHeight(droneObj)
                              end
                              switch search
                                  case 1
                                      moveup(droneObj,'Distance', 0.3*up);
                                      pause(0.1);
                                      if height+0.3*up<1.7
                                          up=up+2;
                                      end
                                      search=2;
                                      continue;
                                  case 2
                                      moveright(droneObj,'Distance', 0.3*right);
                                      pause(0.1);
                                      right=right+2;
                                      search=3;
                                      continue;
                                  case 3
                                      movedown(droneObj,'Distance', 0.3*down);
                                      pause(0.1);
                                      if height-0.3*down>0.3
                                          down=down+2;
                                      end
                                      search=4;
                                      continue;
                                  case 4
                                      moveleft(droneObj,'Distance', 0.3*left);
                                      pause(0.1);
                                      left=left+2;
                                      search=1;
                                      continue;
                              end
                          end

                          % 미션 1에서 찾은 영역이 존재하면 구멍의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                          if mission==1 && size(stats_h, 1)>0
                              cx=cx_h; cy=cy_h;
                              x=480; y=225;
                              diff=15;
                              disp("hole");
                          % 미션 2 또는 3에서 찾은 영역이 존재하면 표식의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                          elseif mission>1 && size(stats_r, 1)>0
                              cx=cx_r; cy=cy_r;
                              x=480; y=190;
                              diff=10;
                              stats_r.Area(Ir)
                              disp("rect");
                          else
                          % 아무런 영역도 존재하지 않을 때 예외 처리
                              cx=-1; cy=-1;
                          end

                          if cx>=0 && cy>=0
                              % 기준 좌표가 존재할 때 기준 좌표와 픽셀 좌표가 벗어난 방향으로 드론을 제어
                              dx=0; dy=cx-x; dz=cy-y;
                              if dy>diff && dz>diff
                                  dy=0.1; dz=0.2;
                              elseif dy>diff && dz<-diff
                                  dy=0.1; dz=-0.2;
                              elseif dy<-diff && dz>diff
                                  dy=-0.1; dz=0.2;
                              elseif dy<-diff && dz<-diff
                                  dy=-0.1; dz=-0.2;
                              else
                                  % 기준 좌표와 픽셀 좌표가 허용 범위 내에 존재할 때
                                  % 미션 1의 경우 조금씩 앞으로 제어
                                  if mission==1
                                      dx=0.3; dy=0; dz=0.1;
                                  % 미션 2의 경우 구멍을 통과하고 미션 3으로 전환
                                  elseif mission==2
                                      pause(0.2);
                                      moveforward(droneObj,'Distance', 1.2, 'speed', 1);
                                      mission=3;
                                      continue;
                                  % 미션 3의 경우 조금씩 앞으로 제어
                                  else
                                      dx=0.2; dy=0; dz=0.1;
                                  end
                              end
                              move(droneObj,[dx dy dz]);
                              pause(0.1);
                          end

                          % 프레임, 구멍, 표식 영상 및 중 좌표 표시
                          subplot(2,2,1)
                          imshow(frame)

                          subplot(2,2,2)
                          imshow(hole)
                          hold on
                          if size(stats_h, 1)>0
                              plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                          end
                          hold off

                          subplot(2,2,3)
                          imshow(rect)
                          hold on
                          if size(stats_r, 1)>0
                              plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                          end
                          hold off

                  end  
              end

#### 5. 착륙
              land(droneObj);
          end

Informaiton
=============
>서울시립대학교 기계정보공학과
>
>담당교수 황면중교수
>
>>석사과정 문선영
>>
>>석사과정 박종훈
>>
>>e-mail : rhaxls07@uos.ac.kr
>>
>>e-mail : qkrwhdgns116@uos.ac.kr
>>
>>연락처 : 010-8949-5756
>>
>>연락처 : 010-7115-4220
