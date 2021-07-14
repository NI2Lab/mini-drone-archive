% 각 step 별로 다중곡선피팅의 값을 저장해둔 파일을 가져온다.
p1 = readmatrix('regression/step1_p2.xls');
disp("get p1")
p2 = readmatrix('regression/step2_p2.xls');
disp("get p2")
p3 = readmatrix('regression/step3_p2.xls');
disp("get p3")

% 1단계는 중점과 드론 사이의 거리에 관여하는 변수가 1개 뿐이므로 높이만을 맞춰주면 된다.
% 2,3단계는 변수가 다양하기 때문에 CNN을 이용하여 드론의 이동방향을 결정하여 장애물의 중점과 드론의 위치를 일치시킨다.
% ["back", "down", "forward", "left", "right", "up"]의 6가지 방향에 대해 드론의 이동방향을 예측하는 cnn_model을 가져온다.
classes = ["back", "down", "forward", "left", "right", "up"];
net = importONNXNetwork('cnn/drone_cnn_2.onnx', 'OutputLayerType', 'classification', "Classes", classes); 

myDrone = ryze();
cam = camera(myDrone);
takeoff(myDrone); 
pause(3)

% step 1_passing_obstacle: not using cnn
step1_find_center(myDrone);
frame = snapshot(cam);
masked_blue = masking_blue(frame);
hole = finding_hole(masked_blue);
% f = figure;
% imshow(hole)
% hold on;
final_dist = passing_obstacle(hole, p1)
while final_dist == inf
    moveforward(myDrone, "Distance", 0.2)
    final_dist = passing_obstacle(hole, p1)
end
%예측한 값만큼 드론 전진.
moveforward(myDrone, "Distance", final_dist)
% close(f)
detecting_red(myDrone, cam)


% step 2_passing_obstacle: using cnn
while 1
    frame = snapshot(cam);
    masked_blue = masking_blue(frame);
    
    % CNN을 통해 예측한 이동 방향을 label 변수에 대입.
    label = classify(net, masked_blue);
    
    % CNN이 예측한 드론의 이동방향이 Forward일 경우 while문을 벗어남.
    % forward일 경우, 원형 장애물의 중점과 평행한 지점에 드론이 위치한 것으로 간주하여 전진만 하면 된다고 인식.
    if label == "forward"
%         fprintf("Moving the drone forward\n")
        break
    % 다른 경우 중점을 찾기 위해 움직인다.
    else
        find_center(myDrone, label)
    end
end
frame = snapshot(cam);
masked_blue = masking_blue(frame);
hole = finding_hole(masked_blue);
% f = figure;
% imshow(hole)
% hold on;
final_dist = passing_obstacle(hole, p2)
while final_dist == inf
    moveforward(myDrone, "Distance", 0.2)
    final_dist = passing_obstacle(hole, p2)
end
%예측한 값만큼 드론 전진.
moveforward(myDrone, "Distance", final_dist)
% close(f)
detecting_red(myDrone, cam)
moveforward(myDrone, "Distance", 0.2)


% step 3_passing_obstacle: using cnn
while 1
    frame = snapshot(cam);
    masked_blue = masking_blue(frame);
    
    % CNN을 통해 예측한 이동 방향을 label 변수에 대입.
    label = classify(net, masked_blue);
    
    % CNN이 예측한 드론의 이동방향이 Forward일 경우 while문을 벗어남.
    % forward일 경우, 원형 장애물의 중점과 평행한 지점에 드론이 위치한 것으로 간주하여 전진만 하면 된다고 인식.
    if label == "forward"
%         fprintf("Moving the drone forward\n")
        break
    % 다른 경우 중점을 찾기 위해 움직인다.
    else
        find_center(myDrone, label)
    end
end
frame = snapshot(cam);
masked_blue = masking_blue(frame);
hole = finding_hole(masked_blue);
% f = figure;
% imshow(hole)
% hold on;
final_dist = passing_obstacle(hole, p3)
while final_dist == inf
    moveforward(myDrone, "Distance", 0.2)
    final_dist = passing_obstacle(hole, p3)
end
%예측한 값만큼 드론 전진.
moveforward(myDrone, "Distance", final_dist+0.2)
% close(f)
detecting_purple(myDrone, cam)


