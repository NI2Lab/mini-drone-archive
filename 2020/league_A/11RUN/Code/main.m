%% Mini-drone 연결

droneObj=ryze()
camObj=camera(droneObj);


[angle]= readOrientation(droneObj)
takeoff(droneObj)
[height] = readHeight(droneObj);
height1=height;
moveup(droneObj,1,'Speed',0.2);
moveforward(droneObj,1,'speed',0.75);

% y축 중심 360을 기준으로 -100, 범위 408
centerD=300;
centerU=220;

% x축 중심 480을 기준으로 범위 70 
centerR=550; 
centerL=410;

Round=1;
Rotate=0;
Num=0;
sprintf('%d 라운드 시작',Round)

%[angles,time]= readOrientation(droneObj); %yaw,pitch,roll 검출
%초기 yaw값
yawI=angle(1);

%% Main-loop

while(1)    
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
    HSVframe=rgb2hsv(frame);    
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
    if Round<3        
        [RedCenterX, RedCenterY, redmaxvalue] = FindRed(HSVframe);                  
        if (~isempty(redmaxvalue))&&(Novalue==0)&&(redmaxvalue>=20)            
            ImageCenterY=GreenCenterY;
            ImageCenterX=GreenCenterX;                       
        elseif (isempty(redmaxvalue)||(redmaxvalue<20))&&(Novalue==0)            
            ImageCenterY=GreenCenterY;
            ImageCenterX=GreenCenterX;
        elseif ((~isempty(redmaxvalue))&&(redmaxvalue>=20))&&(Novalue==1)
            ImageCenterY=RedCenterY;
            ImageCenterX=RedCenterX;
        else             
            ImageCenterY=720;
            ImageCenterX=470;
        end
        
        if (~isempty(redmaxvalue))
            if (800>redmaxvalue)&&(redmaxvalue>500)                
                moveforward(droneObj,1,'speed',0.2)
                turn(droneObj, -deg2rad(90));
                Round=Round+1;
                yawI=(yawI)-deg2rad(90)
                Rotate=1;                
                sprintf('%d 라운드 시작',Round)
            elseif 800<redmaxvalue                               
                turn(droneObj, -deg2rad(90));
                Round=Round+1;
                yawI=(yawI)-deg2rad(90)
                Rotate=1;                
                sprintf('%d 라운드 시작',Round)                
            end
        end
    else
        [BlueCenterX, BlueCenterY, bluemaxvalue] = FindBlue(HSVframe);
         if (Novalue==0)&&(~isempty(bluemaxvalue))&&(bluemaxvalue>=20)      
            ImageCenterY=GreenCenterY;
            ImageCenterX=GreenCenterX;                     
        elseif (Novalue==0)&&(isempty(bluemaxvalue)||(bluemaxvalue<20))           
            ImageCenterY=GreenCenterY;
            ImageCenterX=GreenCenterX ;
        elseif (Novalue==1)&&(~isempty(bluemaxvalue))           
            ImageCenterY=BlueCenterY;
            ImageCenterX=BlueCenterX; 
        else            
            ImageCenterY=720;
            ImageCenterX=470;           
         end
         if (~isempty(bluemaxvalue))
            if (bluemaxvalue>500)&&(bluemaxvalue<800)
                moveforward(droneObj,1,'speed',0.2);                
                land(droneObj);
                break
            elseif bluemaxvalue>800               
                land(droneObj);
                break
            end
         end        
    end
    
  if Rotate==0  
    %이동
    if ((centerU<=ImageCenterY)&&(ImageCenterY<=centerD))&&((centerL<=ImageCenterX)&&(ImageCenterX<=centerR))      
         moveforward(droneObj,1,'speed',0.75);         
    end
    if ImageCenterY>centerD      
        movedown(droneObj,1,'Speed',0.2);
    end
    if ImageCenterY<centerU         
         moveup(droneObj,1,'Speed',0.2);
    end  
            
    if ImageCenterX>centerR        
        moveright(droneObj,1,'Speed',0.2);
    end
    if ImageCenterX<centerL        
        moveleft(droneObj,1,'Speed',0.2);
    end
  else
      Rotate=0;
  end
 
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


