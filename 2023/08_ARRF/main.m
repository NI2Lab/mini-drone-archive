clear; clc;

baseSpeed = 0.7;
baseDistance = 0.5;
basePauseTime = baseDistance/baseSpeed;
w = 960;
h = 720;
wcenter = w/2;
hcenter = h/2-170;

droneObj = ryze("Tello")
takeoff(droneObj)   

% for finding circle
move(droneObj,[-1.0 0 -0.7],'Speed',baseSpeed);
pause(1.0/baseSpeed);

cameraObj = camera(droneObj);
pause(0.5);

backDistance = 1.5;

%% Step 1,2
for i=1:2
    % Find circle center
    [centerX, centerY, backDistance] = findCircleCenter(cameraObj,droneObj,backDistance);
    if backDistance > 1.5
        pause(backDistance-0.5);
    end
    
    depth = backDistance-0.6;
    delX = centerX - wcenter;
    delZ = hcenter - centerY;
    [movingY, movingZ] = movingDistance(depth, delX, delZ,w,h);
    if ~((movingY == 0) & (movingZ == 0))
        move(droneObj,[0 movingY -movingZ],'Speed',baseSpeed);
        pause(2);
        % pause(max(abs(movingY),abs(movingZ))/baseSpeed+1.0);
    end
    
    moveforward(droneObj,'Distance',backDistance+0.7,'Speed',baseSpeed);
    pause((backDistance+0.7)/basePauseTime+0.5);
    
    pause(1.5);
    turn(droneObj,deg2rad(90));
    pause(2);
    
    backDistance = 1.5;
end

%% Step 3
for cnt=1:2
    % Find circle center
    [centerX, centerY, backDistance] = findCircleCenter(cameraObj,droneObj,backDistance);
    if backDistance > 1.5
        pause(backDistance-0.5);
    end

    depth = backDistance-0.6;
    delX = centerX - wcenter;
    delZ = hcenter - centerY;
    [movingY, movingZ] = movingDistance(depth, delX, delZ,w,h);
    if ~((movingY == 0) & (movingZ == 0))
        move(droneObj,[0.2 movingY -movingZ],'Speed',baseSpeed);  
        backDistance = backDistance-0.2;
        pause(max(abs(movingY),abs(movingZ))/baseSpeed+1.0);
    else
        break;
    end
end
moveforward(droneObj,'Distance',backDistance+0.8,'Speed',baseSpeed);
pause((backDistance+0.8)/basePauseTime+0.5);

pause(1.5);
turn(droneObj,deg2rad(45));
pause(2);

%% Step 4
backDistance = 1.5;
delX = 0.0;
for cnt=1:3
    % Find circle center
    [centerX, centerY, backDistance] = findCircleCenter(cameraObj,droneObj,backDistance);
    if backDistance > 1.5
        pause(backDistance-0.5);
    end

    depth = backDistance-0.1;
    delX = centerX - wcenter;
    delZ = hcenter - centerY;
    [movingY, movingZ] = movingDistance(depth, delX, delZ,w,h);

    [LAND,area] = detecPurple(cameraObj);
    if LAND
        break;
    end

    if ~((movingY == 0) & (movingZ == 0))
        move(droneObj,[0.2 movingY -movingZ],'Speed',baseSpeed);  
        backDistance = backDistance-0.2;
        pause(max(abs(movingY),abs(movingZ))/baseSpeed+1.0);

        [centerX, centerY, backDistance] = findCircleCenter(cameraObj,droneObj,backDistance);
        if backDistance > 1.5
            pause(backDistance-0.5);
        end
    
        depth = backDistance-0.1;
        delX = centerX - wcenter;
        delZ = hcenter - centerY;

        if delX < -w/4
            turn(droneObj,deg2rad(-10));
            pause(2);
        elseif delX > w/4
            turn(droneObj,deg2rad(10));
            pause(2);
        end
    else
        if area == 0
            if delX < 0
                turn(droneObj,deg2rad(-15));
            else
                turn(droneObj,deg2rad(15));
            end
            pause(1);
        else
            if delX < -w/4
                moveleft(droneObj,0.5,'Speed',baseSpeed);  
            elseif delX > w/4
                moveright(droneObj,0.5,'Speed',baseSpeed);
            elseif area > 2200
                moveback(droneObj,'Distance',0.5,'Speed',baseSpeed);
            else
                moveforward(droneObj,'Distance',0.5,'Speed',baseSpeed);
            end
            pause(1.0);
            backDistance = backDistance-0.5;
        end

        if LAND
            break;
        end
    end
end

[LAND,area] = detecPurple(cameraObj);
if area == 0
    if (delX < -w/4)
        move(droneObj,[1.0 -1.0 0],'Speed',baseSpeed);  
    elseif (delX > w/4)
        move(droneObj,[1.0 1.0 0],'Speed',baseSpeed); 
    elseif delX > 0
        move(droneObj,[0.5 -0.5 0],'Speed',baseSpeed); 
    elseif delX < 0
        move(droneObj,[0.5 0.5 0],'Speed',baseSpeed); 
    end
    pause(1.5)
elseif area < 800
    if delX > 0
        move(droneObj,[0.5 -0.5 0],'Speed',baseSpeed);  
    else
        move(droneObj,[0.5 0.5 0],'Speed',baseSpeed); 
    end
    pause(1.2);
elseif ~LAND
    moveforward(droneObj,'Distance',0.5,'Speed',baseSpeed);
    pause(1.0);
end

land(droneObj)


