
## 대회 진행 전략

**1.  기체의 움직임에 대한 전략**

 미니드론의 경우 부품의 경량화로 인해 외란에 취약하며, 장애물을 통과하는 과정에 있어 정밀한 제어가 어렵다.
이러한 단점을 바탕으로 미니드론의 자율비행은 다음과 같은 문제점을 포함하고 있다.

**<문제점>**
 - P1)  영상 수신 과정에서 roll, pitch, yaw각이 흔들려 정확한 영상 수신 불가.
 - P2)  기체의 이동에 대한 명령에 대하여 부정확한 움직임.
 (예: moveforward 명령어에 대해 드론의 상승) 
 - P3)  기체의 최소 이동거리 제약에 따른 이동의 비정밀함.

**<드론의 문제점을 해결하기 위한 전략 Point>**

 - S1)  일정한 영상 수신을 위해 MATLAB 명령어로 조절 가능한 yaw의 경우 초기 위치를 유지하는 알고리즘 설계, pitch각이 일정 범위에 들어야 영상을 수신하는 알고리즘 설계.
 - S2) 부정확한 움직임 중 과도한 고도 상승에 대하여 일정 고도 변화 이상의 경우 전진 거리 및 고도 변화 만큼 후진 및 하강하게 설계.
 - S3) 기체가 전진을 할때마다 기준선의 범위를 조절하며, 기체가 회전 또는 착륙을 고려할때 목표물체의 픽셀 수의 범위에 따라 각각 적절한 행동을 취함.
 
**2. 영상처리에 대한 전략**

  영상처리의 경우 드론이 촬영한 이미지속의 장애물의 기하학적인 형상이 실제와 달라 하나의 메커니즘만으로 장애물의 중심점을 특정할 수 없다. 그러므로 각각의 상황에 맞는 알고리즘을 설계하여 시의적절하게 장애물의 중심점을 찾는 것이 중요하다.
  때문에 정밀한 중심좌표 획득을 위해 이진화 이미지의 대조군인 반전된 이진화 이미지를 동시에 연산하여 다양한 케이스에서 유연성을 가질수 있도록 하였다.



## 알고리즘