function step1_find_center(myDrone)
    %드론의 비행 높이를 읽음.
    [height, time] = readHeight(myDrone);
    %1단계 장애물의 중점 높이에서 드론의 현재 비행 높이를 뺀 값.
    dist_1 = 0.9-height
    %dist_1의 값이 음수이면 드론 하강, 양수이면 드론 상승.
    if abs(dist_1) > 0.2 
        if dist_1<0
            movedown(myDrone, "Distance", dist_1)
        else
            moveup(myDrone, "Distance", dist_1)
        end
    end
end


function find_center(myDrone, label)
    if label == "right"
        fprintf("Moving the drone right\n")
        moveright(myDrone, "Distance", 0.2)
    %CNN이 예측한 드론의 이동방향이 Left일 경우 왼쪽으로 20cm 이동.
    elseif label == "left"
        fprintf("Moving the drone left\n")
        moveleft(myDrone, "Distance", 0.3)
    %CNN이 예측한 드론의 이동방향이 Up일 경우 20cm 상승.
    elseif label == "up"
        fprintf("Moving the drone up\n")
        moveup(myDrone, "Distance", 0.2)
    %CNN이 예측한 드론의 이동방향이 Down일 경우 20cm 하강.
    elseif label == "down"
        fprintf("Moving the drone down\n")
        movedown(myDrone, "Distance", 0.3)
    %CNN이 예측한 드론의 이동방향이 Back일 경우 20cm 후진.
    elseif label == "back"
        fprintf("Moving the drone back\n")
        moveback(myDrone, "Distance", 0.2)
    end
end


function masked_blue = masking_blue(frame)
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    img = (0.57<h)&(h<0.7)&(0.4<s)&(v>0.3)&(v<0.97);
    masked_blue = imresize(img, 0.3);
end


function masked_red = masking_red(frame)
    % 드론 전면 카메라의 frame을 받아온 후, 빨간색만 탐지되도록 HSV 설정 및 마스킹 처리.
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    masked_red = (0.95<h)+(h<0.1)&(0.4<s)&(v>0.1)&(v<0.97);
end


function masked_purple = masking_purple(frame)
    % 드론 전면 카메라의 frame을 받아온 후, 보라색만 탐지되도록 HSV 설정 및 마스킹 처리.
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    masked_purple = (0.7<h)&(h<0.8)&(0.2<s)&(v>0.1)&(v<0.97);
end


function hole = finding_hole(detect_blue)
    % 첫 행을 1로 변환
    for i=1:288
        detect_blue(1,i)=1;
    end
%     % 마지막 행을 1로 변환
%     for i=1:288
%         detect_blue(216,i)=1;
%     end
    % 구멍을 채움
    hole = imfill(detect_blue,'holes');
    
    % 구멍을 채우기 전과 후를 비교하여 값의 변화가 없으면 0, 변화가 있으면 1로 변환
    % 구멍에 해당하는 데이터만 얻는다.
    for x=1:216
        for y=1:288
            if detect_blue(x,y)==hole(x,y)
                hole(x,y)=0;
            end
        end
    end
end


function final_dist = passing_obstacle(hole, p)
    %다중곡선피팅을 통해 모든 거리에 대해서 드론이 전진해야 할 이동거리를 예측.
    disp(sum(sum(hole)))
    reg_exp = polyval(p, sum(sum(hole)));
    dist = reg_exp;
    final_dist = round(dist,3)+0.4
end


function detecting_red(myDrone, cam)
    while 1
        frame = snapshot(cam);
        masked_red = masking_red(frame);
        detect_red_sum = sum(sum(masked_red))
        % 빨간색 표식의 픽셀 수가 400이상이면 표식을 인식한 것으로 간주.
        % 픽셀 수가 400이상이면 반시계 방향으로 90도 회전 한 후, 90cm 전진.
        if detect_red_sum >= 400
            turn(myDrone,deg2rad(-90));
            moveforward(myDrone, "Distance", 1)
            pause(1);
            break
        % 픽셀 수가 400미만이면 400이상이 될 때까지 20cm씩 전진.
        else
            moveforward(myDrone, "Distance", 0.2)
        end
    end
end


function detecting_purple(myDrone, cam)
    while 1
        frame = snapshot(cam);
        masked_purple = masking_purple(frame);
        detect_purple_sum = sum(sum(masked_purple))
        % 보라색 표식의 픽셀 수가 400이상이면 표식을 인식한 것으로 간주.
        % 픽셀 수가 400이상이면 착지.
        if detect_purple_sum >= 400
            land(myDrone)
            pause(1);
            break
        % 픽셀 수가 400미만이면 400이상이 될 때까지 20cm씩 전진.
        else
            moveforward(myDrone, "Distance", 0.2)
        end
    end
end