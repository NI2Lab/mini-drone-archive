clear all
close all

%202007160114

drone = ryze()
cam = camera(drone);

[angles,time]= readOrientation(drone);
start_time=time;
ref_angle = angles(1)

takeoff(drone);

[height,time] = readHeight(drone);

while size(height) == [0 1]
    [height,time] = readHeight(drone);
end

ref_height=height;

while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end

SE1 = strel('disk',17);
SE2 = strel('disk',10);

moveforward(drone, 'Distance', 0.4,'WaitUntilDone',true);
while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end

%% 상하 1-1

while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    
    bw2 =bwareafilt(bwim,1);
    edgee = edge(bw2,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    step = '상하 1-1'
    
    error_y = 120-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0 %
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
end

%% 좌우 1-1

while 1
    
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    bw2 =bwareafilt(bwim,1);
    edgee = edge(bw2,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    
    step = '좌우 1-1'
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_x = s.Centroid(1)-240
    
    if error_x>=-30 && error_x<=30
        error_x=0;
    else
        error_x=error_x+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_x>0
        moveright(drone,'Distance',0.2,'WaitUntilDone',true);
    elseif error_x<0
        moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end

%% 상하 1-2

while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    img = snapshot(cam);
    
    while size(img) == [0 0 3]
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    bw2 =bwareafilt(bwim,1);
    edgee = edge(bw2,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    step = '상하1-2'
    
    subplot(1,2,2)
    subimage(bw_L)
    error_y = 120-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0 %
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end

%% 좌우 1-2

while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    bw2 =bwareafilt(bwim,1);
    edgee = edge(bw2,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    
    step = '좌우 1-2'
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_x = s.Centroid(1)-240
    
    if error_x>=-30 && error_x<=30
        error_x=0;
    else
        error_x=error_x+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_x>0
        moveright(drone,'Distance',0.2,'WaitUntilDone',true);
    elseif error_x<0
        moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end



%% 전진1

while 1
    step = '전진1'
    
    while 1 % 속도가 0이 될때 까지 1초씩 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(1)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    bw = d_green_detection(img);
    bw2 =bwareafilt(bw,1);
    
    bw3 = imerode(bw2,SE2); % 이미지 침식
    bw3 =bwareafilt(bw3,1); % 제일 큰 성분 취득
    
    subplot(1,2,1)
    subimage(img)
    subplot(1,2,2)
    subimage(bw3)
    
    if sum(bw3, 'all') >= 500
        moveforward(drone, 'Distance', 0.6,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 1초씩  지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.3)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 1초씩 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(1)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    pause(1)
end

%% 조정  1-1
time_1 = time;
step ='링통과후 조정1-1';
%disp(step)

[angles,time]= readOrientation(drone);

while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
    [angles,time]= readOrientation(drone);
end

drone_angle =angles(1)-ref_angle
turn(drone,(ref_angle-angles(1)))

while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end
moveforward(drone, 'Distance', 0.2 ,'WaitUntilDone',true); 

while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.5)
    else
        %disp('**')
        %disp(speed)
        break
    end
end
%% 1차붉은 점 탐색 좌/우

pause(0.5)

img = snapshot(cam);

bw = d_red_detection(img);
bw2 =bwareafilt(bw,1); % 제일 큰 것만 탐색

subplot(1,2,1)
subimage(bw)
subplot(1,2,2)
subimage(bw2)

s = regionprops(bw2,'centroid');
step = '붉은 점 탐색 좌/우';
%disp(step)
if size(s)==[0 1] %붉은 점이 1도 인식 안할  때
    s = struct('Centroid',[480 200]);
    pause(0.3)
end
error_x = -480+s.Centroid(1)

if error_x>=-200 && error_x<=200
    error_x=0;
else
    error_x=error_x+0;
end
while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end

if error_x>0 %
    moveright(drone,'Distance',0.2,'WaitUntilDone',true);
    %disp('오른쪽 이동')
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
elseif error_x<0
    moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
    %disp('왼쪽 이동')
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
else
    
end


while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end
%% 붉은 색

while 1
    step = '붉은 색1'
    
    pause(0.5)
    img = snapshot(cam);
    
    bw = d_red_detection(img);
    bw2 =bwareafilt(bw,1); % 제일 큰것 만 탐색
    
    subplot(1,2,1)
    subimage(bw)
    subplot(1,2,2)
    subimage(bw2)
    pause(1)
    
    red = sum(bw2,'all')
    
    if sum(bw2 ,'all') >= 1200
        step = '붉은색 인식'
        turn(drone,deg2rad(-85));
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        step ='각도 조정 1-2'
        [angles,time]= readOrientation(drone);
        
        while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
            [angles,time]= readOrientation(drone);
        end
        
        turn(drone,-pi/2+ref_angle-angles(1));
        ref_angle =ref_angle
        sense_angle =angles(1)
        drone_angle =angles(1)-ref_angle
        
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.7)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        
        moveforward(drone, 'Distance', 0.5 ,'WaitUntilDone',true); % 전진
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        moveforward(drone, 'Distance', 0.5 ,'WaitUntilDone',true); % 전진
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        break
        
    elseif sum(bw2 ,'all') >= 100
        step = '붉은색 근접 동작';
        %disp(step)
        moveforward(drone, 'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 1초씩 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(1)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
    else  % 붉은 점이 안보일 때
        step = '붉은 점이 안보임_후퇴';
        %disp(step)
        moveback(drone, 'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        %% 붉은 점 탐색 상하
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        img = snapshot(cam);
        
        bw = d_red_detection(img);
        bw2 =bwareafilt(bw,1); %
        
        subplot(1,2,1)
        subimage(bw)
        subplot(1,2,2)
        subimage(bw2)
        
        s = regionprops(bw2,'centroid');
        
        if size(s)==[0 1] %붉은 점이 1도 인식 안될  때
            s = struct('Centroid',[480 200]);
            pause(0.3)
        end
        
        step = '붉은 점 상하';
        %disp(step)
        error_y = 200-s.Centroid(2)
        
        if error_y>=-50 && error_y<=50
            error_y=0;
        else
            error_y=error_y+0;
        end
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        if error_y>0 %
            moveup(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        elseif error_y<0
            movedown(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        else
            
        end
        %% 붉은 점 탐색 좌/우
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        img = snapshot(cam);
        
        bw = d_red_detection(img);
        bw2 =bwareafilt(bw,1); % 제일 큰 것만 인식
        
        subplot(1,2,1)
        subimage(bw)
        subplot(1,2,2)
        subimage(bw2)
        
        s = regionprops(bw2,'centroid');
        step = '붉은 점 탐색 좌/우';
        %disp(step)
        
        if size(s)==[0 1] %붉은 점이 1도 인식 안될  때
            s = struct('Centroid',[480 200]);
            pause(0.3)
        end
        error_x = -480+s.Centroid(1)
        
        if error_x>=-100 && error_x<=100
            error_x=0;
        else
            error_x=error_x+0;
        end
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        if error_x>0 %
            moveright(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        elseif error_x<0
            moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        else
            
        end
        
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    end
end
%% 각도 조정 1-2

step ='각도 조정 1-2'
[angles,time]= readOrientation(drone);

while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
    [angles,time]= readOrientation(drone);
end

turn(drone,-pi/2+ref_angle-angles(1));
ref_angle =ref_angle
sense_angle =angles(1)
drone_angle =angles(1)-ref_angle

while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.7)
    else
        %disp('**')
        %disp(speed)
        break
    end
end


%% @@@@@@@@@@@@@@@@@@@@@@@@@@2단계@@@@@@@@@@@@@@@@@@@@@@@@@@

while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end
img = snapshot(cam);
while size(img) == [0 0 3]
    
    pause(0.4)
    img = snapshot(cam);
end
img2 = imresize(img,0.5);
img2(1,:)=0;
img2(:,1)=0;
img2(:,480) =0;
img2(360,:)=0;

bw = d_green_detection(img2);
bw2 =bwareafilt(bw,1);

bwJ = imerode(bw2,SE2);
bwim= imclose(bwJ,SE1);
edgee = edge(bwim,'Canny');


[B,L,n,A]  = bwboundaries(edgee,8);
bw_L =(L==max(L(:)));
s = regionprops(bw_L,'centroid');
if size(s)==[0 1] %붉은 점이 1도 인식 안 瑛  때
    s = struct('Centroid',[240 115]);
    pause(0.3)
end

step = '상하 2-1';
%disp(step)


subplot(1,2,1)
subimage(edgee)
subplot(1,2,2)
subimage(bw_L)

error_y = 115-s.Centroid(2)
%% 2단계 조정

if error_y>0
    adjust=1;
else
    adjust=0;
end

%% 링2 2-1상하

while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    bw2 =bwareafilt(bw,1);
    
    bwJ = imerode(bw2,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1] %붉은 점이 1도 인식 안 瑛  때
        s = struct('Centroid',[240 115]);
        pause(0.3)
    end
    
    step = '상하 2-1';
    %disp(step)
    
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_y = 115-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0 %
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end

%% 링 2단계  좌우 2-1

while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
        
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    bw2 =bwareafilt(bw,1);
    
    bwJ = imerode(bw2,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_x= s.Centroid(1)-240;
    
    step = '좌/우 2-1'
    
    if error_x>=-30 && error_x<=30
        error_x=0;
    else
        error_x=error_x+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_x>0 %
        moveright(drone,'Distance',0.3,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_x<0
        moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end

%% 상하2-2

while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    bw2 =bwareafilt(bw,1);
    
    bwJ = imerode(bw2,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 115]);
        pause(0.3)
    end
    
    step = '상하2-2';
    %disp(step)
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_y = 115-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0 %
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(1)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(1)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end
%% 좌/우 2-2
while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    bw2 =bwareafilt(bw,1);
    
    bwJ = imerode(bw2,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_x = s.Centroid(1)-240
    
    step = '좌/우 2-2';
    %disp(step)
    
    if error_x>=-30 && error_x<=30
        error_x=0;
    else
        error_x=error_x+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_x>0 %
        moveright(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_x<0
        moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end

step ='+각도 조정 '
[angles,time]= readOrientation(drone);

while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
    [angles,time]= readOrientation(drone);
end

turn(drone,-pi/2+ref_angle-angles(1));
ref_angle =ref_angle
sense_angle =angles(1)
drone_angle =angles(1)-ref_angle
%% 상하2-3
while 1
    
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    bw2 =bwareafilt(bw,1);
    
    bwJ = imerode(bw2,SE2);
    bwim= imclose(bwJ,SE1);
    
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 115]);
        pause(0.3)
    end
    
    step = '상하2-3';
    %disp(step)
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_y = 115-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0 %
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    
end
%% 조정
if adjust ==1
    moveup(drone, 'Distance', 0.2,'WaitUntilDone',true);
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end

%% 전진 2
while 1
    step = '전진2'
    %disp(step)
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    bw = d_green_detection(img);
    
    bw2 = imerode(bw,SE2); % 외곽 침식
    bw3 =bwareafilt(bw2,1); % 가장 큰성분 인식
    
    subplot(1,2,1)
    subimage(bw)
    subplot(1,2,2)
    subimage(bw3)
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if sum(bw3, 'all') >= 500
        moveforward(drone, 'Distance', 0.6,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 1초씩 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(1)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
end

moveforward(drone, 'Distance', 0.3,'WaitUntilDone',true);
%% 각도 조정 2-1
step ='각도 조정2-1'
[angles,time]= readOrientation(drone);


while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
    [angles,time]= readOrientation(drone);
end

turn(drone,-pi/2+ref_angle-angles(1));
sense_angle =angles(1);
drone_angle = sense_angle -ref_angle
time2 = time;
while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.7)
    else
        %disp('**')
        %disp(speed)
        break
    end
end
%% 1차 붉은 점 탐색 상하

pause(0.5)
img = snapshot(cam);

bw = d_red_detection(img);
bw2 =bwareafilt(bw,1); % 제일 큰것 인식

subplot(1,2,1)
subplot(1,2,2)
subimage(bw)
subimage(bw2)

s = regionprops(bw2,'centroid');

if size(s)==[0 1] %붉은 점이 1도 인식 안 瑛  때
    s = struct('Centroid',[480 200]);
    pause(0.3)
end

step = '붉은 점 상하';
%disp(step)
error_y = 200-s.Centroid(2)

if error_y>=-150 && error_y<=50
    error_y=0;
else
    error_y=error_y+0;
end

while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end

if error_y>0 %
    moveup(drone,'Distance',0.2,'WaitUntilDone',true);
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
elseif error_y<0
    movedown(drone,'Distance',0.2,'WaitUntilDone',true);
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
else
    
end

%% 1차붉은 점 탐색 좌/우

pause(0.5)

img = snapshot(cam);

bw = d_red_detection(img);
bw2 =bwareafilt(bw,1); % 제일 큰 것만 탐색

subplot(1,2,1)
subimage(bw)
subplot(1,2,2)
subimage(bw2)

s = regionprops(bw2,'centroid');
step = '붉은 점 탐색 좌/우';
%disp(step)
if size(s)==[0 1] %붉은 점이 1도 인식 안 瑛  때
    s = struct('Centroid',[480 200]);
    pause(0.3)
end
error_x = -480+s.Centroid(1)

if error_x>=-200 && error_x<=200
    error_x=0;
else
    error_x=error_x+0;
end
while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end

if error_x>0 %
    moveright(drone,'Distance',0.2,'WaitUntilDone',true);
    %disp('오른쪽 이동')
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
elseif error_x<0
    moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
    %disp('왼쪽 이동')
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
else
    
end


while 1 % 속도가 0이 될때 까지 지연
    [speed,time] = readSpeed(drone);
    if sum(speed) ~= 0
        
        %disp(speed)
        pause(0.4)
    else
        %disp('**')
        %disp(speed)
        break
    end
end

%% 붉은 점 2
while 1
    step = '붉은 점2'
    %disp(step)
    pause(0.5)
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    bw = d_red_detection(img);
    bw2 =bwareafilt(bw,1); % 가장 큰이미지 인식
    
    subplot(1,2,1)
    subimage(bw)
    subplot(1,2,2)
    subimage(bw2)
    red = sum(bw2,'all')
    if sum(bw2 ,'all') >= 1200
        step = '붉은점 회전2';
        %disp(step)
        turn(drone,deg2rad(-85));
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        step='2-2 각도 조정';
        %disp(step)
        [angles,time]= readOrientation(drone);
        
        
        while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
            [angles,time]= readOrientation(drone);
        end
        
        if angles(1)<0
            turn(drone,-pi-(angles(1)-ref_angle));
        elseif angles(1)>0
            turn(drone,pi-(angles(1)-ref_angle));
        end
        
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        moveforward(drone, 'Distance', 1 ,'WaitUntilDone',true); % 탈출
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        break
    elseif sum(bw2 ,'all') >= 100
        step = '붉은점 전진';
        %disp(step)
        moveforward(drone, 'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
    else
        step = '붉은점 후퇴';
        %disp(step)
        moveback(drone, 'Distance',0.2,'WaitUntilDone',true);
        %% 붉은점 상/하 조정
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        img = snapshot(cam);
        
        bw = d_red_detection(img);
        bw2 =bwareafilt(bw,1); % 가장 큰점 인식
        
        subplot(1,2,1)
        subimage(bw)
        subplot(1,2,2)
        subimage(bw2)
        
        s = regionprops(bw_L,'centroid');
        if size(s)==[0 1]
            s = struct('Centroid',[240 110]);
            pause(0.3)
        end
        
        step = '붉은 점 상하 조정'
        error_y = 200-s.Centroid(2)
        
        if error_y>=-50 && error_y<=50
            error_y=0;
        else
            error_y=error_y+0;
        end
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        if error_y>0 %
            moveup(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        elseif error_y<0
            movedown(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        else
        end
        
        %% 붉은 점2 좌/우 조정
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        img = snapshot(cam);
        
        bw = d_red_detection(img);
        bw2 =bwareafilt(bw,1); % 가장 큰거 긴식
        
        subplot(1,2,1)
        subimage(bw)
        subplot(1,2,2)
        subimage(bw2)
        
        s = regionprops(bw_L,'centroid');
        if size(s)==[0 1]
            s = struct('Centroid',[480 200]);
            pause(0.3)
        end
        
        step = '붉은 점 좌/우 조정';
        %disp(step)
        error_x = -480+s.Centroid(1)
        
        if error_x>=-100 && error_x<=100
            error_x=0;
        else
            error_x=error_x+0;
        end
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        if error_x>0 %
            moveright(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        elseif error_x<0
            moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        else
            
        end
        
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    end
end
%% 2-2 각도 조정
pause(3)
step='2-2 각도 조정';
%disp(step)
[angles,time]= readOrientation(drone);

while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
    [angles,time]= readOrientation(drone);
end

if angles(1)<0
    turn(drone,-pi-(angles(1)-ref_angle));
elseif angles(1)>0
    turn(drone,pi-(angles(1)-ref_angle));
end

pause(3)
%% 높이 기준값

[height,time] = readHeight(drone);

while size(height) == [0 1]
    [height,time] = readHeight(drone);
end

sense_height = height;
if sense_height> ref_height
    
    ref_height = ref_height;
elseif sense_height< ref_height
    ref_height = ref_height+0.2;
end


%% 고도 조정
while 1
    
    [height,time] = readHeight(drone);
    
    while size(height) == [0 1]
        [height,time] = readHeight(drone);
    end
    
    sense_height = height;
    error_height = ref_height-sense_height;
    
    if error_height>=0.2
        moveup(drone, 'Distance', 0.3,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_height<=-0.2
        
        movedown(drone, 'Distance', 0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        %disp('위치 조정 끝')
    end
    
    [height,time] = readHeight(drone);
    while size(height) == [0 1]
        [height,time] = readHeight(drone);
    end
    
    sense_height = height;
    
    error_height = ref_height-sense_height;
    
    if error_height<=0.2 && error_height>=-0.2
        break
    end
    
end
%% 3번째 링 못찾을 때
while 1
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    
    if sum(bwim,'all')<=1000 || sum(bw_L,'all')>=150000  % 臾쇱껜 媛  ? 紐삵   ?   ?   ?  ?
        moveright(drone, 'Distance',0.6,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
end

%% 2-3 각도 조정
pause(3)
step='2-3 각도 조정';
%disp(step)
[angles,time]= readOrientation(drone);

while size(angles) ==[0 3] % 각도가 측정 되지 않는다면
    [angles,time]= readOrientation(drone);
end

if angles(1)<0
    turn(drone,-pi-(angles(1)-ref_angle));
elseif angles(1)>0
    turn(drone,pi-(angles(1)-ref_angle));
end

pause(3)



%% @@@@@@@@@@@@@@@@@@@@@@@@@@3단계@@@@@@@@@@@@@@@@@@@@@@@@@@

%% 상하 3-1
while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    
    subplot(1,2,1)
    subimage(img2)
    subplot(1,2,2)
    subimage(bw_L)
    
    
    step = '상하3-1'
    error_y = 115-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end
%% 좌우 3-1
while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    
    subplot(1,2,1)
    subimage(img2)
    subplot(1,2,2)
    subimage(bw_L)
    
    step = '좌 우 3-1'
    error_x = s.Centroid(1)-240
    
    if error_x>=-30 && error_x<=30
        error_x=0;
    else
        error_x=error_x+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(1)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_x>0 %
        moveright(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(1)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
    elseif error_x<0
        moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end
%% 상/하  3-2
while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    
    
    step = '상/하  3-2'
    
    subplot(1,2,1)
    subimage(img2)
    subplot(1,2,2)
    subimage(bw_L)
    error_y = 115-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0 %
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end
%% 좌/우  3-2
while 1
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    
    bwJ = imerode(bw,SE2);
    bwim= imclose(bwJ,SE1);
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 110]);
        pause(0.3)
    end
    
    subplot(1,2,1)
    subimage(img2)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_x = s.Centroid(1)-240
    
    step = '좌/우   3-2'
    
    if error_x>=-30 && error_x<=30
        error_x=0;
    else
        error_x=error_x+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_x>0 %
        moveright(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_x<0
        moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end
%% 상하3-3
while 1
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    while size(img) == [0 0 3]
        
        pause(0.4)
        img = snapshot(cam);
    end
    img2 = imresize(img,0.5);
    img2(1,:)=0;
    img2(:,1)=0;
    img2(:,480) =0;
    img2(360,:)=0;
    
    bw = d_green_detection(img2);
    bw2 =bwareafilt(bw,1);
    
    bwJ = imerode(bw2,SE2);
    bwim= imclose(bwJ,SE1);
    bwim =imdilate(bwim,SE1);
    
    edgee = edge(bwim,'Canny');
    
    [B,L,n,A]  = bwboundaries(edgee,8);
    bw_L =(L==max(L(:)));
    s = regionprops(bw_L,'centroid');
    if size(s)==[0 1]
        s = struct('Centroid',[240 115]);
        pause(0.3)
    end
    
    step = '상하3-2';
    %disp(step)
    
    subplot(1,2,1)
    subimage(edgee)
    subplot(1,2,2)
    subimage(bw_L)
    
    error_y = 115-s.Centroid(2)
    
    if error_y>=-20 && error_y<=20
        error_y=0;
    else
        error_y=error_y+0;
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if error_y>0 %
        moveup(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    elseif error_y<0
        movedown(drone,'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
end
%% 전진 3
while 1
    step = '전진 3'
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    
    bw = d_green_detection(img);
    
    bw2 = imerode(bw,SE2);
    bw3 =bwareafilt(bw2,1);
    
    subplot(1,2,1)
    subimage(bw)
    subplot(1,2,2)
    subimage(bw3)
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if sum(bw3, 'all') >= 500
        moveforward(drone, 'Distance', 0.6,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        break
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    pause(1)
end
%% 파랑 색
while 1
    step = '파랑색  '
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    img = snapshot(cam);
    
    bw = d_blue_detection(img);
    bw2 =bwareafilt(bw,1); % 가장 큰것만 인식
    
    subplot(1,2,1)
    subimage(img)
    subplot(1,2,2)
    subimage(bw2)
    
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
    
    if sum(bw2 ,'all') >= 1500
        break
    elseif sum(bw2 ,'all') <= 50
        step = '파랑색 후퇴'
        moveback(drone, 'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        img = snapshot(cam);
        
        bw = d_blue_detection(img);
        bw2 =bwareafilt(bw,1); % 가장 큰점 인식
        
        subplot(1,2,1)
        subimage(bw)
        subplot(1,2,2)
        subimage(bw2)
        
        s = regionprops(bw_L,'centroid');
        if size(s)==[0 1]
            s = struct('Centroid',[240 110]);
            pause(0.3)
        end
        
        step = '붉은 점 상하 조정'
        error_y = 200-s.Centroid(2)
        
        if error_y>=-50 && error_y<=50
            error_y=0;
        else
            error_y=error_y+0;
        end
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        if error_y>0 %
            moveup(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        elseif error_y<0
            movedown(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        else
        end
        
        %% 붉은 점2 좌/우 조정
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        img = snapshot(cam);
        
        bw = d_blue_detection(img);
        bw2 =bwareafilt(bw,1); % 가장 큰거 긴식
        
        subplot(1,2,1)
        subimage(bw)
        subplot(1,2,2)
        subimage(bw2)
        
        s = regionprops(bw_L,'centroid');
        if size(s)==[0 1]
            s = struct('Centroid',[480 200]);
            pause(0.3)
        end
        
        step = '붉은 점 좌/우 조정';
        %disp(step)
        error_x = -480+s.Centroid(1)
        
        if error_x>=-100 && error_x<=100
            error_x=0;
        else
            error_x=error_x+0;
        end
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
        
        if error_x>0 %
            moveright(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        elseif error_x<0
            moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
            while 1 % 속도가 0이 될때 까지 지연
                [speed,time] = readSpeed(drone);
                if sum(speed) ~= 0
                    
                    %disp(speed)
                    pause(0.4)
                else
                    %disp('**')
                    %disp(speed)
                    break
                end
            end
        else
            
        end
        
        
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    else
        moveforward(drone, 'Distance',0.2,'WaitUntilDone',true);
        while 1 % 속도가 0이 될때 까지 지연
            [speed,time] = readSpeed(drone);
            if sum(speed) ~= 0
                
                %disp(speed)
                pause(0.4)
            else
                %disp('**')
                %disp(speed)
                break
            end
        end
    end
    while 1 % 속도가 0이 될때 까지 지연
        [speed,time] = readSpeed(drone);
        if sum(speed) ~= 0
            
            %disp(speed)
            pause(0.4)
        else
            %disp('**')
            %disp(speed)
            break
        end
    end
end

land(drone);
[angles,time]= readOrientation(drone);
end_time=time;
duration = end_time - start_time
%% d_green_detection
function [BW,maskedRGBImage] = d_green_detection(RGB)

I = rgb2hsv(RGB);

channel1Min = 0.226;
channel1Max = 0.316;

channel2Min = 0.174;
channel2Max = 1.000;

channel3Min = 0.128;
channel3Max = 1.000;

sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

maskedRGBImage = RGB;

maskedRGBImage(repmat(~BW,[1 1 3])) = 0;


end
%% d_red_detection
function [BW,maskedRGBImage] = d_red_detection(RGB)

I = rgb2hsv(RGB);

channel1Min = 0.951;
channel1Max = 0.039;

channel2Min = 0.172;
channel2Max = 1.000;

channel3Min = 0.000;
channel3Max = 1.000;

sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

maskedRGBImage = RGB;

maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
%% d_blue_detection
function [BW,maskedRGBImage] =  d_blue_detection(RGB)

I = rgb2hsv(RGB);

channel1Min = 0.561;
channel1Max = 0.633;

channel2Min = 0.118;
channel2Max = 1.000;

channel3Min = 0.000;
channel3Max = 1.000;

sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

maskedRGBImage = RGB;

maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
