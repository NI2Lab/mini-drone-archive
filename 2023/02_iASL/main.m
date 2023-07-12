
clear, clc;

%드론 설정 및 takeoff
drone=ryze()
cam=camera(drone);
preview(cam);
back_cnt = 1;
ccheck = 0;
originCenter=[480 168];
count=0;
max_r=0;
none=0;
cnt = 0;
newjeans = 0;
hsv_purple = [0.71 0.79 0.5 0.9];
hsv_blue = [0.55 0.7 0.5 0.9];
warigari = 1;
a = -0.6;
takeoff(drone);

%%preview(cam);
for level = 1:4
    disp("level change")
    originCenter=[480 168];


    if level == 1
        moveup(drone, 'distance', 0.35)
    end

    %% finding hole
    while 1

        if level == 1
            break;
        end

        %파란색에 대한 HSV값 설정 및 이진화
        frame=snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blue=(0.55<h)&(h<0.7)&(0.5<s)&(s<0.9);

        % 첫 행을 1로 변환
        blue(1,:) = 1;


        % 마지막 행을 1로 변환
        blue(720,:) = 1;

        %구멍을 채움
        bw2 = imfill(blue,'holes');

        %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
        for x=1:720
            for y=1:size(blue,2)
                if blue(x,y)==bw2(x,y)
                    bw2(x,y)=0;
                end
            end
        end

        %변환한 이미지의 픽셀 수가 1000이상이면 구멍을 인식했다고 파악
        %1000이하이면 상승하여 전 과정을 다시 반복
        if sum(bw2,'all')>10000
            disp('find hole!');
            break;

        else
            %화면의 좌우를 비교
            diff_lr = sum(imcrop(blue,[0 0 480 720]),'all') - sum(imcrop(blue,[480 0 960 720]),'all');
            diff_ud = sum(imcrop(blue,[0 0 960 360]),'all') - sum(imcrop(blue,[0 360 960 720]),'all');
            disp(diff_lr);
            disp(diff_ud);
            if diff_lr > 30000
                if level ==4
                    turn(drone,deg2rad(-5));
                    disp('잡았다 반시계')
                else
                    moveleft(drone,'distance',0.5,'speed',1);
                    disp('finding hole_move_left 0.5m');
                end
            elseif diff_lr < -30000
                if level ==4
                    turn(drone,deg2rad(5));
                    disp('잡았다 시계')
                else
                    moveright(drone,'distance',0.4,'speed',1);
                    disp('finding hole_move_right 0.4m');
                end
            end

            if diff_ud > 10000
                moveup(drone,'distance',0.3,'speed',1);
                disp('finding hole_move_up_0.3m');
            elseif diff_ud < -10000
                movedown(drone,'distance',0.2,'speed',1);
                disp('finding hole_move_down_0.2m');
            end

            % 사진 찍어서 noise 및 diff_ud 확인
            if sum(blue,'all') < 3000
                if none==0
                    if diff_ud >= 0
                        moveup(drone,'distance',0.4,'speed',1);
                        disp('Cannot find barrier_moving_up');
                    else
                        movedown(drone,'distance',0.2,'speed',1);
                        disp('Cannot find barrier_moving_down');
                    end

                    moveleft(drone,'distance',1,'speed',1);
                    disp('Cannot find barrier_moving_left_1m');
                    none = none+1;

                elseif none==1
                    moveright(drone,'distance',2.1,'speed',1);
                    disp('Cannot find barrier_moving_right_2.1m');
                    none = 2;
                end
            end
        end
    end


    %% find center point

    count_l = 0; count_r = 0; count_u = 0; count_d = 0; %*

    while 1
        if level == 1
            break;
        end
        if level == 2 || level ==3 || level == 4
            %파란색에 대한 HSV값 설정 및 이진화
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            blue=(0.55<h)&(h<0.7)&(0.5<s)&(s<0.9);

            %첫 행을 1로 변환
            blue(1,:)=1;

            %마지막 행을 1로 변환
            blue(720,:)=1;

            %구멍을 채움
            bw2 = imfill(blue,'holes');

            %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
            for x=1:720
                for y=1:size(blue,2)
                    if blue(x,y)==bw2(x,y)
                        bw2(x,y)=0;
                    end
                end
            end

            %이미지에서 인식된 곳들의 중점과 보조축의 크기를 구함
            stats = regionprops('table',bw2, 'Centroid', 'MinorAxisLength');
            z = stats.MinorAxisLength;
            max_r=0;
            y = stats.Centroid;

            while isempty(y) && cnt == 0;
                disp("333333333333333333333333333333333333333333333333")
                moveback(drone,'distance',0.2,'speed', 1)
                cnt =1;
            end
            %보조축의 크기가 가장 큰 곳의 중점을 가져옴
            for i=1:size(stats)
                if z(i,1)>=max_r
                    max_r=z(i,1);
                    firstCenter(1,1)=round(y(i,1));
                    firstCenter(1,2)=round(y(i,2));

                end
            end
            clearvars max

            %측정된 중점과 이상 중점을 비교하여 이동
            ct_diff_lr = firstCenter(1,1)-originCenter(1,1);
            ct_diff_ud = firstCenter(1,2)-originCenter(1,2);
            %disp(ct_diff_lr)
            % x 중점 찾기
            if ct_diff_lr >= 45 && ct_diff_lr <= 80
                if level == 4
                    turn(drone,deg2rad(5));
                else
                    moveright(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move right_0.2m');

                    count_r = count_r + 1; %*
                end

            elseif ct_diff_lr > 80
                if level == 4
                    turn(drone,deg2rad(10));
                else
                    moveright(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move right_0.3m');
                    count_r = count_r + 1; %*
                end
            elseif ct_diff_lr <= -45 && ct_diff_lr >= -80
                if level ==4
                    turn(drone,deg2rad(-5));
                else
                    moveleft(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move left_0.25m');
                    count_l = count_l + 1; %*
                end
            elseif ct_diff_lr < -80
                if level ==4
                    turn(drone,deg2rad(-10));
                else
                    moveleft(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move left _0.3m');
                    count_l = count_l + 1; %*
                end
            end

            % y 중점찾기
            if ct_diff_ud >= 35 && ct_diff_ud <= 75
                movedown(drone,'Distance',0.2,'speed',1);
                disp('finding center point_move down_0.2m');
                count_d = count_d + 1; %*

            elseif ct_diff_ud > 75
                movedown(drone,'Distance',0.2,'speed',1);
                disp('finding center point_move down_0.3m');
                count_d = count_d + 1; %*

            elseif ct_diff_ud <= -35 && ct_diff_ud >= -75
                moveup(drone,'Distance',0.2,'speed',1);
                disp('finding center point_move up_0.25m');
                count_u = count_u + 1; %*

            elseif ct_diff_ud < -75
                moveup(drone,'Distance',0.2,'speed',1);
                disp('finding center point_move up_0.3m');
                count_u = count_u + 1; %*
            end


            tmp = [count_l, count_r, count_u, count_d]; %*

            % 장애물이 가까워서 계속 같은 행동을 반복하는 loop에 갇힐 시 빠져나오기 위해 0.5m 뒤로 이동
            if max(tmp) >= 7 %*
                disp('a drone is in loop. moveback_0.5m'); %*
                disp("44444444444444444444444444444444444444444444444")
                moveback(drone, 'distance', 0.5); %*
                count_l=0; count_r=0; count_u=0; count_d=0; %*
            end %*

            %오차범위 내에 있으면 반복문 탈출
            if ct_diff_ud < 30 && ct_diff_ud > -30 && ct_diff_lr < 40 && ct_diff_lr > -40
                disp('find center point!');
                count_l=0; count_r=0; count_u=0; count_d=0; %*
                break;
            end
        end
    end
    %% find distance to barrier and moving
    %파란색에 대한 HSV값 설정 및 이진화
    frame = snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blue = (0.55<h)&(h<0.7)&(0.5<s)&(s<0.9);

    % 첫 행을 1로 변환
    blue(1,:) = 1;

    % 마지막 행을 1로 변환
    blue(720,:) = 1;

    %구멍을 채움
    bw2 = imfill(blue,'holes');

    %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
    for x=1:720
        for y=1:size(blue,2)
            if blue(x,y)==bw2(x,y)
                bw2(x,y)=0;
            end
        end
    end

    %이미지에서 인식된 곳들의 장축의 크기를 구함
    stats = regionprops('table', bw2, 'MajorAxisLength');
    long_rad = max(stats.MajorAxisLength);
    s = sum(bw2,'all');
    disp(s)
    md = [890 780 717 670 655 584 545 508 475 443 425 403 384 ; 890 780 717 670 655 584 545 508 475 443 425 403 384; 633 575 521 467 437 401 376 351 329 309 295 278 260 ; 425 409 385 370 360 351 338 322 316 305 294 287 280];

    %각 단게에서 long_rad의 값에 따라서 거리 추정
    if level == 1
        moveforward(drone, 'distance', 2.3, 'speed', 1);
        disp('측정 거리 = 1m');
        disp('이동거리 = 1.4m');
        long_rad

    elseif level==4
        while level==4
            disp("while")
            Center =[0 0];
            reward = 0;
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            blue=(0.55<h)&(h<0.7)&(0.5<s)&(s<0.9);

            % 첫 행을 1로 변환
            blue(1,:) = 1;


            % 마지막 행을 1로 변환
            blue(720,:) = 1;

            %구멍을 채움
            bw2 = imfill(blue,'holes');

            %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
            for x=1:720
                for y=1:size(blue,2)
                    if blue(x,y)==bw2(x,y)
                        bw2(x,y)=0;
                    end
                end
            end

            %변환한 이미지의 픽셀 수가 1000이상이면 구멍을 인식했다고 파악
            %1000이하이면 상승하여 전 과정을 다시 반복
            if sum(bw2,'all')>10000
                disp('find hole!');


            else
                %화면의 좌우를 비교
                diff_lr = sum(imcrop(blue,[0 0 480 720]),'all') - sum(imcrop(blue,[480 0 960 720]),'all');
                diff_ud = sum(imcrop(blue,[0 0 960 360]),'all') - sum(imcrop(blue,[0 360 960 720]),'all');
                disp(diff_lr);
                disp(diff_ud);
                if diff_lr > 30000
                    if level ==4
                        turn(drone,deg2rad(-5));
                        disp('잡았다 반시계')
                    else
                        moveleft(drone,'distance',0.5,'speed',1);
                        disp('finding hole_move_left 0.5m');
                    end
                elseif diff_lr < -30000
                    if level ==4
                        turn(drone,deg2rad(5));
                        disp('잡았다 시계')
                    else
                        moveright(drone,'distance',0.4,'speed',1);
                        disp('finding hole_move_right 0.4m');
                    end
                end


                % 사진 찍어서 noise 및 diff_ud 확인
                if sum(blue,'all') < 3000
                    if none==0
                        moveleft(drone,'distance',1,'speed',1);
                        disp('Cannot find barrier_moving_left_1m');
                        none = none+1;

                    elseif none==1
                        moveright(drone,'distance',2.1,'speed',1);
                        disp('Cannot find barrier_moving_right_2.1m');
                        none = 2;
                    end
                end
            end

            if ispurple(cam) == 0
                reward = 1;
                
                disp('reward = 1')
                if warigari == 1
                    disp('좌우이동 시작!')
                    moveforward(drone,'distance',1.0);
                    if ispurple(cam) == 0
                        disp("1번")
                        turn(drone,deg2rad(15));
                        moveleft(drone,'distance',0.3);
                        if ispurple(cam) == 0
                            disp("2번")
                            moveright(drone,'distance',0.3);
                            turn(drone,deg2rad(-15));
                            turn(drone,deg2rad(-15));
                            moveright(drone,'distance',0.3);
                        end
                        if ispurple(cam) == 0
                            disp("3번")
                            newjeans = 0;
                            moveleft(drone,'distance',0.3);
                            turn(drone,deg2rad(15));
                        else
                            disp("4번")
                            warigari = 0;
                        end
                    else
                        disp("5번")
                        warigari = 0;
                    end
                else
                    disp("6번")
                    warigari = 0;
                end
            
            end

            if ispurple(cam) == 1
                disp('보라색 찾음')
                %거리비교
                [x_pur,  y_pur] = find_center_other(cam,hsv_purple);
                [x_blu,  y_blu, long_rad] = find_center_blu(cam,hsv_blue);
                % disp(x_pur - x_blu)
                if abs(x_pur - x_blu) <= 1
                    disp("찾았다")
                    if long_rad > md(level,1)

                        moveaforward(drone, 'distance', 0.72+ a, 'speed', 1);
                        disp('측정 거리 = 1.22m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,2) && long_rad <= md(level,1)

                        moveforward(drone,'distance', 0.77+ a, 'speed',1);
                        disp('측정 거리 = 1.27m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,3) && long_rad <= md(level,2)

                        moveforward(drone, 'distance', 0.82+ a, 'speed', 1);
                        disp('측정 거리 = 1.32m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,4) && long_rad <= md(level,3)

                        moveforward(drone, 'distance', 0.87+ a, 'speed', 1);
                        disp('측정 거리 = 1.37m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,5) && long_rad <= md(level,4)

                        moveforward(drone, 'distance', 0.92+ a, 'speed', 1);
                        disp('측정 거리 = 1.42m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,6) && long_rad <= md(level,5)

                        moveforward(drone, 'distance', 0.97+ a, 'speed', 1);
                        disp('측정 거리 = 1.47m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,7) && long_rad <= md(level,6)

                        moveforward(drone, 'distance', 1.02+ a, 'speed', 1);
                        disp('측정 거리 = 1.52m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,8) && long_rad <= md(level,7)

                        moveforward(drone, 'distance', 1.07+ a, 'speed', 1);
                        disp('측정 거리 = 1.57m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,9) && long_rad <= md(level,8)

                        moveforward(drone, 'distance', 1.12 + a, 'speed', 1);
                        disp('측정 거리 = 1.62m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,10) && long_rad <= md(level,9)

                        moveforward(drone, 'distance', 1.17 + a, 'speed', 1);
                        disp('측정 거리 = 1.67m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,11) && long_rad <= md(level,10)


                        moveforward(drone, 'distance', 1.22 + a, 'speed', 1);
                        disp('측정 거리 = 1.72m');
                        disp('이동후 착륙');
                        long_rad


                    elseif long_rad > md(level,12) && long_rad <= md(level,11)

                        moveforward(drone, 'distance', 1.27 + a, 'speed', 1);
                        disp('측정 거리 = 1.77m');
                        disp('이동후 착륙');
                        long_rad

                    elseif long_rad > 250 && long_rad <= md(level,12)
                        moveforward(drone, 'distance', 0.5, 'speed', 1);
                        % moveforward(drone, 'distance', 1.32 + a, 'speed', 1);
                        disp('측정 거리 = 1.82m 이상 50cm 전진');
                        % disp('이동후 착륙');
                        long_rad
                        ccheck = 1;

                    elseif long_rad > 230 && long_rad <= 250
                        moveforward(drone, 'distance', 0.8, 'speed', 1);
                        % moveforward(drone, 'distance', 1.32 + a, 'speed', 1);
                        disp('측정 거리 = 1.82m 이상 80cm 전진');
                        % disp('이동후 착륙');
                        long_rad
                        ccheck = 1;

                    elseif long_rad > 200 && long_rad <= 230
                        moveforward(drone, 'distance', 1.0, 'speed', 1);
                        % moveforward(drone, 'distance', 1.32 + a, 'speed', 1);
                        disp('측정 거리 = 1.82m 이상 100cm 전진');
                        % disp('이동후 착륙');
                        long_rad
                        ccheck = 1;

                    elseif long_rad <= 200
                        moveforward(drone, 'distance', 1.2, 'speed', 1);
                        % moveforward(drone, 'distance', 1.32 + a, 'speed', 1);
                        disp('측정 거리 = 1.82m 이상 120cm 전진');
                        % disp('이동후 착륙');
                        long_rad
                        ccheck = 1;


                    end
                    if ccheck == 1
                        disp("미션 재추적")
                        ccheck = 0;
                    else
                        land(drone);
                        disp('mission complete!')
                    end

                elseif (x_pur - x_blu) > 5
                    disp("찾는중1")
                    turn(drone,deg2rad(3));
                elseif (x_pur - x_blu) < -5
                    disp("찾는중2")
                    turn(drone,deg2rad(-3));
                end
            end

            if reward ==1 && back_cnt == 1
                disp('moveback')
                disp("55555555555555555555555555555555555555555555555555")
                moveback(drone,'distance',1.0);
                reward = 0;
                back_cnt = 0;
            end


            %파란색 중심찾기



            %파란점 찾기

            while true

                firstCenter = find_center_blu(cam,hsv_blue);


                % if isempty(firstCenter)
                %     moveback
                ct_diff_lr = firstCenter(1,1)-originCenter(1,1);
                % disp('ct_diff_lr: ')
                % disp(ct_diff_lr)
                % ct_diff_ud = firstCenter(1,2)-originCenter(1,2);
                % disp("3")
                if ct_diff_lr >= 45 && ct_diff_lr <= 80
                    moveright(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move right_0.2m');



                elseif ct_diff_lr > 80
                    moveright(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move right_0.3m');


                elseif ct_diff_lr <= -45 && ct_diff_lr >= -80
                    moveleft(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move left_0.25m');


                elseif ct_diff_lr < -80
                    moveleft(drone,'Distance',0.2,'speed',1);
                    disp('finding center point_move left _0.3m');

                    % elseif ct_diff_lr <= 45 && ct_diff_lr >= 0
                    %     moveforward(drone,'Distance',1.0);
                    %     land(drone);
                    %     break;
                else
                    disp("중심맞춤")
                    break;


                end

            end
            % clearvars max
        end
    elseif long_rad > md(level,1)

        moveaforward(drone, 'distance', 1.1, 'speed', 1);
        disp('측정 거리 = 0.8m');
        disp('이동거리 = 1.6m');
        long_rad


    elseif long_rad > md(level,2) && long_rad <= md(level,1)

        moveforward(drone, 'distance', 1.3, 'speed', 1);
        disp('측정 거리 0.9m');
        disp('이동거리 = 1.8m');
        long_rad


    elseif long_rad > md(level,3) && long_rad <= md(level,2)

        moveforward(drone, 'distance', 1.5, 'speed', 1);
        disp('측정 거리 1.0m');
        disp('이동거리 = 2.0m');
        long_rad


    elseif long_rad > md(level,4) && long_rad <= md(level,3)

        moveforward(drone, 'distance', 1.7, 'speed', 1);
        disp('측정 거리 1.1m');
        disp('이동거리 = 2.2m');
        long_rad


    elseif long_rad > md(level,5) && long_rad <= md(level,4)

        moveforward(drone, 'distance', 1.9, 'speed', 1);
        disp('측정 거리 1.2m');
        disp('이동거리 = 2.4m');
        long_rad


    elseif long_rad > md(level,6) && long_rad <= md(level,5)

        moveforward(drone, 'distance', 2.1, 'speed', 1);
        disp('측정 거리 1.3m');
        disp('이동거리 = 2.6m');
        long_rad


    elseif long_rad > md(level,7) && long_rad <= md(level,6)

        moveforward(drone, 'distance', 2.3, 'speed', 1);
        disp('측정 거리 1.4m');
        disp('이동거리 = 2.8m');
        long_rad


    elseif long_rad > md(level,8) && long_rad <= md(level,7)

        moveforward(drone, 'distance', 2.5, 'speed', 1);
        disp('측정 거리 1.5m');
        disp('이동거리 = 3.0m');
        long_rad


    elseif long_rad > md(level,9) && long_rad <= md(level,8)

        moveforward(drone, 'distance', 2.7, 'speed', 1);
        disp('측정 거리 1.6m');
        disp('이동거리 = 3.2m');
        long_rad


    elseif long_rad > md(level,10) && long_rad <= md(level,9)

        moveforward(drone, 'distance', 2.9, 'speed', 1);
        disp('측정 거리 1.7m');
        disp('이동거리 = 3.4m');
        long_rad


    elseif long_rad > md(level,11) && long_rad <= md(level,10)


        moveforward(drone, 'distance', 3.1, 'speed', 1);
        disp('측정 거리 1.8m');
        disp('이동거리 = 3.6m');
        long_rad


    elseif long_rad > md(level,12) && long_rad <= md(level,11)

        moveforward(drone, 'distance', 3.3, 'speed', 1);
        disp('측정 거리 1.9m');
        disp('이동거리 = 3.8m');
        long_rad

    elseif long_rad <= md(level,12)

        moveforward(drone, 'distance', 3.5, 'speed', 1);
        disp('측정 거리 2m');
        disp('이동거리 = 4m');
        long_rad


    end



    %% detecting sign
    % 1,2 단계일 때 수행
    if level==1 || level==2 ||level ==3
        %빨간점 찾기
        while 1

            %빨간색에 대한 HSV값 설정 및 이진화
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            red = ((0.95<h) & (h<1) | (0<h) & (h<0.05)) & (0.8<s) & (s<=1);
            green =(0.25<h) &(h<0.4) &(0.5<s)&(s<0.9);
            %빨간색의 픽셀이 400이 넘으면 90도 회전
            if sum(red,'all')>500
                if count==1
                    moveforward(drone,'distance',0.2);
                    count=0;
                end

                turn(drone,deg2rad(90))
                disp("111111111111111111111111111111111111111111111111")
                moveback(drone,'distance',0.5)
                moveup(drone,'distance',0.3);


                break;
            elseif sum(green,'all')>400
                if count==1
                    moveforward(drone,'distance',0.2);
                    count=0;
                end
                turn(drone,deg2rad(45));

                break;


            else
                disp("22222222222222222222222222222222222222222222")
                moveback(drone,'distance',0.2)
                count=1;

            end
        end
    end

    %3단계일 때 실행


end
disp('efefe')
clear drone;
clear cam;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = ispurple(cam)

frame=snapshot(cam);
hsv = rgb2hsv(frame);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);
purple=(0.71<h)&(h<0.79)&(0.5<s)&(s<0.9);
if sum(purple,'all')<30
    a = 0;
else
    a = 1;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x_, y_, z_] = find_center_blu(cam,hsv)
frame=snapshot(cam);
hsv_ = rgb2hsv(frame);
h = hsv_(:,:,1);
s = hsv_(:,:,2);
v = hsv_(:,:,3);
blue=(hsv(1)<h)&(h<hsv(2))&(hsv(3)<s)&(s<hsv(4));
blue(1,:) = 1;
blue(720,:) = 1;
bw2 = imfill(blue,'holes');

for x=1:720
    for y=1:size(blue,2)
        if blue(x,y)==bw2(x,y)
            bw2(x,y)=0;
        end
    end
end

stats = regionprops('table',bw2, 'Centroid', 'MinorAxisLength');
z_ = max(stats.MinorAxisLength);
max_r=0;
y = stats.Centroid;
z = stats.MinorAxisLength;
for i=1:size(stats)
    if z(i,1)>=max_r
        max_r=z(i,1);
        x_=round(y(i,1));
        y_=round(y(i,2));
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x_, y_] = find_center_other(cam,hsv)
frame=snapshot(cam);
hsv_ = rgb2hsv(frame);
h = hsv_(:,:,1);
s = hsv_(:,:,2);
v = hsv_(:,:,3);
color=(hsv(1)<h)&(h<hsv(2))&(hsv(3)<s)&(s<hsv(4));

stats = regionprops('table',color, 'Centroid', 'MinorAxisLength');
max_r=0;
z = stats.MinorAxisLength;
y = stats.Centroid;
for i=1:size(stats)
    if z(i,1)>=max_r
        max_r=z(i,1);
        x_=round(y(i,1));
        y_=round(y(i,2));
    end
end
end

