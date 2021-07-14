clear;

% 드론 설정
drone = ryze()
cam = camera(drone)

originCenter = [480 170; 480 170; 480 170;];
count = 0;
max = 0;
none = 0;

takeoff(drone);

hold on
for level = 1 : 3
   
    while 1
        %파란색에 대한 RGB값 설정 및 이진화
        frame = snapshot(cam);
        figure(1)
        imshow(frame)
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    justGreen = G - R/2 - B/2;
    justRed = R - G/2 - B/2;
    justBlue = B - G/2 - R/2;
    bw = justGreen > 40; 
    bwred = justRed > 55;
    blue = justBlue > 55;
        
        
        % 첫행 1로 변환
        for i = 1 : 960 
            blue(1, i) = 1;
        end
        
        % 마지막 행을 1로 변환
        for i = 1 : 960
           blue(720, i) = 1; 
        end
        
        
        %구멍을 채움
        bw2 = imfill(blue,'holes');
        figure(2)
        imshow(bw2)
        %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
        for x=1:720
            for y=1:960
                if blue(x,y)==bw2(x,y)
                    bw2(x,y)=0;
                end
            end
        end
        
            figure(3)
            imshow(bw2)
        %변환한 이미지의 픽셀 수가 500이상이면 구멍을 인식했다고 파악
        %500이하이면 상승하여 전 과정을 다시 반복
        if sum(bw2,'all')>500
            break;
        else
            

            %화면의 좌우를 비교
            if sum(imcrop(blue,[0 0 480 720]),'all')-sum(imcrop(blue,[480 0 960 720]),'all')>10000
                moveleft(drone,'distance',0.2,'speed',0.5);
            elseif sum(imcrop(blue,[480 0 960 720]),'all')-sum(imcrop(blue,[0 0 480 720]),'all')>10000
                moveright(drone,'distance',0.2,'speed',0.5);
            end
            
            if sum(imcrop(blue,[0 0 960 360]),'all')-sum(imcrop(blue,[0 360 960 720]),'all')>10000
                moveup(drone,'distance',0.2,'speed',0.5);
            elseif sum(imcrop(blue,[0 360 960 720]),'all')-sum(imcrop(blue,[0 0 960 360]),'all')>10000
                movedown(drone,'distance',0.2,'speed',0.5);
            end
            
             if sum(blue,'all')<10000
                 if none==0
                 moveup(drone,'distance',0.2,'speed',0.5);
                 moveleft(drone,'distance',0.2,'speed',0.5);
                 none=none+1;
                 elseif none==1
                 moveright(drone,'distance',0.2,'speed',0.5);
                 end
             end 
        end      
    end % end of while
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
     %구멍에 대한 중점 찾기
    while 1
        frame = snapshot(cam);
        figure(4)
        imshow(frame)
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    justGreen = G - R/2 - B/2;
    justRed = R - G/2 - B/2;
    justBlue = B - G/2 - R/2;
    bw = justGreen > 40; 
    bwred = justRed > 55;
    blue = justBlue > 55;
        
        
        % 첫행 1로 변환
        for i = 1 : 960 
            blue(1, i) = 1;
        end
        
        % 마지막 행을 1로 변환
        for i = 1 : 960
           blue(720, i) = 1; 
        end
        
        
        %구멍을 채움
        bw2 = imfill(blue,'holes');
        figure(5)
        imshow(bw2)
        %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
        for x=1:720
            for y=1:960
                if blue(x,y)==bw2(x,y)
                    bw2(x,y)=0;
                end
            end
        end
        
      
        %이미지에서 인식된 곳들의 중점과 보조축의 크기를 구함
        stats = regionprops('table',bw2, 'Centroid', 'MinorAxisLength');
        z=stats.MinorAxisLength;
        max=0;
        y=stats.Centroid;
        %보조축의 크기가 가장 큰 곳의 중점을 가져옴
        for i=1:size(stats)
            if z(i,1)>=max
                max=z(i,1);
                firstCenter(1,1)=round(y(i,1));
                firstCenter(1,2)=round(y(i,2));
            end
        end
        clearvars max
        
        %측정된 중점과 이상 중점을 비교하여 이동
        if firstCenter(1,1)-originCenter(level,1)>=40
            moveright(drone,'Distance',0.3,'speed',1);
        elseif firstCenter(1,1)-originCenter(level,1)<=-40
            moveleft(drone,'Distance',0.2,'speed',1);
        end
        if firstCenter(1,2)-originCenter(level,2)>=30
            movedown(drone,'Distance',0.3,'speed',1);
        elseif firstCenter(1,2)-originCenter(level,2)<=-30
            moveup(drone,'Distance',0.2,'speed',1);
        end
        %오차범위 내에 있으면 반복문 탈출
        if firstCenter(1,2)-originCenter(level,2)<30 && firstCenter(1,2)-originCenter(level,2)>-30 && firstCenter(1,1)-originCenter(level,1)<40 && firstCenter(1,1)-originCenter(level,1)>-40
            break;
        end
    end
    
    %=========================================== 이거 hsv로 표현된 빨간색 건드림
    
    %1단계 및 2단계일 때 실행
    if level==1||level==2
        if level==1
            moveforward(drone,'Distance',2.3,'speed',1);
        elseif level==2
            moveforward(drone,'Distance',2.3,'speed',1);
        end
        
        %빨간점 찾기
        while 1
            %빨간색에 대한 RGB값 설정 및 이진화
        frame = snapshot(cam);
        figure(6)
        imshow(frame)
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    justGreen = G - R/2 - B/2;
    justRed = R - G/2 - B/2;
    justBlue = B - G/2 - R/2;
    bw = justGreen > 40; 
    red = justRed > 55;
    blue = justBlue > 55;
            
            
            %빨간색의 픽셀이 400이 넘으면 90도 회전
            if sum(red,'all')> 430
                if count==1
                    moveforward(drone,'distance',0.5);
                    count=0;
                end
                turn(drone,deg2rad(-90))
                moveforward(drone,'distance',0.5,'speed',1); % 우리가 한 것
                break;
            else
                moveback(drone,'distance',0.2)
                count=1;
            end
        end % end of while
        


        % 3단계일 때 실행

    elseif level==3
        
        %=======================================
        
    while 1
        %파란색에 대한 RGB값 설정 및 이진화
        frame = snapshot(cam);
        figure(1)
        imshow(frame)
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    justGreen = G - R/2 - B/2;
    justRed = R - G/2 - B/2;
    justBlue = B - G/2 - R/2;
    bw = justGreen > 40; 
    bwred = justRed > 55;
    blue = justBlue > 55;
        
        
        % 첫행 1로 변환
        for i = 1 : 960 
            blue(1, i) = 1;
        end
        
        % 마지막 행을 1로 변환
        for i = 1 : 960
           blue(720, i) = 1; 
        end
        
        
        %구멍을 채움
        bw2 = imfill(blue,'holes');
        figure(2)
        imshow(bw2)
        %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
        for x=1:720
            for y=1:960
                if blue(x,y)==bw2(x,y)
                    bw2(x,y)=0;
                end
            end
        end
        
            figure(3)
            imshow(bw2)
        %변환한 이미지의 픽셀 수가 500이상이면 구멍을 인식했다고 파악
        %500이하이면 상승하여 전 과정을 다시 반복
        if sum(bw2,'all')>500
            break;
        else
            

            %화면의 좌우를 비교
            if sum(imcrop(blue,[0 0 480 720]),'all')-sum(imcrop(blue,[480 0 960 720]),'all')>10000
                moveleft(drone,'distance',0.2,'speed',0.5);
            elseif sum(imcrop(blue,[480 0 960 720]),'all')-sum(imcrop(blue,[0 0 480 720]),'all')>10000
                moveright(drone,'distance',0.2,'speed',0.5);
            end
            
            if sum(imcrop(blue,[0 0 960 360]),'all')-sum(imcrop(blue,[0 360 960 720]),'all')>10000
                moveup(drone,'distance',0.2,'speed',0.5);
            elseif sum(imcrop(blue,[0 360 960 720]),'all')-sum(imcrop(blue,[0 0 960 360]),'all')>10000
                movedown(drone,'distance',0.2,'speed',0.5);
            end
            
             if sum(blue,'all')<10000
                 if none==0
                 moveup(drone,'distance',0.2,'speed',0.5);
                 moveleft(drone,'distance',0.2,'speed',0.5);
                 none=none+1;
                 elseif none==1
                 moveright(drone,'distance',0.2,'speed',0.5);
                 end
             end 
        end      
    end % end of while
        %%===================================================
        
             %구멍에 대한 중점 찾기
    while 1
        frame = snapshot(cam);
        figure(4)
        imshow(frame)
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    justGreen = G - R/2 - B/2;
    justRed = R - G/2 - B/2;
    justBlue = B - G/2 - R/2;
    bw = justGreen > 40; 
    bwred = justRed > 55;
    blue = justBlue > 55;
        
        
        % 첫행 1로 변환
        for i = 1 : 960 
            blue(1, i) = 1;
        end
        
        % 마지막 행을 1로 변환
        for i = 1 : 960
           blue(720, i) = 1; 
        end
        
        
        %구멍을 채움
        bw2 = imfill(blue,'holes');
        figure(5)
        imshow(bw2)
        %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
        for x=1:720
            for y=1:960
                if blue(x,y)==bw2(x,y)
                    bw2(x,y)=0;
                end
            end
        end
        
      
        %이미지에서 인식된 곳들의 중점과 보조축의 크기를 구함
        stats = regionprops('table',bw2, 'Centroid', 'MinorAxisLength');
        z=stats.MinorAxisLength;
        max=0;
        y=stats.Centroid;
        %보조축의 크기가 가장 큰 곳의 중점을 가져옴
        for i=1:size(stats)
            if z(i,1)>=max
                max=z(i,1);
                firstCenter(1,1)=round(y(i,1));
                firstCenter(1,2)=round(y(i,2));
            end
        end
        clearvars max
        
        %측정된 중점과 이상 중점을 비교하여 이동
        if firstCenter(1,1)-originCenter(level,1)>=40
            moveright(drone,'Distance',0.3,'speed',1);
        elseif firstCenter(1,1)-originCenter(level,1)<=-40
            moveleft(drone,'Distance',0.2,'speed',1);
        end
        if firstCenter(1,2)-originCenter(level,2)>=30
            movedown(drone,'Distance',0.3,'speed',1);
        elseif firstCenter(1,2)-originCenter(level,2)<=-30
            moveup(drone,'Distance',0.2,'speed',1);
        end
        %오차범위 내에 있으면 반복문 탈출
        if firstCenter(1,2)-originCenter(level,2)<30 && firstCenter(1,2)-originCenter(level,2)>-30 && firstCenter(1,1)-originCenter(level,1)<40 && firstCenter(1,1)-originCenter(level,1)>-40
            break;
        end
    end
        
        
        
        %%=================================================
        
        
        %===================================================
        moveforward(drone,'Distance',2.5,'speed',1);
        

        %파란점 찾기
        while 1
            %파란색에 대한 HSV값 설정 및 이진화

        frame = snapshot(cam);
        figure(6)
        imshow(frame)
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    justGreen = G - R/2 - B/2;
    justRed = R - G/2 - B/2;
    justBlue = B - G/2 - R/2;
    bw = justGreen > 40; 
    red = justRed > 55;
    blue = justBlue > 55;


            %의 픽셀이 300이 넘으면 착륙
            
            if sum(red,'all') > 110 
                if count==1
                    moveforward(drone,'distance',0.2);
                    count=0;
                end
                land(drone);
                break;
            else

                moveback(drone,'distance',0.2)
                count=1;
            end
        end
    end
    
    
%     end % end of for
 end