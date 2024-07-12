clear all;
clc;
% Initialize drone and camera
drone = ryze()
cameraObj = camera(drone);
% Take off
takeoff(drone);
preview(cameraObj);
% Set constants
width_ = 960;
height_ = 720;
center = [width_/2, height_/2 - 180];
offset = [round(height_/20), round(height_/20)];
mode = 0;
%     disp(x);
% Initial movement
move(drone, [-0.4, 0, -0.2], 'WaitUntilDone', true);
while true
    hold off;
    frame = snapshot(cameraObj);
    subplot(2,2,2);
    imshow(frame);
    
    % Convert to HSV
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    % Detect colors
    % detect_ring = (0.53<h)&(h<0.625)&(0.55<s)&(s<0.9);
    % detect_red = ((0.95<h) | (h<0.1)) & (0.25<s);
    % detect_green = (0.33<h) & (h<0.405) & (0.45<s);
    % detect_purple = (h>0.655) & (h<0.725) & (0.25<s);
       
    % 대회용 threshold
    detect_ring = (0.58<h)&(h<0.635)&(0.35<s)&(s<0.9);
    % detect_red = ((0.95<h)&(h<1)|(0<h)&(h<0.05));
    detect_red = ((0.95<h) | (h<0.1)) & (0.25<s);
    detect_green = (0.33<h) & (h<0.405) & (0.15<s);
    detect_purple = (h>0.655) & (h<0.725) & (0.25<s);
    % 
    disp("current mode : " + mode)
    
    switch mode
        case 0 
            % Pass through the ring
            [centroids, move_vector] = process_detected_objects(detect_ring, center, offset);
            if move_drone(drone, move_vector)
                moveforward(drone, 'Distance', 3.0, 'Speed', 1, 'WaitUntilDone', true);
                mode = 1;
            end
        case 1
            % Move to red rectangle and 
            % Move 3m to align ring in front of green marker
            move_vector = align_to_red(drone, detect_red, center, offset, 12000, 3.5, 130);
            if isempty(move_vector)
                mode = 2;
            end
        case 2
            % Align center and Move 1.5m 
            [centroids, move_vector] = process_detected_objects(detect_ring, center, offset);
            if move_drone(drone, move_vector)
                moveforward(drone, 'Distance', 1.5, 'Speed', 1, 'WaitUntilDone', true);
                mode = 3;
            end
        case 3
            % Approach green marker
            % and -130deg turn and  1.0m move
            % purple threshold 4000
            move_vector = align_to_color(drone, detect_green, center, offset, 2000, 0.0, -130);
            if isempty(move_vector)
                mode = 4;
            end
        case 4
            % Align center and Move 1.0m 
%             [centroids, move_vector] = process_detected_objects(detect_ring, center, offset);
%             if move_drone(drone, move_vector)
%                 % 현재 우리 map은 3.1m 대회는 4.0m
%                 moveforward(drone, 'Distance', 2.0, 'Speed', 1, 'WaitUntilDone', true);
%                 mode = 5;
%             end
            [centroids, move_vector] = process_detected_objects_for_purple(detect_ring, center, offset);
            move_vector(:,1) = 3.1;
            if norm(move_vector) > 0.05
                disp("Moving");
                move(drone, move_vector, 'WaitUntilDone', true,'Speed',1);
            else
                move(drone, [3.1,0,0], 'WaitUntilDone', true,'Speed',1);
                disp("Aligned");
            end
            mode = 5;
        case 5
            % Move to purple marker
            % and 220 deg turn and  1.0m move
            move_vector = align_to_color(drone, detect_purple, center, offset, 5000, 1.5, 225);
            % move_vector = align_to_color(drone, detect_purple, center, offset, 5000, 1.0, 230);
            if isempty(move_vector)
                mode = 6;
            end
        
        case 6
            % Rotate to align yaw
            centroids = find_center(detect_ring);
            diff_x = centroids(:,1) - width_ / 2;
            disp("Rotating to align yaw, diff_x : " + diff_x);
