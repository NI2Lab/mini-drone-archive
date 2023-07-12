%국민대통합






count = 0;                              % 전진 여부 확인 변수
center_point = [480,240];               % 사각형 중심점이 center_point와 일치해야 통과
centroid = zeros(size(center_point));   % 사각형 중심점

drone = ryze();                         
cam = camera(drone);
takeoff(drone);

moveback(drone,'Distance',0.5,'Speed',1);   % 사각형 전체 한 번에 인식하기 위해 뒤로 이동
  
% 1st stage
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue

        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=35 && abs(dis(2))<=35)    % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 3
    elseif(dis(2)<=0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 5
    elseif(dis(2)>0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
    
    % 중심 찾음; 이동 거리 계산
    if count == 1
        disp('Moving...');

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blue = (0.535<h)&(h<0.69)&(0.4<s)&(v>0.1)&(v<0.97);
        
        blue(1,:) = 1;
        blue(720,:) = 1;
        bw = imfill(blue,'holes');
        for x=1:720
            for y=1:size(blue,2)
                if blue(x,y)==bw(x,y)
                    bw(x,y)=0;
                end
            end
        end
        
        % 속성 측정; 장축 길이 값 추출
        stats = regionprops('table',bw,'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);
        
        % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw,'all') <= 10000
            moveforward(drone, 'Distance', 2, 'Speed', 1);
            
        elseif longAxis > 860
            moveforward(drone, 'Distance', 2, 'Speed', 1);
            
        else
            distance = (3E-06)*(longAxis)^2 - 0.0065*longAxis + 4.3399; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance + 1, 'Speed', 1);   % 링과 표식 사이 거리의 절반만큼 추가 이동
            distance
        end

        break;
    end
end

disp('1st Stage Finish');
turn(drone, deg2rad(90));   % 1단계 통과 후 90도 회전
moveback(drone,'Distance',1,'Speed',1);   % 사각형 전체 한 번에 인식하기 위해 뒤로 이동   
count = 0; 

%2nd stage
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 영상 영역의 속성 측정; BoundingBox, Area, Centroid 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue

        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=35 && abs(dis(2))<=35)    % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

     % case 3
     elseif(dis(2)<=0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

     % case 5
     elseif(dis(2)>0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
   
    % 중심 찾음; 이동 거리 계산
    if count == 1
        disp('Moving...');

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blue = (0.535<h)&(h<0.69)&(0.4<s)&(v>0.1)&(v<0.97);
        
        blue(1,:) = 1;
        blue(720,:) = 1;
        bw = imfill(blue,'holes');       
        for x=1:720
            for y=1:size(blue,2)
                if blue(x,y)==bw(x,y)
                    bw(x,y)=0;
                end
            end
        end
        
        % 속성 측정; 장축의 길이 값 추출
        stats = regionprops('table',bw,'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);
        
        % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw,'all') <= 10000
            moveforward(drone, 'Distance', 2.2, 'Speed', 1);
            
        elseif longAxis > 860
            moveforward(drone, 'Distance', 2.2, 'Speed', 1); %1.2m+1m
            
        else
            distance = (3E-06)*(longAxis)^2 - 0.0065*longAxis + 4.3399; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance + 1, 'Speed', 1);   % 링과 표식 사이 거리의 절반만큼 추가 이동
            distance
        end

        break;
    end
end

disp('2nd Stage Finish');
turn(drone, deg2rad(90));   % 2단계 통과 후 90도 회전
moveback(drone,'Distance',1,'Speed',1);   % 사각형 전체 한 번에 인식하기 위해 뒤로 이동
count = 0;

%3rd stage
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 영상 영역의 속성 측정; BoundingBox, Area, Centroid 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue

        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end
    
    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=33 && abs(dis(2))<=33)    % x 좌표 차이, y 좌표 차이가 33보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=33 && abs(dis(1))>33)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

     % case 3
     elseif(dis(2)<=0 && abs(dis(2))>33)
        if(dis(1)<=0 && abs(dis(1))>33)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>33)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=33)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=33)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=33 && abs(dis(1))>33)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

     % case 5
     elseif(dis(2)>0 && abs(dis(2))>33)
        if(dis(1)<=0 && abs(dis(1))>33)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>33)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=33)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=33)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
    
    % 중심 찾음; 이동 거리 계산
    if count == 1
        disp('Moving...');
        
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blue = (0.535<h)&(h<0.69)&(0.4<s)&(v>0.1)&(v<0.97);
        
        blue(1,:) = 1;
        blue(720,:) = 1;
        bw = imfill(blue,'holes');        
        for x=1:720
            for y=1:size(blue,2)
                if blue(x,y)==bw(x,y)
                    bw(x,y)=0;
                end
            end
        end
        
        % 속성 측정; 장축의 길이 값 추출
        stats = regionprops('table',bw,'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);
        
        % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw,'all') <= 10000
            moveforward(drone, 'Distance', 1.7, 'Speed', 1);
            
        elseif longAxis > 860
            moveforward(drone, 'Distance', 1.7, 'Speed', 1); %1.2m+0.5m
            
        else
            distance = (7E-06)*(longAxis)^2 - 0.0102*longAxis + 4.5856; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance + 0.8, 'Speed', 1); % 링과 표식 사이 거리의 절반만큼 추가 이동
            distance
        end

        break;
    end
end

disp('3rd Stage Finish');
turn(drone, deg2rad(30));   % 3단계 통과 후 30도 회전
count=0;

% 4th stage

% 5도씩 회전하며 탐색
max_sum = 0;

for level = 1:7
    if level > 1
        turn(drone, deg2rad(5));
    end

    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    sumblueNemo = sum(sum(blueNemo));

    if sumblueNemo > max_sum
        max_sum = sumblueNemo;
        maxlevel = level;
    end
end


% 최적 각도
angle = (-1) * 5 * (7 - maxlevel);
turn(drone, deg2rad(angle));


while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 영상 영역의 속성 측정; BoundingBox, Area, Centroid 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue

        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end
    
    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=35 && abs(dis(2))<=35)    % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

     % case 3
     elseif(dis(2)<=0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

     % case 5
     elseif(dis(2)>0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
    
    % 중심 찾음; 이동 거리 계산
    if count == 1
        disp('Moving...');

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blue = (0.535<h)&(h<0.69)&(0.4<s)&(v>0.1)&(v<0.97);
        
        blue(1,:) = 1;
        blue(720,:) = 1;
        bw = imfill(blue,'holes');        
        for x=1:720
            for y=1:size(blue,2)
                if blue(x,y)==bw(x,y)
                    bw(x,y)=0;
                end
            end
        end
        
        % 속성 측정; 장축의 길이 값 추출
        stats = regionprops('table',bw,'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);
                
        % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw,'all') <= 10000
            moveforward(drone, 'Distance', 0.2, 'Speed', 1);
            
        elseif longAxis > 460
            moveforward(drone, 'Distance', 0.2, 'Speed', 1);
            
        else
            distance = (1E-05)*(longAxis)^2 - 0.0124*longAxis + 4.5996; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance - 0.8, 'Speed', 1);   % 링과 표식 사이 거리의 절반만큼 추가 이동
            distance
            
        end

        break;
    end
end

disp('4th Stage Finish');
disp('Mission Complete!');
land(drone);