%% Functions
function [movingY, movingZ] = movingDistance(depth, delX, delZ,w,h)
    movingY = depth*tan(deg2rad(41.3))*delX/(w/2);
    movingZ = depth*tan(deg2rad(41.3))*delZ/(h/2);
    if abs(movingY) < 0.2
        movingY = 0;
    end
    if abs(movingZ) < 0.2
        movingZ = 0;
    end
end

function [LAND,area] = detecPurple(cameraObj)
    [frame,~] = snapshot(cameraObj);
    hsvImage = rgb2hsv(frame);
    
    % Red color range  
    purpleHMin = 0.5;     
%     purpleHMax = 0.8;
    purpleHMax = 1.0;
%     purpleSMin = 0.3;
    purpleSMin = 0.2;
    purpleSMax = 0.6;
    purpleVMin = 0.45;
    purpleVMax = 0.7;
    
    % Create a filter to select pixels with saturation greater than 0.1
    s = hsvImage(:,:,2);
    filter = s>0.1;     
    
    % Create a mask for the green region
    purpleMask = (hsvImage(:,:,1)>purpleHMin) & (hsvImage(:,:,1)<=purpleHMax) ...
        & (hsvImage(:,:,2)>purpleSMin) & hsvImage(:,:,2)<=purpleSMax...
        & (hsvImage(:,:,3)>purpleVMin) & hsvImage(:,:,3)<=purpleVMax;
    purpleMask = purpleMask.*filter;
    
    % Create a disk-shaped structuring element with a radius of 9
    se = strel('disk',8);
    purpleMask = imopen(purpleMask,se);

    LAND = false;
    purpleImg = frame;
    purpleImg(repmat(~purpleMask, [1 1 3])) = 0;

    area = length(find(purpleMask == 1));

    if (1200 < length(find(purpleMask == 1))) & (length(find(purpleMask == 1)) < 2100)
        LAND = true;
    end

    % Display the results
    figure(2);
    subplot(1, 2, 1);
    imshow(frame);
    title('Original Image');
    
    subplot(1, 2, 2);
    purpleImg = frame;
    purpleImg(repmat(~purpleMask, [1 1 3])) = 0;
    imshow(purpleImg);
    title('Purple Image');
end

function correct = isCenterCorrect(centerX,centerY,blueMask)
    correct = true;
    centerX = round(centerX);
    centerY = round(centerY);
    for i=-10:10
        for j=-10:10
            if blueMask(centerY+j,centerX+i) > 0
                correct = false;
                break;
            end
        end
        if ~correct
            break;
        end
    end
end

function [centerX, centerY, forward_distance] = findCircleCenter(cameraObj,droneObj,forward_distance)
    baseSpeed = 0.7;
    baseDistance = 0.5;
    basePauseTime = baseDistance/baseSpeed+0.5;
    isDone = false;
    while ~isDone
        [frame,~] = snapshot(cameraObj);
    
        % Blue Region Mask Creation
        hsvImage = rgb2hsv(frame);
    
        % Blue color range  
        blueHMin = 0.56;     
        blueHMax = 0.67;   
        blueSMin = 0.5;
        blueSMax = 0.9;
        
        % Create a filter to select pixels with saturation greater than 0.1
        s = hsvImage(:,:,2);
        filter = s>0.1;     
        
        % Create a mask for the green region
        blueMask = (hsvImage(:,:,1)>blueHMin) & (hsvImage(:,:,1)<=blueHMax) ...
            & (hsvImage(:,:,2)>blueSMin) & hsvImage(:,:,2)<=blueSMax;
        blueMask = blueMask.*filter;
        
        % Create a disk-shaped structuring element with a radius of 9
        se = strel('disk',8);
        blueMask = imopen(blueMask,se); 
        
        % Display the results
        blueImg = frame;
        blueImg(repmat(~blueMask, [1 1 3])) = 0;
        grayImage = im2gray(blueImg);
        edgeImage = edge(grayImage, 'Canny'); 
       
        % Circle Detection and Centroid Extraction
        % Obtain the properties of the connected components in the edge image
        props = regionprops(edgeImage, 'Area', 'BoundingBox', 'Centroid');
        
        % Find the component with a shape that resembles a square (based on area)
        validSquares = [];
        for i = 1:numel(props)
            area = props(i).Area;   
            areaThreshold = 500; % Minimum area
        
            if area > areaThreshold
                validSquares = [validSquares; props(i)];
            end
        end
        
        % Sort the areas of the valid squares in descending order
        % validSquares
        if length(validSquares) == 0
            moveback(droneObj,'Distance',0.5,'Speed',baseSpeed);
            forward_distance = forward_distance+0.5;
            pause(basePauseTime);
            continue;
        end
        [~, idx] = sort([validSquares.Area],'descend');
        

        if length(idx) == 1
            moveback(droneObj,'Distance',0.5,'Speed',baseSpeed);
            forward_distance = forward_distance+0.5;
            pause(basePauseTime);
            continue;
        end

        % Get the centroid of the chosen square(the second largest area (idx == 2))
        centroid = validSquares(find(idx==2)).Centroid;
        
        
        % Display the center coordinates
        centerX = centroid(1);
        centerY = centroid(2);
        
        figure(1);
        imshow(frame);
        hold on;
        plot(centerX, centerY, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        fprintf('Center coordinates: (%.3f, %.3f)\n', centerX, centerY);

        if ~isCenterCorrect(centerX,centerY,blueMask)
            moveback(droneObj,'Distance',0.5,'Speed',baseSpeed)
            forward_distance = forward_distance+0.5;
            pause(basePauseTime);
        else
            isDone = true;
        end
        hold off;
    end
end