clear;
%드론 설정 및 takeoff
drone=ryze(); 
cam=camera(drone);
originCenter=[480 170; 480 170; 480 170];
count=0;
max=0;
none=0;
takeoff(drone);
%총 3단계로 설정
for level=1:3
    %구멍 찾기
    while 1
        %초록색에 대한 HSV값 설정 및 이진화
        frame=snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        green=(0.2<h)&(h<0.5)&(0.5<s)&(s<0.9);
        %첫 행을 1로 변환
        for i=1:960
        green(1,i)=1;
        end
        %마지막 행을 1로 변환
        for i=1:960
        green(720,i)=1;
        end
        %구멍을 채움
        bw2 = imfill(green,'holes');
        %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
        for x=1:720
            for y=1:960
                if green(x,y)==bw2(x,y)
                    bw2(x,y)=0;
                end
            end
        end
        %변환한 이미지의 픽셀 수가 1000이상이면 구멍을 인식했다고 파악
        %1000이하이면 상승하여 전 과정을 다시 반복
        if sum(bw2,'all')>1000
            break;
        else
            %화면의 좌우를 비교
            if sum(imcrop(green,[0 0 480 720]),'all')-sum(imcrop(green,[480 0 960 720]),'all')>10000
                moveleft(drone,'distance',0.5,'speed',1);
            elseif sum(imcrop(green,[480 0 960 720]),'all')-sum(imcrop(green,[0 0 480 720]),'all')>10000
                moveright(drone,'distance',0.5,'speed',1);
            end
            if sum(imcrop(green,[0 0 960 360]),'all')-sum(imcrop(green,[0 360 960 720]),'all')>10000
                moveup(drone,'distance',0.4,'speed',1);
            elseif sum(imcrop(green,[0 360 960 720]),'all')-sum(imcrop(green,[0 0 960 360]),'all')>10000
                movedown(drone,'distance',0.4,'speed',1);
            end
            if sum(green,'all')<10000
                if none==0
                moveup(drone,'distance',0.3,'speed',1);
                moveleft(drone,'distance',0.3,'speed',1);
                none=none+1;
                elseif none==1
                moveright(drone,'distance',1,'speed',1);
                end
            end 
        end
    end
    %구멍에 대한 중점 찾기
    while 1
        %초록색에 대한 HSV값 설정 및 이진화
        frame=snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        green=(0.2<h)&(h<0.5)&(0.5<s)&(s<0.9);
        %첫 행을 1로 변환
        for i=1:960
            green(1,i)=1;
        end
        %마지막 행을 1로 변환
        for i=1:960
            green(720,i)=1;
        end
        %구멍을 채움
        bw2 = imfill(green,'holes');
        %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
        for x=1:720
            for y=1:960
                if green(x,y)==bw2(x,y)
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
    %1단계 및 2단계일 때 실행
    if level==1||level==2
        if level==1
            moveforward(drone,'Distance',2.6,'speed',1);
        elseif level==2
            moveforward(drone,'Distance',2.4,'speed',1);
        end
        %빨간점 찾기
        while 1
            %빨간색에 대한 HSV값 설정 및 이진화
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            red= ((0.95<h)&(h<1)|(0<h)&(h<0.05))&(0.8<s)&(s<=1);
            %빨간색의 픽셀이 400이 넘으면 90도 회전
            if sum(red,'all')>400
                if count==1
                    moveforward(drone,'distance',0.2);
                    count=0;
                end
                turn(drone,deg2rad(-90))
                break;
            else
                moveback(drone,'distance',0.2)
                count=1;
            end
        end
        %가운데 아래를 기준으로 하기위한 제어
        if level==1
            moveforward(drone,'Distance',0.8,'speed',1);
        elseif level==2
            moveforward(drone,'distance',1,'speed',1);
        end
        %3단계일 때 실행
    elseif level==3
        moveforward(drone,'Distance',2.2,'speed',1);
        %파란점 찾기
        while 1
            %파란색에 대한 HSV값 설정 및 이진화
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            blue= (0.55<h)&(h<0.8)&(0.8<s)&(s<=1);
            %파란색의 픽셀이 300이 넘으면 90도 회전
            if sum(blue,'all')>300
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
end