%             if abs(diff_x) < -10
%                 turn(drone, deg2rad(diff_x * 0.1));
%             else
%                 turn(drone, deg2rad(-10));
% %                 moveforward(drone, 'Distance', 1.8, 'Speed', 1, 'WaitUntilDone', true);
%                 mode = 7;
%             end
            if abs(diff_x) > 15
                turn(drone, deg2rad(diff_x * 0.1));
            else
                % moveforward(drone, 'Distance', 1.8, 'Speed', 1, 'WaitUntilDone', true);
                mode = 7;
            end
        case 7
            % Align center and Move 2.0m 
            [centroids, move_vector] = process_detected_objects(detect_ring, center, offset);
            if move_drone(drone, move_vector)
                % moveforward(drone, 'Distance', 2.5, 'Speed', 1, 'WaitUntilDone', true);
                moveforward(drone, 'Distance', 2.8, 'Speed', 1, 'WaitUntilDone', true);
                mode = 9;
            end
%         case 8
%             % Move to red marker
%             move_vector = align_to_color(drone, detect_red, center, offset, 10000, 0.0, 0);
%             if isempty(move_vector)
%                 mode = 9;
%             end
        case 9
            % Align center only Y axis control
            move_vector = last_align_to_color(drone, detect_red);
%             if isempty(move_vector)
%                 mode = 10;
%             end
           mode = 10;
        case 10
            % Land
            land(drone);
            break;
    end
end
function [centroids, move_vector] = process_detected_objects(detect, center, offset)
    centroids = find_center(detect);
    displace = centroids - center;
    if norm(displace) > 175
        move_vector = [0, 0.4 * ((displace > offset) - (displace < -offset))];
    else
        move_vector = [0, 0.2 * ((displace > offset) - (displace < -offset))];
    end
end
function [centroids, move_vector] = process_detected_objects_for_purple(detect, center, offset)
    centroids = find_center(detect);
    displace = centroids - center;
    diff = ((displace > offset) - (displace < -offset));
    diff_y = diff(1);
    diff_z = diff(2);
    if abs(displace(1)) > 50 && abs(displace(1)) < 100
        move_vector = [0, 0.4 * diff_y, 0.2 * diff_z];
    elseif abs(displace(1)) > 100 && abs(displace(1)) < 150
        move_vector = [0, 0.6 * diff_y, 0.2 * diff_z];
        disp("y axis 0.6m ")
    elseif abs(displace(1)) > 150 
        move_vector = [0, 0.8 * diff_y, 0.2 * diff_z];
        disp("y axis 0.8m ")
    else
        move_vector = [0, 0.2 * diff_y , 0.2 * diff_z];
    end
end
function moved = move_drone(drone, move_vector)
    disp("distance from center : " + norm(move_vector));
    if norm(move_vector) > 0.05
        disp("Moving");
        move(drone, move_vector, 'WaitUntilDone', true);
        moved = false;
    else
        disp("Aligned");
        moved = true;
    end
end
function move_vector = align_to_color(drone, detect, center, offset, threshold, forward_distance, turn_angle)
    binary = bwareafilt(detect, 1);
    if sum(binary, 'all') <= threshold
        move_vector = [0.2, 0.0, 0.0];
        s = regionprops(binary, 'centroid');
        if ~isempty(s)
            center = [960/2, 720/2 - 180];
            displace = s.Centroid - center;
            move_vector = [0.2, 0.2 * ((displace > offset) - (displace < -offset))];
        end
        move(drone, move_vector, 'WaitUntilDone', true);
    
    else
        turn(drone, deg2rad(turn_angle));
        if ~(forward_distance == 0)
            moveforward(drone, 'Distance', forward_distance, 'Speed', 1, 'WaitUntilDone', true);
        end
        move_vector = [];
    end
