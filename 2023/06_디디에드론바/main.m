clear
clc
% 처음 시작할 때 위로 올라가는 거리
up_distance = 0.7;
% 처음 시작할 때 뒤로 물러나는 거리
back_distance = 1.0;
% 원을 통과할 때 전진하는 거리
forward_distance = 1.0;
% 원과 드론 사이의 거리에 따라 m/pixel 값이 달라지기 때문에 
% 이것을 magic_num로 정하고 이것을 찾아야됨.
magic_num1 = 0.0025;
magic_num2 = 0.0025;
cal_z_px = 150;
centroids = [];

try
    drone = ryze();
    cam = camera(drone);

    takeoff(drone);
    pause(1);
    disp("UP")
    moveup(drone, 'Distance', up_distance, 'Speed', 0.4)
    disp("BACK")
    moveback(drone, 'Distance', back_distance, 'Speed', 0.4);
        
    count = 0;
    % stage 1
    while 1
        frame = snapshot(cam);
        preview(cam)
        pause(1);

        count = count + 1;
        fprintf("count is %d", count)

        [height, width, channel] = size(frame);
        
        [BW,maskedRGBImage] = createMask(frame);
        
        edge_BW1 = edge(BW, 'Sobel', 'vertical'); 
        edge_BW2 = edge(BW, 'Sobel', 'horizontal');
        edge_BW = (edge_BW1 + edge_BW2);
        fill_im = imfill(edge_BW,'holes');
        figure('Name','fill_im')
        boundaries = bwboundaries(fill_im);
        imshow(fill_im)
         
        stats = regionprops(fill_im, 'Centroid', 'Circularity');
        centroids = cat(1, stats.Centroid);
        figure('Name','position')
        imshow(frame)
        hold on
        plot(centroids(:,1),centroids(:,2),'b*')
        fprintf("x is %d and y is %d\n", centroids(1,1), centroids(1,2))
        
        % while 문 종료 조건
        if 410 < centroids(1, 1) && 530 > centroids(1, 1)
            if 110 <centroids(1, 2) && 190 > centroids(1, 2)
                disp("stage 1 point break")
                % break
            end
        end
        if count == 3
            disp("stage 1 count break")
            break
        end 
        
        if isempty(centroids) == true
            continue
        end
        coord_x = (centroids(1, 1)-width/2)*magic_num1;
        coord_y = (cal_z_px-centroids(1, 2))*magic_num2;
        abs_coord_x = abs(coord_x(1));
        abs_coord_y = abs(coord_y(1));

        if abs_coord_x < 0.2 || abs_coord_x > 5
           coord_x(1) = 0.2;
        end
        if abs_coord_y < 0.2 || abs_coord_y > 5
           coord_y(1) = 0.2;
        end
        
        move(drone,[0 coord_x(1) -coord_y(1)/2])
        pause(1)      
    end

    % stage1 => 2

    disp("forward")
    moveforward(drone, 'Distance', forward_distance + 0.5);
    disp("turn 90")
    turn(drone, deg2rad(90))

    disp("stage1 end")
    moveback(drone, 'Distance', back_distance);
    
    disp("stage2 start")
    % stage2
    count = 0;
    while 1
        frame = snapshot(cam);
        preview(cam)
        pause(1);

        count = count + 1;
        fprintf("count is %d", count)

        [height, width, channel] = size(frame);
        
        [BW,maskedRGBImage] = createMask(frame);
        
        edge_BW1 = edge(BW, 'Sobel', 'vertical'); 
        edge_BW2 = edge(BW, 'Sobel', 'horizontal');
        edge_BW = (edge_BW1 + edge_BW2);
        fill_im = imfill(edge_BW,'holes');
        boundaries = bwboundaries(fill_im);
         
        stats = regionprops(fill_im, 'Centroid', 'Circularity');
        centroids = cat(1, stats.Centroid);
        figure(1)
        imshow(frame)
        hold on
        plot(centroids(:,1),centroids(:,2),'b*')
        fprintf("x is %d and y is %d", centroids(1,1), centroids(1,2))
        
        % while 문 종료 조건
        if 410 < centroids(1, 1) && 530 > centroids(1, 1)
            if 110 <centroids(1, 2) && 190 > centroids(1, 2)
                disp("stage 2 break")
                break
            end
        end
        if count == 3
            disp("stage 2 count break")
            break
        end 
        
        if isempty(centroids) == true
            continue
        end
        coord_x = (centroids(1, 1)-width/2)*magic_num1;
        coord_y = (cal_z_px-centroids(1, 2))*magic_num2;
        abs_coord_x = abs(coord_x(1));
        abs_coord_y = abs(coord_y(1));

        if abs_coord_x < 0.2 || abs_coord_x > 5
           coord_x(1) = 0.2;
        end
        if abs_coord_y < 0.2 || abs_coord_y > 5
           coord_y(1) = 0.2;
        end
        
        move(drone,[0 coord_x(1) -coord_y(1)/2])
        pause(1)      
    end

    % stage2 => 3
    disp("forward")
    moveforward(drone, 'Distance', forward_distance + 0.5);
    disp("turn 90")
    turn(drone, deg2rad(90))

    moveback(drone, 'Distance', back_distance);
    count = 0;
    % stage3
    while 1
        frame = snapshot(cam);
        preview(cam)
        pause(1);

        count = count + 1;

        [height, width, channel] = size(frame);
        
        [BW,maskedRGBImage] = createMask(frame);
        
        edge_BW1 = edge(BW, 'Sobel', 'vertical'); 
        edge_BW2 = edge(BW, 'Sobel', 'horizontal');
        edge_BW = (edge_BW1 + edge_BW2);
        fill_im = imfill(edge_BW,'holes');
        boundaries = bwboundaries(fill_im);
         
        stats = regionprops(fill_im, 'Centroid', 'Circularity');
        centroids = cat(1, stats.Centroid);
        figure(1)
        imshow(frame)
        hold on
        plot(centroids(:,1),centroids(:,2),'b*')
        
        % while 문 종료 조건
        if 410 < centroids(1, 1) && 530 > centroids(1, 1)
            if 110 <centroids(1, 2) && 190 > centroids(1, 2)
                disp("stage 3 break")
                break
            end
        end
        if count == 5
            break
        end 
        
        if isempty(centroids) == true
            continue
        end
        coord_x = (centroids(1, 1)-width/2)*magic_num1;
        coord_y = (cal_z_px-centroids(1, 2))*magic_num2;
        abs_coord_x = abs(coord_x(1));
        abs_coord_y = abs(coord_y(1));

        if abs_coord_x < 0.2 || abs_coord_x > 5
           coord_x(1) = 0.2;
        end
        if abs_coord_y < 0.2 || abs_coord_y > 5
           coord_y(1) = 0.2;
        end
        
        move(drone,[0 coord_x(1) -coord_y(1)/2])
        pause(1)      
    end
    moveforward(drone, 'Distance', forward_distance + 1.0);
    % 도박 45도 회전해서 2m 전진 후 착륙
    turn(drone, deg2rad(45))
    moveforward(drone, 'Distance', forward_distance);
    land(drone)
    
catch error
    disp(error);
    clear;
end

function [BW,maskedRGBImage] = createMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 11-Jul-2023
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.389;
channel1Max = 0.658;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.509;
channel2Max = 0.765;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.380;
channel3Max = 0.835;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end


