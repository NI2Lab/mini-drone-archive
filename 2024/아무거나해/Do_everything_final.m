clear all;
clc;


% 카메라 파라미터 설정
focalLength = [957.1698 963.1543];
principalPoint = [495.3551 394.4279];
imageSize = [720 960];
radialDistortion = [-0.0337 0.1373];
tangentialDistortion = [0.0058 0.0034];

% IntrinsicMatrix 구성
intrinsicMatrix = [focalLength(1), 0, principalPoint(1); 
                   0, focalLength(2), principalPoint(2); 
                   0, 0, 1]';

cameraParams = cameraParameters('IntrinsicMatrix', intrinsicMatrix, ...
                                'RadialDistortion', radialDistortion, ...
                                'TangentialDistortion', tangentialDistortion, ...
                                'ImageSize', imageSize);
% 드론 객체 생성 및 연결
global droneObj;
droneObj = ryze();
disp(['Battery Level: ' num2str(droneObj.BatteryLevel) '%']);

% 카메라 객체 생성
global cameraObj;
cameraObj = camera(droneObj);
% 프리뷰 창 생성
figure;
hImage = imshow(snapshot(cameraObj)); % 초기 이미지를 보여줌
axis off;
title('Tello 드론 카메라 프리뷰');

% 프리뷰 활성화
preview(cameraObj, hImage);

% 사용자에게 드론을 이동시키라고 지시
% disp('드론을 이동시키고 "확인"을 누르세요. 현재 이미지 촬영 완료.');
% pause; % 사용자에게 드론을 이동시킬 시간을 줌


takeoff(droneObj);


function[x,y,z,t] = circle(radious, minr,maxr)
    global cameraObj;
    % 카메라 파라미터 설정
    focalLength = [957.1698 963.1543];
    principalPoint = [495.3551 394.4279];
    imageSize = [720 960];
    radialDistortion = [-0.0337 0.1373];
    tangentialDistortion = [0.0058 0.0034];
    
    % IntrinsicMatrix 구성
    intrinsicMatrix = [focalLength(1), 0, principalPoint(1); 
                       0, focalLength(2), principalPoint(2); 
                       0, 0, 1]';
    
    cameraParams = cameraParameters('IntrinsicMatrix', intrinsicMatrix, ...
                                    'RadialDistortion', radialDistortion, ...
                                    'TangentialDistortion', tangentialDistortion, ...
                                    'ImageSize', imageSize);

    % 사진 촬영
    frame = snapshot(cameraObj);
    
    % 보정된 이미지 생성
    image = undistortImage(frame, cameraParams);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % HSV 색 공간으로 변환
    hsvImage = rgb2hsv(image);
    
    % 푸른색 범위 설정 (HSV 값 기준)
    blueMask = (hsvImage(:,:,1) >= 0.45 & hsvImage(:,:,1) <= 0.7) & ...
               (hsvImage(:,:,2) >= 0.25 & hsvImage(:,:,2) <= 1.0) & ...
               (hsvImage(:,:,3) >= 0.25 & hsvImage(:,:,3) <= 1.0);
        
    % 마스크 적용
    filteredImage = bsxfun(@times, image, cast(blueMask, 'like', image));
    
    % 결과 표시
    % figure;
    % imshow(filteredImage);
    % title('Filtered Blue Regions');
    
    %---------------------------------------------------%
    
    % 이진화
    binaryImage = imbinarize(rgb2gray(filteredImage));
    
    % imshow(binaryImage)
    
    % 원 감지 (Hough 변환 사용)
    [centers, radii] = imfindcircles(binaryImage, [minr maxr], 'ObjectPolarity', 'dark', 'Sensitivity', 0.97);
    
    % 원 중심 좌표
    t = 1;
    try
        new_centers = [];
        new_radii = [];
        if length(centers(:,1)) == 1
            new_centers = centers;
            new_radii = radii;
        else
            for i= 1:length(centers(:,1))
                if (340 <= centers(i,1)) && (centers(i,1) <= 630)
                    new_centers = [new_centers; centers(i,:)];
                    new_radii = [new_radii; radii(i)]
                end
            end
        end
        [maxValue, maxIndex] = max(new_radii);

        circleCenter = new_centers(maxIndex, :);
        circleradii = maxValue;

        fprintf('Detected circle center: (%.2f, %.2f)\n', circleCenter(1), circleCenter(2));
        
        %-------------------------------------%
        % 카메라 파라미터 설정
        focalLength = [957.1698 963.1543];
        principalPoint = [495.3551 394.4279];
        imageSize = [720 960];
        radialDistortion = [-0.0337 0.1373];
        tangentialDistortion = [0.0058 0.0034];
        
        % IntrinsicMatrix 구성
        intrinsicMatrix = [focalLength(1), 0, principalPoint(1); 
                           0, focalLength(2), principalPoint(2); 
                           0, 0, 1]';
        
        cameraParams = cameraParameters('IntrinsicMatrix', intrinsicMatrix, ...
                                        'RadialDistortion', radialDistortion, ...
                                        'TangentialDistortion', tangentialDistortion, ...
                                        'ImageSize', imageSize);
        
        % 왜곡 보정된 이미지 좌표 계산
        undistortedPoints = undistortPoints(circleCenter, cameraParams);
        
        % 카메라 좌표계에서 원의 중심 좌표 계산
        % 원의 실제 지름: 0.57m
        actualDiameter = radious;
        actualRadius = actualDiameter / 2;
        
        % 카메라의 중심으로부터 원의 중심까지의 거리 계산
        z = focalLength(1) * actualRadius / radii(maxIndex);
        x = (undistortedPoints(1) - principalPoint(1)) * z / focalLength(1);
        y = (undistortedPoints(2) - principalPoint(2)) * z / focalLength(2);
        
        fprintf('3D coordinates of the circle center: (%.2f, %.2f, %.2f)\n', x, y, z);

    catch exception
        t = -1;
        x = 0;
        y = 0;
        z = 0;
        fprintf('3D coordinates of the circle center: fail!!!!!');
    end
