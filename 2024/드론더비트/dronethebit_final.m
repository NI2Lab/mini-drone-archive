% 메인 스크립트
count_go = 0;  % 전진한 횟수를 세주는 변수
area_circle = 0;  % 각 스테이지 별 원의 면적
center = [480, 200];  % 기준 중심 위치
centroid = zeros(size(center));  % 원의 중심 좌표를 저장할 변수
count = 0; % 상하좌우 전진 횟수
color_pixel = 0; % 색 감지 변수

drone = ryze();  % 드론 객체 선언
cam = camera(drone);  % 드론의 카메라 객체 선언
takeoff(drone);  % 드론 이륙
moveup(drone, 'Distance', 0.3, 'Speed', 0.2);
pause(1.0);

% 1stage
while 1
    frame = snapshot(cam);  % 카메라로부터 이미지 캡처
    img = double(frame);  % 이미지를 double 형으로 변환
    [R, C, X] = size(img);  % 이미지의 크기를 저장

    % 특정 색상 조건에 따라 이미지를 이진화
    img2 = zeros(R, C, X);
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) > -5 || img(i, j, 1) - img(i, j, 3) > -5 || img(i, j, 2) - img(i, j, 3) > -37
                img2(i, j, :) = 255;
            else
                img2(i, j, :) = 0;
            end
        end
    end

    % 이진화된 이미지에서 원의 중심과 면적을 찾음
    circle_ring = img2 / 255;
    circle_ring_Gray = rgb2gray(circle_ring);
    circle_ring_bi = imbinarize(circle_ring_Gray);
    bi2 = imcomplement(circle_ring_bi);
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);
    se = strel('disk', 10);
    bw2 = imclose(bw, se);
    bw3 = bwareaopen(bw2, 8000);
    [B, L] = bwboundaries(bw3, 'noholes');
    figure(1), imshow(bw3); % 원의 중심 좌표 찾는 과정 출력
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 그림
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:, 2), boundary(:, 1), 'w', 'LineWidth', 2);
    end

    % 원의 면적과 중심 좌표를 계산
    stats = regionprops(L, 'Area', 'Centroid');
    threshold = 0.7;
    for k = 1:length(B)
        boundary = B{k};
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq, 2)));
        area = stats(k).Area;
        metric = 4 * pi * area / perimeter^2;
        metric_string = sprintf('%2.2f', metric);

        if metric > threshold
            area_circle = stats(k).Area;
            centroid = stats(k).Centroid;
            plot(centroid(1), centroid(2), 'r');
        end

        text(boundary(1, 2) - 35, boundary(1, 1) + 13, metric_string, 'Color', 'r', ...
            'FontSize', 10, 'FontWeight', 'bold');
    end

    % 드론의 이동 결정
    dis = centroid - center;
    if (abs(dis(1)) < 33 && abs(dis(2)) < 33) || count == 3

        % 드론을 앞으로 이동
        if 30000 <= area_circle && area_circle < 40000
            moveforward(drone, 'Distance', 1.8, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(-1);
        elseif 40000 <= area_circle && area_circle < 50000
            moveforward(drone, 'Distance', 1.7, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(0);
        elseif 50000 <= area_circle && area_circle < 60000
            moveforward(drone, 'Distance', 1.6, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(1);
        elseif 60000 <= area_circle && area_circle < 70000
            moveforward(drone, 'Distance', 1.5, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(2);
        elseif 70000 <= area_circle && area_circle < 85000
            moveforward(drone, 'Distance', 1.4, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(3);
        elseif 85000 <= area_circle && area_circle < 100000
            moveforward(drone, 'Distance', 1.3, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(4);
        elseif 100000 <= area_circle && area_circle < 130000
            moveforward(drone, 'Distance', 1.1, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(5);
        elseif 130000 <= area_circle
            moveforward(drone, 'Distance', 1.0, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(6);
        else
            moveforward(drone, 'Distance', 1.9, 'Speed', 0.7);
            count_go = 1;
            pause(0.5);
            disp(12);
        end

    else
        while 1
             if dis(2) > 0 && abs(dis(2)) > 33
                disp("Moving drone down");
                movedown(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(0.5);
                break;
            elseif dis(2) < 0 && abs(dis(2)) > 33
                disp("Moving drone up");
                moveup(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(0.5);
                break;
             elseif dis(1) > 0 && abs(dis(1)) > 33 && dis(2) < 33
                disp("Moving drone right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(0.5);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 33 && dis(2) < 33
                disp("Moving drone left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(0.5);
                break;
            elseif dis(1) > 0 && abs(dis(1)) > 33
                disp("Moving right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(0.5);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 33
                disp("Moving left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(0.5);
                break;
            else
                break;
            end
        end

    end
    if count_go == 1
        break;
    end
end

frame = snapshot(cam);
colorcenter = processImage_R_a(frame); % 링의 앞에서 붉은색 타겟의 중점 찾음
dis_c = colorcenter - center;
count_a = 0; % 각도 조정 횟수 변수
% 각도 조정을 통해 붉은색 타겟의 중점과 원의 중심을 일치
while abs(dis_c(1)) > 30
    frame = snapshot(cam);
    colorcenter = processImage_R_a(frame);
    dis_c = colorcenter - center;
    if dis_c(1)>0
        turn(drone, deg2rad(5));
        count_a = count_a + 1;
    else
        turn(drone, deg2rad(-5));
        count_a = count_a - 1;
    end
end
moveforward(drone, 'Distance', 1.9, 'Speed', 1.0);
pause(0.5);

count_go = 0;
count = 0;
turn(drone, deg2rad(130 - (count_a * 5)));

% 2stage
moveforward(drone, 'Distance', 2.7, 'Speed', 0.7);
pause(1.0);

while 1
    frame = snapshot(cam);  % 카메라로부터 이미지 캡처
    img = double(frame);  % 이미지를 double 형으로 변환
    [R, C, X] = size(img);  % 이미지의 크기를 저장

    % 특정 색상 조건에 따라 이미지를 이진화
    img2 = zeros(R, C, X);
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) > -5 || img(i, j, 1) - img(i, j, 3) > -5 || img(i, j, 2) - img(i, j, 3) > -37
                img2(i, j, :) = 255;
            else
                img2(i, j, :) = 0;
            end
        end
    end

    % 이진화된 이미지에서 원의 중심과 면적을 찾음
    circle_ring = img2 / 255;
    circle_ring_Gray = rgb2gray(circle_ring);
    circle_ring_bi = imbinarize(circle_ring_Gray);
    bi2 = imcomplement(circle_ring_bi);
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);
    se = strel('disk', 10);
    bw2 = imclose(bw, se);
    bw3 = bwareaopen(bw2, 8000);
    [B, L] = bwboundaries(bw3, 'noholes');
    figure(1), imshow(bw3);
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 그림
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:, 2), boundary(:, 1), 'w', 'LineWidth', 2);
    end

    % 원의 면적과 중심 좌표를 계산
    stats = regionprops(L, 'Area', 'Centroid');
    threshold = 0.7;
    for k = 1:length(B)
        boundary = B{k};
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq, 2)));
        area = stats(k).Area;
        metric = 4 * pi * area / perimeter^2;
        metric_string = sprintf('%2.2f', metric);

        if metric > threshold
            area_circle = stats(k).Area;
            centroid = stats(k).Centroid;
            plot(centroid(1), centroid(2), 'r');
        end

        text(boundary(1, 2) - 35, boundary(1, 1) + 13, metric_string, 'Color', 'r', ...
            'FontSize', 10, 'FontWeight', 'bold');
    end

    % 드론의 이동 결정
    dis = centroid - center;
    if (abs(dis(1)) < 40 && abs(dis(2)) < 40) || count == 6


        % 드론을 앞으로 이동
        if 5000 <= area_circle && area_circle < 10000
            moveforward(drone, 'Distance', 2, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-3);
        elseif 10000 <= area_circle && area_circle < 20000
            moveforward(drone, 'Distance', 1.95, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-3);
        elseif 20000 <= area_circle && area_circle < 30000
            moveforward(drone, 'Distance', 1.9, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-1);
        elseif 30000 <= area_circle && area_circle < 40000
            moveforward(drone, 'Distance', 1.85, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-1);
        elseif 40000 <= area_circle && area_circle < 50000
            moveforward(drone, 'Distance', 1.8, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(0);
        elseif 50000 <= area_circle && area_circle < 60000
            moveforward(drone, 'Distance', 1.75, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(1);
        elseif 60000 <= area_circle && area_circle < 70000
            moveforward(drone, 'Distance', 1.7, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(2);
        elseif 70000 <= area_circle && area_circle < 85000
            moveforward(drone, 'Distance', 1.65, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(3);
        elseif 85000 <= area_circle && area_circle < 100000
            moveforward(drone, 'Distance', 1.6, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(4);
        elseif 100000 <= area_circle
            moveforward(drone, 'Distance', 1.55, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(5);
        else
            moveforward(drone, 'Distance', 2.05, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(12); % 두번찍힘
        end

        % 드론이 원의 중심과 가까울 경우
    elseif (abs(dis(1)) > 40 && abs(dis(1)) <= 150) || (abs(dis(2)) > 40 && abs(dis(2)) <=150)
        while 1
            if dis(1) > 0 && abs(dis(1)) > 40 && dis(2) < 40
                disp("Moving drone right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 40 && dis(2) < 40
                disp("Moving drone left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 40 && dis(2) > 0 && abs(dis(2)) > 40
                disp("Moving drone down");
                movedown(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 40 && dis(2) < 0 && abs(dis(2)) > 40
                disp("Moving drone up");
                moveup(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) > 0 && abs(dis(1)) > 40
                disp("Moving right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 40
                disp("Moving left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            end
        end


        % 드론이 원의 중심과 멀리 떨어져 있을 경우
    elseif dis(1) > 0 && abs(dis(1)) > 150 && dis(2) < 40
        disp("Moving drone more right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 150 && dis(2) < 40
        disp("Moving drone more left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 40 && dis(2) > 0 && abs(dis(2)) > 150
        disp("Moving drone more down");
        movedown(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 40 && dis(2) < 0 && abs(dis(2)) > 150
        disp("Moving drone more up");
        moveup(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) > 0 && abs(dis(1)) > 150
        disp("Moving right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 150
        disp("Moving left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    end

    if count_go == 1
        break;
    end
end

frame = snapshot(cam);
colorcenter = processImage_G(frame); % 초록색 타겟의 중점 찾음
dis_c = colorcenter - center;
count_a = 0;
% 각도 조정을 통해 초록색 타겟의 중점과 드론 중심을 일치
while abs(dis_c(1)) > 30
    frame = snapshot(cam);
    colorcenter = processImage_G(frame);
    dis_c = colorcenter - center;
    if dis_c(1)>0
        turn(drone, deg2rad(5));
        pause(0.5);
        count_a = count_a + 1;
    else
        turn(drone, deg2rad(-5));
        pause(0.5);
        count_a = count_a - 1;
    end
end
pause(1.5);
turn(drone, deg2rad(-130 - (count_a * 5)));
count_go = 0;
count = 0;

% 3stage
moveforward(drone, 'Distance', 0.6, 'Speed', 0.3);
pause(1.0);

while 1
    frame = snapshot(cam);  % 카메라로부터 이미지 캡처
    img = double(frame);  % 이미지를 double 형으로 변환
    [R, C, X] = size(img);  % 이미지의 크기를 저장

    % 특정 색상 조건에 따라 이미지를 이진화
    img2 = zeros(R, C, X);
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) > -5 || img(i, j, 1) - img(i, j, 3) > -5 || img(i, j, 2) - img(i, j, 3) > -37
                img2(i, j, :) = 255;
            else
                img2(i, j, :) = 0;
            end
        end
    end

    % 이진화된 이미지에서 원의 중심과 면적을 찾음
    circle_ring = img2 / 255;
    circle_ring_Gray = rgb2gray(circle_ring);
    circle_ring_bi = imbinarize(circle_ring_Gray);
    bi2 = imcomplement(circle_ring_bi);
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);
    se = strel('disk', 10);
    bw2 = imclose(bw, se);
    bw3 = bwareaopen(bw2, 8000);
    [B, L] = bwboundaries(bw3, 'noholes');
    figure(1), imshow(bw3);
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 그림
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:, 2), boundary(:, 1), 'w', 'LineWidth', 2);
    end

    % 원의 면적과 중심 좌표를 계산
    stats = regionprops(L, 'Area', 'Centroid');
    threshold = 0.7;
    for k = 1:length(B)
        boundary = B{k};
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq, 2)));
        area = stats(k).Area;
        metric = 4 * pi * area / perimeter^2;
        metric_string = sprintf('%2.2f', metric);

        if metric > threshold
            area_circle = stats(k).Area;
            centroid = stats(k).Centroid;
            plot(centroid(1), centroid(2), 'r');
        end

        text(boundary(1, 2) - 35, boundary(1, 1) + 13, metric_string, 'Color', 'r', ...
            'FontSize', 10, 'FontWeight', 'bold');
    end

    % 드론의 이동 결정
    dis = centroid - center;
    if (abs(dis(1)) < 40 && abs(dis(2)) < 40) || count == 4

        % 드론을 앞으로 이동
        if 5000 <= area_circle && area_circle < 10000
            moveforward(drone, 'Distance', 1.9, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-3);
        elseif 20000 <= area_circle && area_circle < 30000
            moveforward(drone, 'Distance', 1.85, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-2);
        elseif 30000 <= area_circle && area_circle < 40000
            moveforward(drone, 'Distance', 1.8, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-1);
        elseif 40000 <= area_circle && area_circle < 50000
            moveforward(drone, 'Distance', 1.75, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(0);
        elseif 50000 <= area_circle && area_circle < 60000
            moveforward(drone, 'Distance', 1.7, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(1);
        elseif 60000 <= area_circle && area_circle < 70000
            moveforward(drone, 'Distance', 1.65, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(2);
        elseif 70000 <= area_circle && area_circle < 85000
            moveforward(drone, 'Distance', 1.6, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(3);
        elseif 85000 <= area_circle && area_circle < 100000
            moveforward(drone, 'Distance', 1.55, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(4);
        elseif 100000 <= area_circle && area_circle < 130000
            moveforward(drone, 'Distance', 1.5, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(5);
        elseif 130000 <= area_circle
            moveforward(drone, 'Distance', 1.4, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(6);
        else
            moveforward(drone, 'Distance', 1.95, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(12);
        end

    elseif (abs(dis(1)) > 40 && abs(dis(1)) <= 150) || (abs(dis(2)) > 40 && abs(dis(2)) <= 150)
        while 1
            if dis(1) > 0 && abs(dis(1)) > 40 && dis(2) < 40
                disp("Moving drone right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 40 && dis(2) < 40
                disp("Moving drone left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 40 && dis(2) > 0 && abs(dis(2)) > 40
                disp("Moving drone down");
                movedown(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 40 && dis(2) < 0 && abs(dis(2)) > 40
                disp("Moving drone up");
                moveup(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) > 0 && abs(dis(1)) > 40
                disp("Moving right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 40
                disp("Moving left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            end
        end


        % 드론이 원의 중심과 멀리 떨어져 있을 경우
    elseif dis(1) > 0 && abs(dis(1)) > 150 && dis(2) < 40
        disp("Moving drone more right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 150 && dis(2) < 40
        disp("Moving drone more left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 40 && dis(2) > 0 && abs(dis(2)) > 150
        disp("Moving drone more down");
        movedown(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 40 && dis(2) < 0 && abs(dis(2)) > 150
        disp("Moving drone more up");
        moveup(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) > 0 && abs(dis(1)) > 150
        disp("Moving right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 150
        disp("Moving left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    end

    if count_go == 1
        break;
    end
end

frame = snapshot(cam);
colorcenter = processImage_P(frame);
dis_c = colorcenter - center;
count_a = 0;

while abs(dis_c(1)) > 30
    frame = snapshot(cam);
    colorcenter = processImage_P(frame);
    dis_c = colorcenter - center;
    if dis_c(1) > 0
        turn(drone, deg2rad(5));
        count_a = count_a + 1;
    else
        turn(drone, deg2rad(-5));
        count_a = count_a - 1;
    end
end
pause(1.5);

turn(drone, deg2rad(215 - count_a * 5));
stage_pixel = 0;
count_go = 0;
count = 0;

% 4stage
frame = snapshot(cam);
colorcenter = processImage_R_a(frame);
dis_c = colorcenter - center;
count_a = 0;
while abs(dis_c(1)) > 30
    frame = snapshot(cam);
    colorcenter = processImage_R_a(frame);
    dis_c = colorcenter - center;
    if dis_c(1)>0
        turn(drone, deg2rad(5));
        count_a = count_a + 1;
    else
        turn(drone, deg2rad(-5));
        count_a = count_a - 1;
    end
end
moveforward(drone, 'Distance', 1.1, 'Speed', 0.7);

while 1
    frame = snapshot(cam);  % 카메라로부터 이미지 캡처
    img = double(frame);  % 이미지를 double 형으로 변환
    [R, C, X] = size(img);  % 이미지의 크기를 저장

    % 특정 색상 조건에 따라 이미지를 이진화
    img2 = zeros(R, C, X);
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) > -5 || img(i, j, 1) - img(i, j, 3) > -5 || img(i, j, 2) - img(i, j, 3) > -37
                img2(i, j, :) = 255;
            else
                img2(i, j, :) = 0;
            end
        end
    end

    % 이진화된 이미지에서 원의 중심과 면적을 찾음
    circle_ring = img2 / 255;
    circle_ring_Gray = rgb2gray(circle_ring);
    circle_ring_bi = imbinarize(circle_ring_Gray);
    bi2 = imcomplement(circle_ring_bi);
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);
    se = strel('disk', 10);
    bw2 = imclose(bw, se);
    bw3 = bwareaopen(bw2, 8000);
    [B, L] = bwboundaries(bw3, 'noholes');
    figure(1), imshow(bw3);
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 그림
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:, 2), boundary(:, 1), 'w', 'LineWidth', 2);
    end

    % 원의 면적과 중심 좌표를 계산
    stats = regionprops(L, 'Area', 'Centroid');
    threshold = 0.7;
    for k = 1:length(B)
        boundary = B{k};
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq, 2)));
        area = stats(k).Area;
        metric = 4 * pi * area / perimeter^2;
        metric_string = sprintf('%2.2f', metric);

        if metric > threshold
            area_circle = stats(k).Area;
            centroid = stats(k).Centroid;
            plot(centroid(1), centroid(2), 'r');
        end

        text(boundary(1, 2) - 35, boundary(1, 1) + 13, metric_string, 'Color', 'r', ...
            'FontSize', 10, 'FontWeight', 'bold');
    end

    % 드론의 이동 결정
    dis = centroid - center;
    if (abs(dis(1)) < 33 && abs(dis(2)) < 33) || count == 5

        % 드론을 앞으로 이동
        if 30000 <= area_circle && area_circle < 40000
            moveforward(drone, 'Distance', 1.65, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-1);
        elseif 40000 <= area_circle && area_circle < 50000
            moveforward(drone, 'Distance', 1.6, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(0);
        elseif 50000 <= area_circle && area_circle < 60000
            moveforward(drone, 'Distance', 1.55, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(1);
        elseif 60000 <= area_circle && area_circle < 70000
            moveforward(drone, 'Distance', 1.5, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(2);
        elseif 70000 <= area_circle && area_circle < 85000
            moveforward(drone, 'Distance', 1.45, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(3);
        elseif 85000 <= area_circle && area_circle < 100000
            moveforward(drone, 'Distance', 1.4, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(4);
        elseif 100000 <= area_circle && area_circle < 130000
            moveforward(drone, 'Distance', 1.35, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(5);
        elseif 130000 <= area_circle && area_circle < 160000
            moveforward(drone, 'Distance', 1.3, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(6);
        elseif 160000 <= area_circle && area_circle < 200000
            moveforward(drone, 'Distance', 1.25, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(7);
        elseif 200000 <= area_circle
            moveforward(drone, 'Distance', 1.2, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(8);
        else
            moveforward(drone, 'Distance', 1.7, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(12);
        end

    elseif (abs(dis(1)) > 33 && abs(dis(1)) <= 150) || (abs(dis(2)) > 33 && abs(dis(2)) <=150)
        while 1
            if dis(1) > 0 && abs(dis(1)) > 33 && dis(2) < 33
                disp("Moving drone right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 33 && dis(2) < 33
                disp("Moving drone left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 33 && dis(2) > 0 && abs(dis(2)) > 33
                disp("Moving drone down");
                movedown(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 33 && dis(2) < 0 && abs(dis(2)) > 33
                disp("Moving drone up");
                moveup(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) > 0 && abs(dis(1)) > 33
                disp("Moving right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 33
                disp("Moving left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            end
        end


        % 드론이 원의 중심과 멀리 떨어져 있을 경우
    elseif dis(1) > 0 && abs(dis(1)) > 150 && dis(2) < 33
        disp("Moving drone more right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 150 && dis(2) < 33
        disp("Moving drone more left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 33 && dis(2) > 0 && abs(dis(2)) > 150
        disp("Moving drone more down");
        movedown(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 33 && dis(2) < 0 && abs(dis(2)) > 150
        disp("Moving drone more up");
        moveup(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) > 0 && abs(dis(1)) > 150
        disp("Moving right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 150
        disp("Moving left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    end

    if count_go == 1
        break;
    end
end
frame = snapshot(cam);
colorcenter = processImage_R_a(frame);
dis_c = colorcenter - center;
count_a = 0;
while abs(dis_c(1)) > 30
    frame = snapshot(cam);
    colorcenter = processImage_R_a(frame);
    dis_c = colorcenter - center;
    if dis_c(1)>0
        turn(drone, deg2rad(5));
        count_a = count_a + 1;
    else
        turn(drone, deg2rad(-5));
        count_a = count_a - 1;
    end
end
disp('find');
moveforward(drone, 'Distance', 1, 'Speed', 0.8);
pause(1.0);
count_go = 0;
land(drone);

% 빨간색 이미지 처리 함수
function [centerX, centerY] = processImage_R_a(frame)

% 이미지 읽기
img = double(frame);
[R, C, X] = size(img);
img3 = zeros(R, C, X);  % img3 변수를 초기화

% 빨간색 픽셀의 개수를 초기화
redPixelCount = 0;

% 빨간색 픽셀의 좌표를 저장할 배열
redPixels = [];

for i = 1:R
    for j = 1:C
        % 빨간색이 아닌 색들을 제거하기 위한 조건
        if img(i,j,1) - img(i,j,2) >= 55 && img(i,j,1) - img(i,j,3) >= 10 && img(i,j,2) - img(i,j,3) <= 30
            % 빨간색으로 판단되는 경우
            img3(i, j, 1) = 255;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
            redPixelCount = redPixelCount + 1;
            redPixels = [redPixels; [i, j]];
        else
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
        end
    end
end

% 빨간색 픽셀의 중심 좌표 계산
if redPixelCount > 0
    centerX = mean(redPixels(:, 2));
    centerY = mean(redPixels(:, 1));
else
    centerX = NaN;
    centerY = NaN;
end

% 중심 좌표 출력
fprintf('빨간색 네모의 중심 좌표: (%.2f, %.2f)\n', centerX, centerY);


end

% 초록색 이미지 처리 함수
function [centerX, centerY] = processImage_G(frame)

% 이미지 읽기
img = double(frame);
[R, C, X] = size(img);
img3 = zeros(R, C, X);  % img3 변수를 초기화

% 초록색 픽셀의 개수를 초기화
greenPixelCount = 0;

% 초록색 픽셀의 좌표를 저장할 배열
greenPixels = [];

for i = 1:R
    for j = 1:C
        % 초록색이 아닌 색들을 제거하기 위한 조건
        if img(i,j,1) - img(i,j,2) <= 25 && img(i,j,1) - img(i,j,3) <= 5 && img(i,j,2) - img(i,j,3) >= 17 %조건이 애매하다
            % 초록색으로 판단되는 경우
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 255;
            img3(i, j, 3) = 0;
            greenPixelCount = greenPixelCount + 1;
            greenPixels = [greenPixels; [i, j]];
        else
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
        end
    end
end

% 초록색 픽셀의 중심 좌표 계산
if greenPixelCount > 0
    centerX = mean(greenPixels(:, 2));
    centerY = mean(greenPixels(:, 1));
else
    centerX = NaN;
    centerY = NaN;
end

% 중심 좌표 출력
fprintf('초록색 네모의 중심 좌표: (%.2f, %.2f)\n', centerX, centerY);


end
% 보라색 이미지 처리 함수
function [centerX, centerY] = processImage_P(frame)

img = double(frame);
[R, C, X] = size(img);
img3 = zeros(R, C, X);  % img3 변수를 초기화

% 보라색 픽셀의 개수를 초기화
purplePixelCount = 0;

% 보라색 픽셀의 좌표를 저장할 배열
purplePixels = [];

for i = 1:R
    for j = 1:C
        % 보라색이 아닌 색들을 제거하기 위한 조건
        if img(i,j,1) - img(i,j,2) >= 11 && img(i,j,1) - img(i,j,3) <= 0 && img(i,j,2) - img(i,j,3) <= 20
            % 보라색으로 판단되는 경우
            img3(i, j, 1) = 255;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 255;
            purplePixelCount = purplePixelCount + 1;
            purplePixels = [purplePixels; [i, j]];
        else
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
        end
    end
end

% 보라색 픽셀의 중심 좌표 계산
if purplePixelCount > 0
    centerX = mean(purplePixels(:, 2));
    centerY = mean(purplePixels(:, 1));
else
    centerX = NaN;
    centerY = NaN;
end

% 중심 좌표 출력
fprintf('보라색 네모의 중심 좌표: (%.2f, %.2f)\n', centerX, centerY);


end