end
function move_vector = align_to_red(drone, detect, center, offset, threshold, forward_distance, turn_angle)
    a = 4.03384320e-08;
    b = -4.33292888e-03;
    c = 1.24805685e+02;
%     a = 5.44326213e-08;
%     b = -5.65017034e-03;
%     c = 1.43016828e+02;
    binary = bwareafilt(detect, 1);
    x = sum(binary,'all');
    if sum(binary, 'all') <= threshold
        depth = a * x * x + b * x + c;
        
        fprintf("move : %f \n",depth - 40);
        move_distance = (depth - 40) / 100;
        move_vector = [move_distance, 0.0, 0.0];
        s = regionprops(binary, 'centroid');
        if ~isempty(s)
            center = [960/2, 720/2 - 180];
            displace = s.Centroid - center;
            move_vector = [move_distance, 0.2 * ((displace > offset) - (displace < -offset))];
        end
        move(drone, move_vector, 'WaitUntilDone', true, 'Speed', 1);
    
    else
        turn(drone, deg2rad(turn_angle));
        if ~(forward_distance == 0)
            moveforward(drone, 'Distance', forward_distance, 'Speed', 1, 'WaitUntilDone', true);
        end
        move_vector = [];
    end
end
function move_vector = last_align_to_color(drone, detect)
    binary = bwareafilt(detect, 1);
    a = 4.03384320e-08;
    b = -4.33292888e-03;
    c = 1.24805685e+02;    
%     a = 5.44326213e-08;
%     b = -5.65017034e-03;
%     c = 1.43016828e+02;
    
%     if sum(binary, 'all') >= 13000
%         move(drone, [-0.2 ,0, 0], 'WaitUntilDone', true);
%         disp("So close")
%     end
    x = sum(binary,'all'); 
    depth = a * x * x + b * x + c;    
    fprintf("move : %f \n",depth - 60);
    move_distance = (depth - 60) / 100;

    if move_distance < 0.2
        move_distance = 0;
    elseif move_distance < 0
        move_distance = -0.2;
    end
    
    s = regionprops(binary,'centroid','Area');
    area = s.Area;
    selection = (area > 900);
    rect_centroids = cat(1,s.Centroid);
    center_x = rect_centroids(selection,1);
    center_y = rect_centroids(selection,2);
    displace = ([center_x, 0] - [480 ,0]);
    disp(displace);
    xy_margin = [100, 100];
    thres = abs(fix(displace(1)/100));
    if thres == 1
        thres = 2;
    end
    
    move_vector = [move_distance, 0.1 * thres* ((displace > xy_margin)-(displace < -xy_margin))];
    if norm(move_vector) > 0
        move(drone, move_vector, 'WaitUntilDone', true, 'Speed', 1);
    else
        move_vector = [];
    end
end
function centroids = find_center(detect)
    binary_res = bwareafilt(detect, 1);

    [row, col] = find(binary_res);
    locmin = [min(row), min(col)];
    locmax = [max(row), max(col)];
    screen_center = (locmin + locmax) / 2;
    if screen_center(1) <= 360
        binary_res(1,:) = 1;
    else
        binary_res(end,:) = 1;
    end
    if screen_center(2) <= 480
        binary_res(:,1) = 1;
    else
        binary_res(:,end) = 1;
    end

    no_hole = binary_res;

    subplot(2,2,2);
    imshow(binary_res);
    binary_res = imfill(binary_res, 'holes');
    subplot(2,2,3);
    imshow(binary_res);
    hole_reg = xor(no_hole, binary_res);
    hole_reg = bwareafilt(hole_reg, 1);
    if sum(hole_reg, 'all') < 250
        hole_reg = no_hole;
    end
    subplot(2,2,4);
    imshow(hole_reg);
    hold on;
    B = bwboundaries(hole_reg);
    for k = 1:length(B)
       boundary = B{k};
       plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
    end
    s = regionprops(hole_reg, 'centroid');
    centroids = cat(1, s.Centroid);
    plot(centroids(:,1), centroids(:,2), 'b*');
end
