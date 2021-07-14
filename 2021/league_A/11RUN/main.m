%% 텔로 연결
droneObj=ryze();
camObj=camera(droneObj);
takeoff(droneObj)


%% 파랑
channel1Min = 0.53;
channel1Max = 0.65;

channel2Min = 0.3;
channel2Max = 1;

channel3Min = 0.2;
channel3Max = 1;

%% 빨강

red1Min = 0;
red1Max = 0.036;
red2Min = 0.96;
red2Max = 1;

redchannel2Min = 0.3;
redchannel2Max = 95;

redchannel3Min = 0.2;
redchannel3Max = 1;

%% 보라
PPchannel1Min = 0.66;
PPchannel1Max = 0.83;

PPchannel2Min = 0.1;
PPchannel2Max = 1;

PPchannel3Min = 0.175;
PPchannel3Max = 1;

%% 링 중심범위
% y축 중심 360을 기준으로 -100, 범위 408
centerD=300;
centerU=220;

% x축 중심 480을 기준으로 범위 70 
centerR=550; 
centerL=410;

%% 기타 초기 값

 Round = 1;
 V = 1;
 Vx = 0.2;
 Vy = 0.2;
 moveforward(droneObj,1,'speed',1); 

%% 메인 루프
while(1)
   frame=snapshot(camObj);
   I=rgb2hsv(frame);   
   
  if (Round < 3)
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
                    %% 링 영상처리
                    BWa = ( (I(:,:,1) >= channel1Min) & (I(:,:,1) <= channel1Max) ) & ...
                    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
                    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max); 

                    BWb = medfilt2(BWa);
                    BWIb= imcomplement(BWb);    
                    BIW = bwlabel(BWIb, 8); 
    
                     Istats = regionprops('Table',BIW, 'BoundingBox','Area');
                     Istats=table2array(Istats);
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
                           vox=abs(ImageCenterX-480);
                           voy=abs(ImageCenterY-360);
                           V = 1;
                           V1 = 0.2 + (vox/480);
                           V2 = 0.2 + (voy/360);
                           break
                        end
                        i=i+1;
                   end                    
                   
                    
                  if (ImageCenterX == 0)&&(ImageCenterY == 0)
                      BWb = bwlabel(BWb, 8);
                      measurements = regionprops(BWb, 'BoundingBox','Area');
                      measurements= struct2cell(measurements);
                      z = measurements(2,1);
                      o = cell2mat(z);
                      ImageCenterX = (o(1,1)+o(1,3))/2;
                      ImageCenterY = (o(1,2)+o(1,4))/2;
                      vox=abs(ImageCenterX-480);
                      voy=abs(ImageCenterY-360);
                      V = 1;
                      V1 = 0.2 + (vox/480);
                      V2 = 0.2 + (voy/360);                      
                  end
                        
                elseif (redmaxvalue > 1200)
                    turn(droneObj,deg2rad(90));
                    Round = Round + 1;
                    V = 0.75;                                   
                else
                    ImageCenterX=redArray2(redmaxPosition,2);
                    ImageCenterY=redArray2(redmaxPosition,3);
                    vox=abs(ImageCenterX-480);
                    voy=abs(ImageCenterY-360);
                    V = 1;
                    V1 = 0.2 + (vox/480);
                    V2 = 0.2 + (voy/360);
                end
  else
                 H_PP = ( (I(:,:,1) >= PPchannel1Min) & (I(:,:,1) <= PPchannel1Max) ) & ...
                 (I(:,:,2) >= PPchannel2Min ) & (I(:,:,2) <= PPchannel2Max) & ...
                 (I(:,:,3) >= PPchannel3Min ) & (I(:,:,3) <= PPchannel3Max);
                 H_PP = medfilt2(H_PP); 
                 PP = bwlabel(H_PP, 8);
                 PPstats = regionprops(PP, 'BoundingBox', 'Centroid','Area');
                 PPArray1=struct2table(PPstats);
                 PPArray2=table2array(PPArray1);
                 PPsizel=size(PPArray2);
                 PPsize2=PPsizel(1);
                 PPArray3=PPArray2(1:PPsize2);
                 [PPmaxvalue,PPmaxPosition]=max(PPArray3);  
                 
                 if (isempty(PPmaxvalue))                    
                     %% 링 영상처리
                    BWa = ( (I(:,:,1) >= channel1Min) & (I(:,:,1) <= channel1Max) ) & ...
                    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
                    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max); 

                    BWb = medfilt2(BWa);
                    BWIb= imcomplement(BWb);    
                    BIW = bwlabel(BWIb, 8); 
    
                     Istats = regionprops('Table',BIW, 'BoundingBox','Area');
                     Istats=table2array(Istats);
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
                           vox=abs(ImageCenterX-480);
                           voy=abs(ImageCenterY-360);
                           V = 1;
                           V1 = 0.2 + (vox/480);
                           V2 = 0.2 + (voy/360);
                           break
                        end
                        i=i+1;
                    end                  
                     
                    
                  if (ImageCenterX == 0)&&(ImageCenterY == 0)
                      BWb = bwlabel(BWb, 8);
                      measurements = regionprops(BWb, 'BoundingBox','Area');
                      measurements= struct2cell(measurements);
                      z = measurements(2,1);
                      o = cell2mat(z);
                      ImageCenterX = (o(1,1)+o(1,3))/2;
                      ImageCenterY = (o(1,2)+o(1,4))/2;
                      vox=abs(ImageCenterX-480);
                      voy=abs(ImageCenterY-360);
                      V = 1;
                      V1 = 0.2 + (vox/480);
                      V2 = 0.2 + (voy/360);
                      
                  end                  
                elseif (PPmaxvalue > 1200)                                    
                    land(droneObj);
                    
                    break
                else
                    ImageCenterX=PPArray2(PPmaxPosition,2);
                    ImageCenterY=PPArray2(PPmaxPosition,3);
                    vox=abs(ImageCenterX-480);
                    voy=abs(ImageCenterY-360);
                    V = 1;
                    V1 = 0.2 + (vox/480);
                    V2 = 0.2 + (voy/360);
                end
  end
    
    %% 드론 이동
    
    if ((centerU<=ImageCenterY)&&(ImageCenterY<=centerD))&&((centerL<=ImageCenterX)&&(ImageCenterX<=centerR))      
         moveforward(droneObj,1,'speed',V);        
              
    end    
    if ImageCenterY>centerD      
        movedown(droneObj,Vy,'Speed',1);
      
    end
    if ImageCenterY<centerU         
         moveup(droneObj,Vy,'Speed',1);
         
    end  
            
    if ImageCenterX>centerR        
        moveright(droneObj,Vx,'Speed',1);
       
    end
    if ImageCenterX<centerL        
        moveleft(droneObj,Vx,'Speed',1);
        
    end
   
end