clc; clear all;

drone = ryze("Tello");

dronecamera = camera(drone);

preview(dronecamera);

takeoff(drone);
%1
moveforward(drone, 'Distance', 0.2, 'speed', 0.7);
pause(1);
% 첫 번째 모서리에서 파란색이 있는지 확인
blueDetected = false;
moveup(drone, 'Distance', 0.3, 'speed', 0.7);
pause(1);
while ~blueDetected
    
    %카메라프레임 캡쳐
    frame = snapshot(dronecamera);
    hsv = rgb2hsv(frame);
      % 파란색의 HSV 범위를 설정합니다.
    hueMin = 0.5;
    hueMax = 0.7;
    saturationMin = 0.3;
    saturationMax = 1.0;
    valueMin = 0.3;
    valueMax = 1.0;
    
    % 파란색에 해당하는 마스크를 생성합니다.
    blueMask = (hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax) & ...
               (hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax) & ...
               (hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax);
    % 왼쪽 위 모서리에서 파란색이 있는지 확인
    blueDetected = any(blueMask(1:50, 1:50), 'all');
    if blueDetected
        blueDetected = any(blueMask(1:50, end-49:end), 'all');
     if blueDetected
         % 오른쪽 아래 모서리에서 파란색이 있는지 확인
         blueDetected = any(blueMask(end-49:end, end-49:end), 'all');
         if blueDetected
             movedown(drone, 'Distance', 0.2, 'speed', 0.7);
             pause(1);
             moveforward(drone, 'Distance', 2.0, 'speed', 0.7);
             pause(1);
             % 빨간색을 인식하면 오른쪽으로 90도 회전
             redDetected = false;
             while ~redDetected
                % 카메라 프레임 캡처
                frame = snapshot(dronecamera);
                hsv = rgb2hsv(frame);
                
                % 빨간색의 HSV 범위를 설정
               hueMin = 0; 
               hueMax = 0.1;
               saturationMin = 0.5; 
               saturationMax = 1;
               valueMin = 0.5; 
               valueMax = 1;

                % 빨간색에 해당하는 마스크 생성
                redMask = ((hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax)) & ...
                          ((hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax)) & ...
                          ((hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax));
                
                % 빨간색이 있는지 확인
                redDetected = any(redMask, 'all');
                
                if redDetected
                    % 오른쪽으로 90도 회전
                    turn(drone, deg2rad(90));
                    break;
                end
            end
         else 
             moveup(drone, 'Distance', 0.2, 'speed', 0.7);
             pause(1);
         end   
     else
         moveleft(drone, 'Distance', 0.4, 'speed', 0.7);
         pause(1);
     end     

    else
         moveright(drone, 'Distance', 0.4, 'speed', 0.7);
         pause(1);
         moveup(drone, 'Distance', 0.2, 'speed', 0.7);
         pause(1);
    end
end

%2
moveforward(drone, 'Distance', 0.4, 'speed', 0.7);

while ~blueDetected
    
    %카메라프레임 캡쳐
    frame = snapshot(dronecamera);
    hsv = rgb2hsv(frame);
      % 파란색의 HSV 범위를 설정합니다.
    hueMin = 0.5;
    hueMax = 0.7;
    saturationMin = 0.3;
    saturationMax = 1.0;
    valueMin = 0.3;
    valueMax = 1.0;
    
    % 파란색에 해당하는 마스크를 생성합니다.
    blueMask = (hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax) & ...
               (hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax) & ...
               (hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax);
    % 왼쪽 위 모서리에서 파란색이 있는지 확인
    blueDetected = any(blueMask(1:50, 1:50), 'all');
    if blueDetected
        blueDetected = any(blueMask(1:50, end-49:end), 'all');
     if blueDetected
         % 오른쪽 아래 모서리에서 파란색이 있는지 확인
         blueDetected = any(blueMask(end-49:end, end-49:end), 'all');
         if blueDetected
             movedown(drone, 'Distance', 0.2, 'speed', 0.7);
             pause(1);
             moveforward(drone, 'Distance', 1.6, 'speed', 0.7);
             pause(1);
             % 빨간색을 인식하면 오른쪽으로 90도 회전
             redDetected = false;
             while ~redDetected
                % 카메라 프레임 캡처
                frame = snapshot(dronecamera);
                hsv = rgb2hsv(frame);
                
                % 빨간색의 HSV 범위를 설정
               hueMin = 0; 
               hueMax = 0.1;
               saturationMin = 0.5; 
               saturationMax = 1;
               valueMin = 0.5; 
               valueMax = 1;

                % 빨간색에 해당하는 마스크 생성
                redMask = ((hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax)) & ...
                          ((hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax)) & ...
                          ((hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax));
                
                % 빨간색이 있는지 확인
                redDetected = any(redMask, 'all');
                
                if redDetected
                    % 오른쪽으로 90도 회전
                    turn(drone, deg2rad(90));
                    break;
                end
            end
         else 
             moveup(drone, 'Distance', 0.2, 'speed', 0.7);
             pause(1);
         end   
     else
         moveleft(drone, 'Distance', 0.4, 'speed', 0.7);
         pause(1);
     end     

    else
         moveright(drone, 'Distance', 0.4, 'speed', 0.7);
         pause(1);
         moveup(drone, 'Distance', 0.2, 'speed', 0.7);
         pause(1);
    end
end

%3
moveforward(drone, 'Distance', 0.4, 'speed', 0.7);

