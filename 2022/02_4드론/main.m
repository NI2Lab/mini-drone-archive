
% 0. 선언
% dronee=ryze("TELLO-ED9E1F");    %드론 객체 선언

dronee=ryze()    %드론 객체 선언
pause(0.5);
cam=camera(dronee);             %드론 카메라 객체 선언
pause(0.5);

% 0-1. 띄우기
takeoff(dronee); 
pause(0.5);
moveup(dronee,Distance=0.6)

% 1. 1단계 (빨간색)--------------------------------
while 1
frame1=snapshot(cam);
hsv = rgb2hsv(frame1);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);
BlueOnly = (0.55<h)&(h<0.8)&(0.8<s)&(s<=1); % 초록 성분만 추출

% 1-1. 가운데 원만 추출
    for i=1:960
        BlueOnly(1,i)=1;
    end
    % 1-2. 마지막 행을 1로 변환
    for i=1:960
        BlueOnly(720,i)=1;
    end
    BlueHole = imfill(BlueOnly,"holes");   % 가운데 빈 원의 공간을 매꿈
    for x=1:720
        for y=1:960
            if BlueOnly(x,y)==BlueHole(x,y)
                BlueHole(x,y)=0;
            end
        end
    end

Center1 = regionprops(BlueHole,'Image','BoundingBox','Centroid','Area'); % 중심값을 계산

    % 1-3. 원의 구멍 찾기
    if nnz(BlueHole)>1500&&nnz(BlueHole)<500000 %<<<<<<<<<<<<<<<<<수정 필요
       if (Center1(1).Centroid(1)+Center1(1).Centroid(2))/840<1.12&&(Center1(1).Centroid(1)+Center1(1).Centroid(2))/840>0.881
       moveforward(dronee,'distance',0.2);
    
        elseif (Center1(1).Centroid(1)+Center1(1).Centroid(2))/840>1.12||(Center1(1).Centroid(1)+Center1(1).Centroid(2))/840<0.881
            if 480-Center1(1).Centroid(1)>50
               moveleft(dronee,'distance',0.2);
            elseif  480-Center1(1).Centroid(1)<-50
               moveright(dronee,'distance',0.2);
            end
            
            if 360-Center1(1).Centroid(2)>50
               moveup(dronee,'distance',0.2);
            elseif  360-Center1(1).Centroid(2)<-50
               movedown(dronee,'distance',0.2);
            end
        
        end 
    else
        % 1-4. 빨간 표식 찾기
        frame2=snapshot(cam);
        hsv = rgb2hsv(frame2);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        RedOnly = ((0.95<h)&(h<1)|(0<h)&(h<0.05))&(0.8<s)&(s<=1);
        turn(dronee,deg2rad(90)); 
    end
    break
end

%-------------------------------------------------------

% 2. 2단계 (초록색)--------------------------------
while 1
frame1=snapshot(cam);
hsv = rgb2hsv(frame1);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);
BlueOnly = (0.37<h)&(h<0.48)&(s>0.4)&(v>0.1)&(v<0.9); % 초록 성분만 추출

% 2-1. 가운데 원만 추출
    for i=1:960
        BlueOnly(1,i)=1;
    end
    %2-2. 마지막 행을 1로 변환
    for i=1:960
        BlueOnly(720,i)=1;
    end
    BlueHole = imfill(BlueOnly,"holes");   % 가운데 빈 원의 공간을 매꿈
    for x=1:720
        for y=1:960
            if BlueOnly(x,y)==BlueHole(x,y)
                BlueHole(x,y)=0;
            end
        end
    end

Center1 = regionprops(BlueHole,'Image','BoundingBox','Centroid','Area'); % 중심값을 계산

    % 2-3. 원의 구멍 찾기
    if nnz(BlueHole)>1500&&nnz(BlueHole)<500000 %<<<<<<<<<<<<<<<<<수정 필요
       if (Center1(1).Centroid(1)+Center1(1).Centroid(2))/840<1.12&&(Center1(1).Centroid(1)+Center1(1).Centroid(2))/840>0.881
       moveforward(dronee,'distance',0.2);
    
        elseif (Center1(1).Centroid(1)+Center1(1).Centroid(2))/840>1.12||(Center1(1).Centroid(1)+Center1(1).Centroid(2))/840<0.881
            if 480-Center1(1).Centroid(1)>50
               moveleft(dronee,'distance',0.2);
            elseif  480-Center1(1).Centroid(1)<-50
               moveright(dronee,'distance',0.2);
            end
            
            if 360-Center1(1).Centroid(2)>50
               moveup(dronee,'distance',0.2);
            elseif  360-Center1(1).Centroid(2)<-50
               movedown(dronee,'distance',0.2);
            end
        
        end 
    else
        % 2-4. 초록 표식 찾기
        frame2=snapshot(cam);
        hsv = rgb2hsv(frame2);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        GreenOnly = (0.37<h)&(h<0.48)&(s>0.4)&(v>0.1)&(v<0.9);
        turn(dronee,deg2rad(90)); 
    end
    break
end

%-------------------------------------------------------

