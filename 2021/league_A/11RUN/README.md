11RUN 
=============
기술 워크샵
-------------
# 대회 진행 전략

1. 영상처리에 대한 전략
 >영상처리를 원활 하게 진행하기 위해서는 색검출을 정밀하게 하는 것이 무엇 보다 중요하다. 이를 위해서 많은 시도를 통해 색의 정확한 범위를 찾도록 하였다.
 >색을 검출 했다면 다음은 링의 중심을 찾아야한다. 링의 중심을 찾는 과정은 아래의 알고리즘 부분에 자세하게 기재하였다.
 
2. 기체의 움직임에 대한 전략
 >미니드론의 경우 부품의 경량화로 인해 외란에 취약하며, 장애물을 통과하는 과정에 있어 정밀한 제어가 어렵다.
 >그렇기에 최대한 정밀하게 제어하기 위해서는 다양한 경우를 고려하여 코드를 더욱 정밀하게 짜야한다. 본 팀은 여러상황에서 속도의 비를 조절하여 유연성을 가지도록 하였다.
  
 
# 알고리즘

영상처리의 기본적인 알고리즘은 아래와 같다

![im](https://user-images.githubusercontent.com/63447815/125632034-cfca9cd3-6828-46a9-9c09-61f864ec1f4e.PNG)

>드론으로 촬영한 RGB 이미지를 HSV 채널로 변환한다. 이후에 검출하려는 색의 임계값으로 이진화 한다. 그 이후에 2차원 이진 영상의 연결성분에 레이블 지정하여 이진화된 객체를 포함하는 가장작은 직사각형을 찾는다. 마지막으로 직사각형의 네 점을 이용하여 중심점을 찾아내는 것 이다.
 
 >링의 중점을 유추하는 것에 대한 주요 전략은 크게 3단계로 나뉜다. 
 >>첫번째로 우선 링 후방의 마크(빨강, 보라)의 색을 추적한다. 마크는 링의 완전한 중심에 있고 링을 통과한 이후에도 추적이 가능하기 때문에 마크를 우선적으로 추적하여 중점을 잡도록한다. 
 >>>두번째로 링전체의 중심점이 아닌 링 내부의 중심점을 찾는다. 이 과정에서는 한단계가 추가되는데, 이진화된 이미지의 반전된 이미지에서 레이블을 하는 것이다. 반전된 이미지에서는 비어있는 링의 내부가 검출된다. 이는 링의 일부가 잘려서 보이는 상황에서 좀더 정확한 중심점을 찾아낼 수 있다. 하지만 이 경우에는 드론이 링에 매우 떨어져있어 링의 내부가 보이지 않을 경우에는 사용할수 없다.
 >>>>마지막으로 방금 언급했던 상황에는 링의 외곽 부분을 추적한다.
 
 >위와 같이 3가지의 단계로 구성하여 링의 중점을 보다 정확하게 구할 수 있으면서, 다양한 상황에서 더 유동적으로 대처할 수 있도록 하였다.

# 소스코드 설명
```MATLAB
%% 텔로 연결

droneObj=ryze(); %드론과 컴퓨터 연결
camObj=camera(droneObj); %카메라 연결
preview(camObj) %카메라 영상 확인
takeoff(droneObj) % 드론개체 이륙



%% 파랑색 검출을 위한 범위 설정
channel1Min = 0.53;
channel1Max = 0.65;

channel2Min = 0.3;
channel2Max = 1;

channel3Min = 0.2;
channel3Max = 1;

%% 빨강색 검출을 위한 범위 설정

red1Min = 0;
red1Max = 0.036;
red2Min = 0.96;
red2Max = 1;

redchannel2Min = 0.3;
redchannel2Max = 95;

redchannel3Min = 0.2;
redchannel3Max = 1;

%% 보라색 검출을 위한 범위 설정
PPchannel1Min = 0.66;
PPchannel1Max = 0.83;

PPchannel2Min = 0.1;
PPchannel2Max = 1;

PPchannel3Min = 0.175;
PPchannel3Max = 1;

%% 전체 링의 중심범위
% y축 중심 360을 기준으로 -100, 범위 408
centerD=300;
centerU=220;

% x축 중심 480을 기준으로 범위 70 
centerR=550; 
centerL=410;

%% 기타 초기 값

 Round = 1; % 라운드 카운팅 
 V = 1; % 전체 속도 설정
 Vx = 0.2; % 위아래 속도 설정
 Vy = 0.2; % 양옆 속도 설정
 moveforward(droneObj,1,'speed',1); 

%% 메인 루프
while(1)
   frame=snapshot(camObj); % 드론 카메라에서 이미지 가져오기
   I=rgb2hsv(frame); % 이미지에 대한 HSV 설정
   
  if (Round < 3) % 1,2 라운드를 위한 영상처리
                H_red = ((I(:,:,1) >= red1Min) & (I(:,:,1) <= red1Max) |...
                (I(:,:,1) >= red2Min) & (I(:,:,1) <= red2Max)) & ...
                (I(:,:,2) >= redchannel2Min ) & (I(:,:,2) <= redchannel2Max) & ...
                (I(:,:,3) >= redchannel3Min ) & (I(:,:,3) <= redchannel3Max);
                H_red = medfilt2(H_red); % 노이즈 제거를 위한 블러 적용
                red = bwlabel(H_red, 8); % 이진화 이미지에 레이블 지정
                redstats = regionprops(red, 'BoundingBox', 'Centroid','Area');
                redArray1=struct2table(redstats); % 배열을 테이블로 전환
                redArray2=table2array(redArray1); % 테이블을 행렬로 전환
                redsizel=size(redArray2);
                redsize2=redsizel(1);
                redArray3=redArray2(1:redsize2);
                [redmaxvalue,redmaxPosition]=max(redArray3);
            
                if (isempty(redmaxvalue))
                    %% 링 영상처리
                    BWa = ( (I(:,:,1) >= channel1Min) & (I(:,:,1) <= channel1Max) ) & ...
                    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
                    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max); 

                    BWb = medfilt2(BWa); % 노이즈 제거를 위한 블러 적용
                    BWIb= imcomplement(BWb); % 이미지 반전      
                    BIW = bwlabel(BWIb, 8); % 이진화 이미지에 레이블 지정
    
                     Istats = regionprops('Table',BIW, 'BoundingBox','Area');
                     Istats=table2array(Istats); % 배열을 테이블로 전환
                     sizel=size(Istats); % 테이블을 행렬로 전환
                     size2=sizel(1);
                     InMaxValueArray=Istats(1:size2)';   
                     UnNoizeArray=[];
                     k=1;
                     for i=1:size2 
                        if InMaxValueArray(i,1)>500
                         UnNoizeArray(k,1)=Istats(i,2);
                         UnNoizeArray(k,2)=Istats(i,3);
                         UnNoizeArray(k,3)=Istats(i,4);
                         UnNoizeArray(k,4)=Istats(i,5);
                         k=k+1;
                        end    
                     end
                    UnNoizeArraysize=size(UnNoizeArray);
                    UnNoizeArraysize=UnNoizeArraysize(1);
                    ImageCenterX = 0;
                    ImageCenterY = 0;
                    V = 1;
                    V1 = 0.2;
                    V2 = 0.2;
   
    
                    while i<UnNoizeArraysize+1
                        if (((UnNoizeArray(i,1))~= 0.5)&&((UnNoizeArray(i,1))~= 960)&&((UnNoizeArray(i,1))~= 720))&&...
                            (((UnNoizeArray(i,2))~= 0.5)&&((UnNoizeArray(i,2))~= 960)&&((UnNoizeArray(i,2))~= 720))&&...
                            (((UnNoizeArray(i,3))~= 0.5)&&((UnNoizeArray(i,3))~= 960)&&((UnNoizeArray(i,3))~= 720))&&...
                            (((UnNoizeArray(i,4))~= 0.5)&&((UnNoizeArray(i,4))~= 960)&&((UnNoizeArray(i,4))~= 720))
                
                           testR=UnNoizeArray(i,1)+UnNoizeArray(i,3)-0.5;
                           testL=UnNoizeArray(i,1)-0.5;
                           testD=UnNoizeArray(i,2)+UnNoizeArray(i,4)-0.5;
                           testU=UnNoizeArray(i,2)-0.5;
                           %%　１/4원 검출시 영상처리
                           ImageCenterX = (testR+testL)/2; 
                           ImageCenterY = (testU+testD)/2;
                           vox=abs(ImageCenterX-480); % 절대값
                           voy=abs(ImageCenterY-360); % 절대값
                           V = 1;
                           V1 = 0.2 + (vox/480);
                           V2 = 0.2 + (voy/360);
                           break
                        end
                        i=i+1;
                   end
                    
                  if (ImageCenterX == 0)&&(ImageCenterY == 0)
                      BWb = bwlabel(BWb, 8); % 이진화 이미지에 레이블 지정
                      measurements = regionprops(BWb, 'BoundingBox','Area');
                      measurements= struct2cell(measurements);
                      z = measurements(2,1);
                      o = cell2mat(z);
                      ImageCenterX = (o(1,1)+o(1,3))/2;
                      ImageCenterY = (o(1,2)+o(1,4))/2;
                      vox=abs(ImageCenterX-480); % 절대값
                      voy=abs(ImageCenterY-360); % 절대값
                      V = 1;
                      V1 = 0.2 + (vox/480);
                      V2 = 0.2 + (voy/360);
                  
                  end
                %% 빨간색 마크의 면적이 일정한 값 넘을시 회전
                elseif (redmaxvalue > 1200)
                    turn(droneObj,deg2rad(90));
                    Round = Round + 1; 
                    V = 0.75;
                               
                else
                    ImageCenterX=redArray2(redmaxPosition,2);
                    ImageCenterY=redArray2(redmaxPosition,3);
                    vox=abs(ImageCenterX-480); % 절대값
                    voy=abs(ImageCenterY-360); % 절대값
                    V = 1;
                    V1 = 0.2 + (vox/480);
                    V2 = 0.2 + (voy/360);
                end
  else
                 H_PP = ( (I(:,:,1) >= PPchannel1Min) & (I(:,:,1) <= PPchannel1Max) ) & ...
                 (I(:,:,2) >= PPchannel2Min ) & (I(:,:,2) <= PPchannel2Max) & ...
                 (I(:,:,3) >= PPchannel3Min ) & (I(:,:,3) <= PPchannel3Max);
                 H_PP = medfilt2(H_PP); % 노이즈 제거를 위한 블러 적용
                 PP = bwlabel(H_PP, 8); % 이진화 이미지에 레이블 지정
                 PPstats = regionprops(PP, 'BoundingBox', 'Centroid','Area');
                 PPArray1=struct2table(PPstats); % 배열을 테이블로 전환
                 PPArray2=table2array(PPArray1); % 테이블을 행렬로 전환
                 PPsizel=size(PPArray2);
                 PPsize2=PPsizel(1);
                 PPArray3=PPArray2(1:PPsize2);
                 [PPmaxvalue,PPmaxPosition]=max(PPArray3);  
                 
                 if (isempty(PPmaxvalue))                    
                     %% 링 영상처리
                    BWa = ( (I(:,:,1) >= channel1Min) & (I(:,:,1) <= channel1Max) ) & ...
                    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
                    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max); 

                    BWb = medfilt2(BWa); % 노이즈 제거를 위한 블러 적용
                    BWIb= imcomplement(BWb); % 이미지 반전  
                    BIW = bwlabel(BWIb, 8); % 이진화 이미지에 레이블 지정
    
                     Istats = regionprops('Table',BIW, 'BoundingBox','Area');
                     Istats=table2array(Istats); % 테이블을 행렬로 전환
                     sizel=size(Istats);
                     size2=sizel(1);
                     InMaxValueArray=Istats(1:size2)';   
                     UnNoizeArray=[];
                     k=1;
                     for i=1:size2 
                        if InMaxValueArray(i,1)>500
                         UnNoizeArray(k,1)=Istats(i,2);
                         UnNoizeArray(k,2)=Istats(i,3);
                         UnNoizeArray(k,3)=Istats(i,4);
                         UnNoizeArray(k,4)=Istats(i,5);
                         k=k+1;
                        end    
                     end
                    UnNoizeArraysize=size(UnNoizeArray);
                    UnNoizeArraysize=UnNoizeArraysize(1);
                    ImageCenterX = 0;
                    ImageCenterY = 0;
                    V = 1;
                    V1 = 0.2;
                    V2 = 0.2;
   
    
                    while i<UnNoizeArraysize+1
                        if (((UnNoizeArray(i,1))~= 0.5)&&((UnNoizeArray(i,1))~= 960)&&((UnNoizeArray(i,1))~= 720))&&...
                            (((UnNoizeArray(i,2))~= 0.5)&&((UnNoizeArray(i,2))~= 960)&&((UnNoizeArray(i,2))~= 720))&&...
                            (((UnNoizeArray(i,3))~= 0.5)&&((UnNoizeArray(i,3))~= 960)&&((UnNoizeArray(i,3))~= 720))&&...
                            (((UnNoizeArray(i,4))~= 0.5)&&((UnNoizeArray(i,4))~= 960)&&((UnNoizeArray(i,4))~= 720))
                
                           testR=UnNoizeArray(i,1)+UnNoizeArray(i,3)-0.5;
                           testL=UnNoizeArray(i,1)-0.5;
                           testD=UnNoizeArray(i,2)+UnNoizeArray(i,4)-0.5;
                           testU=UnNoizeArray(i,2)-0.5;
                   
                           ImageCenterX = (testR+testL)/2;
                           ImageCenterY = (testU+testD)/2;
                           vox=abs(ImageCenterX-480); % 절대값
                           voy=abs(ImageCenterY-360); % 절대값
                           V = 1;
                           V1 = 0.2 + (vox/480);
                           V2 = 0.2 + (voy/360);
                           break
                        end
                        i=i+1;
                   end
                    
       
                    
                  if (ImageCenterX == 0)&&(ImageCenterY == 0)
                      BWb = bwlabel(BWb, 8); % 이진화 이미지에 레이블 지정
                      measurements = regionprops(BWb, 'BoundingBox','Area');
                      measurements= struct2cell(measurements); % 배열을 테이블로 전환
                      z = measurements(2,1);
                      o = cell2mat(z);
                      ImageCenterX = (o(1,1)+o(1,3))/2;
                      ImageCenterY = (o(1,2)+o(1,4))/2;
                      vox=abs(ImageCenterX-480); % 절대값
                      voy=abs(ImageCenterY-360); % 절대값
                      V = 1;
                      V1 = 0.2 + (vox/480);
                      V2 = 0.2 + (voy/360);
                
                  end    
       %% 보라색 마크의 면적이 일정한 값 넘을시 착륙            
                elseif (PPmaxvalue > 1200)                                    
                    land(droneObj); % 드론 착륙
                  
                    break
                else
                    ImageCenterX=PPArray2(PPmaxPosition,2);
                    ImageCenterY=PPArray2(PPmaxPosition,3);
                    vox=abs(ImageCenterX-480); % 절대값
                    voy=abs(ImageCenterY-360); % 절대값
                    V = 1;
                    V1 = 0.2 + (vox/480);
                    V2 = 0.2 + (voy/360);
                end
  end
    
    %% 드론 이동
    
    if ((centerU<=ImageCenterY)&&(ImageCenterY<=centerD))&&((centerL<=ImageCenterX)&&(ImageCenterX<=centerR))      
         moveforward(droneObj,1,'speed',V); %속도 1만큼씩 움직임
      
    end    
    if ImageCenterY>centerD   %사진이 중앙보다 위쪽에 있을 경우  
        movedown(droneObj,Vy,'Speed',1); %속도 1만큼씩 아래로 움직임
      
    end
    if ImageCenterY<centerU        %사진이 중앙보다 아래쪽에 있을 경우 
         moveup(droneObj,Vy,'Speed',1); %속도 1만큼씩 위로 움직임
       
    end  
            
    if ImageCenterX>centerR        %사진이 중앙보다 왼쪽에 있을 경우
        moveright(droneObj,Vx,'Speed',1); %속도 1만큼씩 오른족으로 움직임
      
    end
    if ImageCenterX<centerL      %사진이 중앙보다 오른쪽에 있을 경우  
        moveleft(droneObj,Vx,'Speed',1); %속도 1만큼씩 왼쪽으로 움직임
      
    end
   
end


```