end

function[rx, ry, rz,rt] = rr(rgp) %rgp==1 -> red// 2 -> green// 3 -> purple
    global cameraObj;
    
    % 카메라 파라미터 설정
    focalLength = [957.1698 963.1543];
    principalPoint = [495.3551 394.4279];
    imageSize = [720 960];
    radialDistortion = [-0.0337 0.1373];
    tangentialDistortion = [0.0058 0.0034];
    
    % IntrinsicMatrix 구성
    intrinsicMatrix = [focalLength(1), 0, principalPoint(1); 
                       0, focalLength(2), principalPoint(2); 
                       0, 0, 1]';
    
    cameraParams = cameraParameters('IntrinsicMatrix', intrinsicMatrix, ...
                                    'RadialDistortion', radialDistortion, ...
                                    'TangentialDistortion', tangentialDistortion, ...
                                    'ImageSize', imageSize);

    % 사진 촬영
    image = snapshot(cameraObj);


    % HSV 색상 공간으로 변환
    hsvImage  = rgb2hsv(image);

    if rgp == 1
        % 붉은색 범위 설정 (Hue 값 대략 0 - 0.05)
        lower_red = [0, 0.15, 0.15];
        upper_red = [0.075, 1, 1];
        
        % 붉은색 마스크 생성
        mask = (hsvImage(:,:,1) >= lower_red(1) & hsvImage(:,:,1) <= upper_red(1)) & ...
               (hsvImage(:,:,2) >= lower_red(2) & hsvImage(:,:,2) <= upper_red(2)) & ...
               (hsvImage(:,:,3) >= lower_red(3) & hsvImage(:,:,3) <= upper_red(3));
    
    elseif rgp == 2
        % 초록색 범위 설정 (Hue 값 대략 0.25 - 0.45)
        lower_green = [0.2, 0.1, 0.3];
        upper_green = [0.5, 1, 1];
        
        % 초록색 마스크 생성
        mask = (hsvImage(:,:,1) >= lower_green(1) & hsvImage(:,:,1) <= upper_green(1)) & ...
               (hsvImage(:,:,2) >= lower_green(2) & hsvImage(:,:,2) <= upper_green(2)) & ...
               (hsvImage(:,:,3) >= lower_green(3) & hsvImage(:,:,3) <= upper_green(3));
    
    elseif rgp == 3
        % 보라색 범위 설정 (Hue 값 대략 0.75 - 0.85)
        lower_purple = [0.6, 0.3, 0.15];
        upper_purple = [0.9, 1, 1];
        
        % 보라색 마스크 생성
        mask = (hsvImage(:,:,1) >= lower_purple(1) & hsvImage(:,:,1) <= upper_purple(1)) & ...
               (hsvImage(:,:,2) >= lower_purple(2) & hsvImage(:,:,2) <= upper_purple(2)) & ...
               (hsvImage(:,:,3) >= lower_purple(3) & hsvImage(:,:,3) <= upper_purple(3));
    end
    
    
    % 결과 표시

    % figure;
    % imshow(redMask);
    % title('Red Square Mask');

    rt = 1;
    try
        % 바이너리 마스크에서 영역 속성을 추출합니다.
        statsRed = regionprops(mask, 'Area', 'Centroid', 'BoundingBox');
        
        % 가장 큰 사각형 찾기
        if ~isempty(statsRed)
            % 모든 사각형의 면적 계산
            areas = [statsRed.Area];
            
            % 가장 큰 면적의 인덱스 찾기
            [~, maxIdx] = max(areas);
            
            % 가장 큰 사각형의 중심 좌표
            redCenter = statsRed(maxIdx).Centroid;
            fprintf('Detected red square center: (%.2f, %.2f)\n', redCenter(1), redCenter(2));
        end
        
        % 왜곡 보정된 이미지 좌표 계산
        if exist('redCenter', 'var')
            undistortedRedCenter = undistortPoints(redCenter, cameraParams);
        
            % 카메라 좌표계에서 정사각형의 중심 좌표 계산
            % 정사각형 한 변의 실제 길이: 0.09m
            actualSideLength = 0.09;
            actualHalfDiagonal = sqrt(2) * actualSideLength / 2;
        
            % 가장 큰 사각형의 BoundingBox를 사용하여 중심 좌표 계산
            rz = focalLength(1) * actualHalfDiagonal / (sqrt(sum((statsRed(maxIdx).BoundingBox(3:4) / 2).^2)));
            rx = (undistortedRedCenter(1) - principalPoint(1)) * rz / focalLength(1);
            ry = (undistortedRedCenter(2) - principalPoint(2)) * rz / focalLength(2);
            fprintf('3D coordinates of the red square center: (%.2f, %.2f, %.2f)\n', rx, ry, rz);
        end

    catch exception
        rt = -1;
        rx = 0;
        ry = 0;
        rz = 0;
    end