**1. 영상처리 알고리즘**

   ![enter image description here](https://github.com/YeongCheolUm/Aleague_11RUN/blob/master/Image/original.JPG)
 
 - **이진화**
 RGB채널의 이미지를 HSV채널로 변환 후 원하는 색상의 각 채널 임계값을 조절하여 이진화를 진행한다. 
 
 ![enter image description here](https://github.com/YeongCheolUm/Aleague_11RUN/blob/master/Image/binary.JPG)
 
 - **이미지 반전**
 이진화 이미지의 대조군인 반전된 이진화 이미지를 얻는다.
 
 ![enter image description here](https://github.com/YeongCheolUm/Aleague_11RUN/blob/master/Image/inverse.JPG)
 - **흐림효과**
이진화 진행한 이미지에 중간값 필터(median filter)를 이용해 이미지의 흐림(Blur)효과를 통해 노이즈를 제거한다.
 - **Labeling**
 장애물 및 경유지점 검출을 위해 목표객체를 그 객체를 포함하는 최소한의 직사각형으로 근사하여 표현한다.  이것으로 외곽 사각형의 중심과 사각형의 점의 좌표를 얻을 수 있다. 
 
 ![enter image description here](https://github.com/YeongCheolUm/Aleague_11RUN/blob/master/Image/labeling.JPG)
 
 - **반전 이미지의 Labeling**
  장애물 및 경유지점 검출을 위해 대조군인 반전임미지속의 목표객체를 그 객체를 포함하는 최소한의 직사각형으로 근사하여 표현한다. 이것으로 내부 사각형의 중심과 사각형의 점의 좌표를 얻을 수 있다. 
 
 ![enter image description here](https://github.com/YeongCheolUm/Aleague_11RUN/blob/master/Image/inverselabeling.JPG)
 - **이미지 중심 표시**
 이미지의 중점을 특정하기 위해 이미지속의 장애물의 위상에 따라 각기 다른 명령을 드론에게 내린다. 
 
	-첫 번째 가장 기본이 되는 상황으로 링의 외경과 내경이 검출된 경우 이다. 이 경우에는 반전된 이미지에서 검출된 사각형중 두번째로 픽셀의 갯수가 많은 사각형을 내경으로 판단하여, 그 내경의 중심점을 이미지의 중심으로 한다.
	
	-두번 째 외경이 화면에 꽉차는 경우이다 예를들어 외곽의 모양이 ㅁ, ㄱ, ㄴ, ㄷ 과 같은 상황이 대표적이다.  이 경우에는 반전된 이미지에서 검출된 사각형중 가장 픽셀의 갯수가 많은 것을 내경으로 판단하여,  그 내경의 중심점을 이미지의 중심으로 한다.
	
	-세번째는 그 외의 경우이다. 외경안에 내경이 존재하지 않거나 모든 픽셀이 초록색으로 검출되는등 첫번째와 두번째의 경우에 반하는 경우이다. 이 경우에는 위, 아래로 기체를 이동시켜 촬영된 이미지를 재확인한다.


  


**2. 미니드론 동작 알고리즘**
		영상처리에서 얻은 이미지의 중심의 좌표가 일정범위 안에 있도록 드론의 위치를 조정하여 범위안에 들어올경우 앞으로 이동한다. 이때 중심의 범위는 측정된 내경의 길이에 대한 함수로써 표현되며, 앞으로 전진하여 촬영된 내경의 크기가 커질수록 증가한다.


## 소스코드 설명

**1. Mini-drone 연결**

    droneObj=ryze() %드론 연결 
    camObj=camera(droneObj); %카메라 연결
    [angle]= readOrientation(droneObj) %현재 위상의 각 검출
    [height] = readHeight(droneObj);% 고도측정
    preview(camObj) %카메라 영상 확인
    
    takeoff(droneObj)
    
    
**2. 초기설정**

        
    % y축 중심 360을 기준으로 -100, 범위 408
    centerD=300;
    centerU=220;
    
    % x축 중심 480을 기준으로 범위 70 
    centerR=550; 
    centerL=410;
    
    Round=1; %라운드 카운팅
    Rotate=0; %회전 체크
    Num=0; %상하이동 확인
    sprintf('%d 라운드 시작',Round)
    yawI=angle(1);
    height1=height;

**3.	Yaw,	Pitch	각	조절**

       function [CameraPitch] = AngleControl(droneObj,yawI)
    
        [angles]= readOrientation(droneObj); %yaw,pitch,roll 검출
        yawD=angles(1) %현재의 yaw각 검출
        testyaw=abs(yawD-yawI); %불연속검출구간 검출을 위한 test value
        
        if testyaw>pi/2  %-180와 180도 사이 구간에서의 각도 변화
            TrueYaw=abs(yawD-yawI+2*pi);
        if yawD>0
            turn(droneObj,-TrueYaw);
            
        else
            if yawD<=0
                turn(droneObj,TrueYaw);
               
            end
        end
    else
        if testyaw<=pi/2
           TrueYaw=abs(yawD-yawI); 
            if yawD>0
              turn(droneObj,-TrueYaw);
             
            else
                if yawD<=0
                turn(droneObj,TrueYaw);               
               end
            end
        end
    end
    
    Pitch=angles(2);
    Pitch=rad2deg(Pitch);
    if (-5<=Pitch)&&(Pitch<=5)
        CameraPitch=true;
    else
        CameraPitch=false;
    end

    


    
**4-1.	초록색	검출**

 

       function [GreenCenterX,GreenCenterY,Novalue,centerD,centerU,centerR,centerL] = FindGreen(I,Round)
    
        % Case 1 : 일반적인 링의 외경과 내경이 검출되는 경우
        % Case 2 : 외경이 화면에 꽉 차는 경우 (ㅁ,ㄴ,ㄷ,ㄱ)
        % Case 3 : 외경 안에 내경이 존재하지 않는 경우 
        
        % 초기 선언 [Novalue=0 -> 링 검출 (Case1, Case2)]
        Novalue=0;
        channel1Min = 0.26;
        channel1Max = 0.38;
        channel2Min = 0.3;
        channel2Max = 1;
        channel3Min = 0.2;
        channel3Max = 1;
        
        % 이진화
        BWa = ( (I(:,:,1) >= channel1Min) & (I(:,:,1) <= channel1Max) ) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max); 
    
        BWb = medfilt2(BWa);  % 노이즈 제거를 위한 블러 적용 
        
        % 원본에 대한 영상처리 
        BW = bwlabel(BWb, 8);   % 라벨링 및 외경에 대한 정보 획득
        stats = regionprops('Table',BW, 'BoundingBox','Area');
        stats=table2array(stats);
        sizeb=size(stats);
        sizeb=sizeb(1);
        OutMaxArray=stats(1:sizeb)';
        [maxvalue,maxPosition]=max(OutMaxArray);
        if isempty(maxvalue)
            Novalue=1;
            GreenCenterX=0;
            GreenCenterY=0;
            % y축 중심 360을 기준으로 -120 (240), 범위 40
            centerD=280+(Round*5);
            centerU=200-(Round*5);
            % x축 중심 480을 기준으로 범위 100
            centerR=580+(Round*5);
            centerL=380-(Round*5);       
        else        
        OutR=stats(maxPosition,2)+stats(maxPosition,4)-0.5;
        OutL=stats(maxPosition,2)-0.5;
        OutD=stats(maxPosition,3)+stats(maxPosition,5)-0.5;
        OutU=stats(maxPosition,3)-0.5;    
        % 원본의 반전 된 이미지에 대한 영상처리
        BWIb= imcomplement(BWb);    
        BIW = bwlabel(BWIb, 8);    
        Istats = regionprops('Table',BIW, 'BoundingBox','Area');
        Istats=table2array(Istats);
        sizel=size(Istats);
        size2=sizel(1);
        InMaxValueArray=Istats(1:size2)';   
        
        % 노이즈 제거를 위해 픽셀의 크기가 500 이상의 물체 검출
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
      
         % 링의 외경이 화면에 접할때 
        if ((OutL==0)&&(OutR==960))&&((OutU==0)&&(OutD==720))
          [InMaxValue, po]=max(InMaxValueArray);
              if (isempty(InMaxValue)) % Case 3_1 : 화면에 외경이 접한 경우 중 모두 초록색인 경우
                  Novalue=2;
                  GreenCenterX=0;
                  GreenCenterY=0;
                  % y축 중심 360을 기준으로 -120 (240), 범위 40
                  centerD=280+(Round*5);
                  centerU=200-(Round*5);
                  % x축 중심 480을 기준으로 범위 100
                  centerR=580+(Round*5);
                  centerL=380-(Round*5);
              else % Case 2 : 링의 외경이 ㅁ,ㄷ,ㄴ.ㄱ의 형태로 접할때
                UnNoizeArray(1)=Istats(po(1),2);
                UnNoizeArray(2)=Istats(po(1),3);
                UnNoizeArray(3)=Istats(po(1),4);
                UnNoizeArray(4)=Istats(po(1),5);
                testR=UnNoizeArray(1)+UnNoizeArray(3)-0.5;
                testL=UnNoizeArray(1)-0.5;
                testD=UnNoizeArray(2)+UnNoizeArray(4)-0.5;
                testU=UnNoizeArray(2)-0.5;
                GreenCenterX=(testR+testL)/2;
                GreenCenterY=(testU+testD)/2;
                centerD=(260+(testD-testU)/6)+Round*5;
                centerU=(260-(testD-testU)/6)-Round*5;
                centerR=(480+(testR-testL)/6)+Round*5;
                centerL=(480-(testR-testL)/6)-Round*5;
                Novalue=0;            
              end      
        else % Case 1 : 일반적인 링의 외경과 내경이 검출되는 경우   
            i=1;
            UnNoizeArraysize=size(UnNoizeArray);
            UnNoizeArraysize=UnNoizeArraysize(1);
            % 검출된 모든 사각형중 모든점이 외경안에 드는 사각형을 찾는다.
            while i<UnNoizeArraysize+1
                    testR=UnNoizeArray(i,1)+UnNoizeArray(i,3)-0.5;
                    testL=UnNoizeArray(i,1)-0.5;
                    testD=UnNoizeArray(i,2)+UnNoizeArray(i,4)-0.5;
                    testU=UnNoizeArray(i,2)-0.5;
                    % Case 1 : 일반적인 링의 외경과 내경이 검출되는 경우 
                    if (((OutL<=testR)&&(testR<=OutR)) && ((OutL<=testL)&&(testL<=OutR)))&&...
                            (((OutU<=testD)&&(testD<=OutD)) && ((OutU<=testU)&&(testU<=OutD)))
                        GreenCenterX=(testR+testL)/2;
                        GreenCenterY=(testU+testD)/2;
                        centerD=(260+(testD-testU)/6)+Round*5;
                        centerU=(260-(testD-testU)/6)-Round*5;
                        centerR=(480+(testR-testL)/6)+Round*5;
                        centerL=(480-(testR-testL)/6)-Round*5;
                        Novalue=0;                 
                        break
                    else
                        Novalue=2;
                        GreenCenterX=0;
                        GreenCenterY=0;
                        % y축 중심 360을 기준으로 -120 (240), 범위 40
                        centerD=280+(Round*5);
                        centerU=200-(Round*5);
                        % x축 중심 480을 기준으로 범위 100
                        centerR=580+(Round*5);
                        centerL=380-(Round*5);
                    end
                    i=i+1;
            end 
        end
        end
    end

**4-2.		빨간색	검출**

    function [RedCenterX, RedCenterY, redmaxvalue] = FindRed(I)

    red1Min = 0;
    red1Max = 0.036;
    red2Min = 0.96;
    red2Max = 1;
    redchannel2Min = 0.3;
    redchannel2Max = 95;
    redchannel3Min = 0.2;
    redchannel3Max = 1;


    H_red = ((I(:,:,1) >= red1Min) & (I(:,:,1) <= red1Max) |...
        (I(:,:,1) >= red2Min) & (I(:,:,1) <= red2Max)) & ...
        (I(:,:,2) >= redchannel2Min ) & (I(:,:,2) <= redchannel2Max) & ...
        (I(:,:,3) >= redchannel3Min ) & (I(:,:,3) <= redchannel3Max);
    
    H_red = medfilt2(H_red); 
    red = bwlabel(H_red, 8);

    redstats = regionprops(red, 'BoundingBox', 'Centroid','Area');


    redArray1=struct2table(redstats);
    redArray2=table2array(redArray1);
    redsizel=size(redArray2);
    redsize2=redsizel(1);
    redArray3=redArray2(1:redsize2);
    [redmaxvalue,redmaxPosition]=max(redArray3);
    
    if (isempty(redmaxvalue))
        RedCenterX=[];
        RedCenterY=[];
        redmaxvalue=[];
    else
    RedCenterX=redArray2(redmaxPosition,2);
    RedCenterY=redArray2(redmaxPosition,3);
    end

    

**4-3.	파란색	검출**

    function [BlueCenterX, BlueCenterY, bluemaxvalue] = FindBlue(I)

   
    bluechannel1Min = 0.53;
    bluechannel1Max = 0.65;

    bluechannel2Min = 0.3;
    bluechannel2Max = 1;

    bluechannel3Min = 0.2;
    bluechannel3Max = 1;
    
    
    H_blue = ( (I(:,:,1) >= bluechannel1Min) & (I(:,:,1) <= bluechannel1Max) ) & ...
    (I(:,:,2) >= bluechannel2Min ) & (I(:,:,2) <= bluechannel2Max) & ...
    (I(:,:,3) >= bluechannel3Min ) & (I(:,:,3) <= bluechannel3Max);
    
    H_blue = medfilt2(H_blue);     
    blue = bwlabel(H_blue, 8);

    bluestats = regionprops(blue, 'BoundingBox', 'Centroid','Area');

        
    blueArray1=struct2table(bluestats);
    blueArray2=table2array(blueArray1);
    bluesizel=size(blueArray2);
    bluesize2=bluesizel(1);
    blueArray3=blueArray2(1:bluesize2);
    [bluemaxvalue,bluemaxPosition]=max(blueArray3);
    
    if (isempty(bluemaxvalue))
        BlueCenterX=[];
        BlueCenterY=[];
        bluemaxvalue=[];
    else
    BlueCenterX=blueArray2(bluemaxPosition,2);
    BlueCenterY=blueArray2(bluemaxPosition,3);
    end

    




**5. Main-loop**

       while(1)
        
        %yaw, pitch각 조절을 위한 함수
        try
            while(1)
                [CameraPitch]=AngleControl(droneObj,yawI); 
                if CameraPitch==true
                     frame=snapshot(camObj);
                     break
                elseif CameraPitch==false
                end
            end
        catch
            disp('각검출 오류')
            frame=snapshot(camObj);
        end
        
        %이미지 HSV
        HSVframe=rgb2hsv(frame);
        
        %초록 링 탐색
        [GreenCenterX,GreenCenterY,Novalue,centerD,centerU,centerR,centerL]=FindGreen(HSVframe,Round);    
         if Novalue==2
            if Num==0
                movedown(droneObj,1,'Speed',0.2);
                Num=1;
            else
                moveup(droneObj,1,'Speed',0.4);
                Num=0;
            end
         else
             Num=0;
       %1,2라운드에는 빨강 찾기, 3라운드는 파랑찾기 
        if Round<3 
            %빨강 원 탐색
            [RedCenterX, RedCenterY, redmaxvalue] = FindRed(HSVframe);                  
            if (~isempty(redmaxvalue))&&(Novalue==0)&&(redmaxvalue>=20)
                disp('초록 빨강 있음')
                ImageCenterY=GreenCenterY;
                ImageCenterX=GreenCenterX;                       
            elseif (isempty(redmaxvalue)||(redmaxvalue<20))&&(Novalue==0)
                disp('초록만 있음')
                ImageCenterY=GreenCenterY;
                ImageCenterX=GreenCenterX;
            elseif ((~isempty(redmaxvalue))&&(redmaxvalue>=20))&&(Novalue==1)
                disp('빨강만 있음')
                ImageCenterY=RedCenterY;
                ImageCenterX=RedCenterX;
            else 
                disp('빨강 초록 검출되지 않음')
                disp('하강')
                ImageCenterY=720;
                ImageCenterX=470;
            end
            
            if (~isempty(redmaxvalue))
                if (800>redmaxvalue)&&(redmaxvalue>500)
                    disp('회전')
                    moveforward(droneObj,1,'speed',0.2)
                    turn(droneObj, -deg2rad(90));
                    Round=Round+1;
                    yawI=(yawI)-deg2rad(90)
                    Rotate=1;                
                    sprintf('%d 라운드 시작',Round)
                elseif 800<redmaxvalue
                    disp('회전')                
                    turn(droneObj, -deg2rad(90));
                    Round=Round+1;
                    yawI=(yawI)-deg2rad(90)
                    Rotate=1;                
                    sprintf('%d 라운드 시작',Round)                
                end
            end
        else
            %파랑 원 탐색
            [BlueCenterX, BlueCenterY, bluemaxvalue] = FindBlue(HSVframe);
             if (Novalue==0)&&(~isempty(bluemaxvalue))&&(bluemaxvalue>=20)            
                disp('초록 파랑 있음')
                ImageCenterY=GreenCenterY;
                ImageCenterX=GreenCenterX;                     
            elseif (Novalue==0)&&(isempty(bluemaxvalue)||(bluemaxvalue<20))            
                disp('초록만 있음')
                ImageCenterY=GreenCenterY;
                ImageCenterX=GreenCenterX ;
            elseif (Novalue==1)&&(~isempty(bluemaxvalue))            
                disp('파랑만 있음')
                ImageCenterY=BlueCenterY;
                ImageCenterX=BlueCenterX; 
            else 
                disp('파랑 초록 검출되지 않음~')
                disp('하강')
                ImageCenterY=720;
                ImageCenterX=470;           
             end
             if (~isempty(bluemaxvalue))
                if (bluemaxvalue>500)&&(bluemaxvalue<800)
                    moveforward(droneObj,1,'speed',0.2);
                    disp('착륙')
                    land(droneObj);
                    break
                elseif bluemaxvalue>800               
                    disp('착륙')
                    land(droneObj);
                    break
                end
             end        
        end
        
      if Rotate==0  
        %이동
        if ((centerU<=ImageCenterY)&&(ImageCenterY<=centerD))&&((centerL<=ImageCenterX)&&(ImageCenterX<=centerR))
             disp('앞으로~')
             moveforward(droneObj,1,'speed',0.6);         
        end
        if ImageCenterY>centerD
            disp('내려가쟈')
            movedown(droneObj,1,'Speed',0.2);
        end
        if ImageCenterY<centerU
             disp('올라가쟈')
             moveup(droneObj,1,'Speed',0.2);
        end  
                
        if ImageCenterX>centerR
            disp('오른쪽가쟈')
            moveright(droneObj,1,'Speed',0.2);
        end
        if ImageCenterX<centerL
            disp('왼쪽가쟈')
            moveleft(droneObj,1,'Speed',0.2);
        end
      else
          Rotate=0;
      end
     
       
        %높이 조절
        [height] = readHeight(droneObj);
        height2=height;
        if (height2-height1)>0.4
             moveback(droneObj,1,'Speed',0.6)
             movedown(droneObj,'Distance',(height2-height1))
             [height] = readHeight(droneObj);
             height1=height;
        else
             height1=height;
        end
         end
        pause(1) 
    end