while ~blueDetected
    
    %카메라프레임 캡쳐
    frame = snapshot(dronecamera);
    hsv = rgb2hsv(frame);
      % 파란색의 HSV 범위를 설정합니다.
    hueMin = 0.5;
    hueMax = 0.7;
    saturationMin = 0.3;
    saturationMax = 1.0;
    valueMin = 0.3;
    valueMax = 1.0;
    
    % 파란색에 해당하는 마스크를 생성합니다.
    blueMask = (hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax) & ...
               (hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax) & ...
               (hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax);
    % 왼쪽 위 모서리에서 파란색이 있는지 확인
    blueDetected = any(blueMask(1:50, 1:50), 'all');
    if blueDetected
        blueDetected = any(blueMask(1:50, end-49:end), 'all');
     if blueDetected
         % 오른쪽 아래 모서리에서 파란색이 있는지 확인
         blueDetected = any(blueMask(end-49:end, end-49:end), 'all');
         if blueDetected
             movedown(drone, 'Distance', 0.2, 'speed', 0.7);
             pause(1);
             moveforward(drone, 'Distance', 1.6, 'speed', 0.7);
         else 
             moveup(drone, 'Distance', 0.2, 'speed', 0.7);
             pause(1);
         end   
     else
         moveleft(drone, 'Distance', 0.4, 'speed', 0.7);
         pause(1);
     end     

    else
         moveright(drone, 'Distance', 0.4, 'speed', 0.7);
         pause(1);
         moveup(drone, 'Distance', 0.2, 'speed', 0.7);
         pause(1);
    end
end
%4
% 초록색의 HSV 범위를 설정합니다.
hueMin = 0.2;
hueMax = 0.4;
saturationMin = 0.4;
saturationMax = 1.0;
valueMin = 0.4;
valueMax = 1.0;

% 초록색에 해당하는 마스크를 생성합니다.
greenMask = (hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax) & ...
            (hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax) & ...
            (hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax);

% 초록색이 있는지 확인합니다.
greenDetected = any(greenMask, 'all');

if greenDetected
    % 오른쪽으로 30도 회전합니다.
    turn(drone, deg2rad(30));
end

%5
while ~blueDetected
    
    %카메라프레임 캡쳐
    frame = snapshot(dronecamera);
    hsv = rgb2hsv(frame);
      % 파란색의 HSV 범위를 설정합니다.
    hueMin = 0.5;
    hueMax = 0.7;
    saturationMin = 0.3;
    saturationMax = 1.0;
    valueMin = 0.3;
    valueMax = 1.0;
    
    % 파란색에 해당하는 마스크를 생성합니다.
    blueMask = (hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax) & ...
               (hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax) & ...
               (hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax);
    imageWidth = size(blueMask, 2);
    blueDetected = any(blueMask(:, imageWidth), 'all');

    if blueDetected
        blueDetected = any(blueMask(:, 1),'all');
        if blueDetected
            blueDetected = any(blueMask(1:50, 1:50), 'all');
             if blueDetected
                 blueDetected = any(blueMask(1:50, end-49:end), 'all');
                 if blueDetected
                 % 오른쪽 아래 모서리에서 파란색이 있는지 확인
                     blueDetected = any(blueMask(end-49:end, end-49:end), 'all');
                     if blueDetected
                         movedown(drone, 'Distance', 0.2, 'speed', 0.7);
                         pause(1);
                         %6
                         % 보라색의 HSV 범위를 설정합니다.
                         hueMin = 0.75;
                         hueMax = 0.85;
                         saturationMin = 0.4;
                         saturationMax = 1.0;
                         valueMin = 0.4;
                         valueMax = 1.0;

                         % 목표 거리 설정 (2m)
                         targetDistance = 200;  % cm

                         while true
                          % 카메라 프레임 캡처
                          frame = snapshot(dronecamera);
                          hsv = rgb2hsv(frame);

                          % 보라색에 해당하는 마스크를 생성합니다.
                          purpleMask = (hsv(:,:,1) >= hueMin) & (hsv(:,:,1) <= hueMax) & ...
                                       (hsv(:,:,2) >= saturationMin) & (hsv(:,:,2) <= saturationMax) & ...
                                       (hsv(:,:,3) >= valueMin) & (hsv(:,:,3) <= valueMax);

                          % 보라색 객체의 특성을 추출합니다.
                          stats = regionprops(purpleMask, 'Area', 'Centroid');

                          % 보라색 객체 중 넓이가 10cm x 10cm인 사각형을 검출합니다.
                          targetArea = 10 * 10;  % cm^2
                          for i = 1:numel(stats)
                              area = stats(i).Area;
                              centroid = stats(i).Centroid;
                              if abs(area - targetArea) < targetArea * 0.2
                                  % 드론과 객체 사이의 거리 계산
                                  distance = sqrt((centroid(1) - imageWidth/2)^2 + (centroid(2) - imageHeight/2)^2);
            
                                  % 거리 조정
                                 if distance < targetDistance - 10
                                     moveforward(drone, 'Distance', 0.2);
                                 elseif distance > targetDistance + 10
                                     movedown(drone, 'Distance', 0.2);
                                 else
                                 break;  % 목표 거리 도달
                                 end
                              end
                         end
    
                         % 다시 객체를 검출하지 못한 경우 종료
                         if i == numel(stats)
                           break;
                         end
                        end
                        % 착륙 명령 실행
                        land(drone);
                     else 
                         moveup(drone, 'Distance', 0.2, 'speed', 0.7);
                         pause(1);
                     end   
                 else 
                     moveleft(drone, 'Distance', 0.4, 'speed', 0.7);
                     pause(1);
                 end     

             else
                moveright(drone, 'Distance', 0.4, 'speed', 0.7);
                pause(1);
                moveup(drone, 'Distance', 0.2, 'speed', 0.7);
                pause(1);
             end
        else 
            turn(drone, deg2rad(5));
            moveforward(drone, 'Distance', 0.2, 'speed', 0.7);
        end
    else
        turn(drone, deg2rad(5));
    end    
end        