end

function[] = md(x,y,z, val) %카메라 좌표계를 드론죄표계로 변경해줌/ 이동을 수월하게
    global droneObj;
    move(droneObj, [z,x,y],'Speed',val);
end

function[result] = try_circle(x, y, z, t,step)
    if t == -1
        result = 'fail';
        fprintf('can not found circle \n');
    end
    switch step
        case 1
            if (2 < z)
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
        case 2
            if 6.7<z
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
        case 3
            if 4<z
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
        case 4
            if 4<z
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
    end


end

function[result] = try_rac(x, y, z, t,step)
    if t == -1
        result = 'fail';
        fprintf('can not found rac \n');
    end
    switch step
        case 1
            if (3 < z)
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
        case 2
            if 5<z
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
        case 3
            if 4<z
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
        case 4
            if 3<z
                result = 'back';
                fprintf('원래 자리로 돌아가는 것을 추천!!');
            end
    end
end

md(0.0, -0.3, -0.3, 0.5);

%첫 인식
[x, y, z, t] = circle(0.57, 50, 2000);

while t == -1
    [x, y, z, t] = circle(0.57, 50, 2000);
    pause(0.5);
end


[x, y, z, t] = circle(0.57, 50, 2000);
z = z + 0.5;
y = y + 0.4;
md(x,y,z,1);

[rx,ry,rz,rt] = rr(1);
ry = ry + 0.4;
rz = rz-0.8;
md(rx,ry,rz,1)

%------------------
turn(droneObj, deg2rad(135));

[x y z t] = circle(0.46, 20,1600);

y = y+0.4;
z = z-1.5;
md(x,y,z,1);

[rx,ry,rz, rt] = rr(2);
if rz >= 1.5
    ry = ry +0.4;
    rz = rz - 0.8;
    md(rx,ry,rz,0.7);
end

%---------------------------------------
turn(droneObj, deg2rad(-135));

[x y z t] = circle(0.46, 20,1600);
y = y +0.4;
z = z -1.5;
md(x,y,z,0.7);

[rx,ry,rz, rt] = rr(3);

if rz >= 1.5
    ry = ry + 0.4;
    rz = 0.3;
    md(rx,ry,rz,0.2);
end

%------------------------------------------
turn(droneObj, deg2rad(210));

[x y z t] = circle(0.52, 20,1700);
y = y +0.4;
md(x,y,z,0.5);

%---------------------------------------
[rx,ry,rz, rt] = rr(1);
ry = ry + 0.4;
rz = rz - 0.75;

if abs(rz) < 0.2
    land(droneObj);
else
    md(rx,ry,rz,0.2);
    
    land(droneObj);
end