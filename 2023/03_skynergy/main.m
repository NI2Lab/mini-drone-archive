% 필요한 라이브러리 로드
import matlab.io.*
import cv.*
drone = ryze();
takeoff(drone);
cameraObj = camera(drone);
%preview(cameraObj);
angle = [-5,10,-15,20,-10];
moveback(drone,Distance=0.4);
pause(1);
% 1단계
while 1
    moveup(drone,Distance=0.2);
    pause(2);
    [frame,ts] = snapshot(cameraObj);
    pause(1);
    [is_cc,x,y] = serch_circle(frame);
    disp(is_cc);
    if is_cc
        img_size = size(frame);  % 이미지 크기 얻기
        ct = img_size(1:2) / 2;  % 이미지의 중심 좌표 계산
        x_move = ceil(ct(2)-x)/30;
        y_move = ceil(ct(1)-y)/30;
        xm = x_move/100;
        ym = y_move/100;
        if xm > 0.1
            moveright(drone,Distance=xm);
        elseif xm < -0.1
            moveleft(drone,Distance=abs(xm));
        end
        pause(2);
        if  ym > 0.1
            moveup(drone,Distance=ym);
        elseif ym < -0.1
            movedown(drone,Distance=abs(ym));
        end
        pause(2);
        break
    end
end
moveforward(drone,Distance=2.4);
pause(2);

[frame,ts] = snapshot(cameraObj);
if red_detection(frame)
    turn(drone,deg2rad(90));
end
pause(1);
% 2단계
moveback(drone,Distance=0.5);
pause(2);
movedown(drone,Distance=0.5);
pause(2);
while 1
    moveup(drone,Distance=0.2);
    pause(2);
    [frame,ts] = snapshot(cameraObj);
    pause(1);
    [is_cc,x,y] = serch_circle(frame);
    disp(is_cc);
    if is_cc
        img_size = size(frame);  % 이미지 크기 얻기
        ct = img_size(1:2) / 2;  % 이미지의 중심 좌표 계산
        x_move = ceil(ct(2)-x)/30;
        y_move = ceil(ct(1)-y)/30;
        xm = x_move/100;
        ym = y_move/100;
        if xm > 0.1
            moveright(drone,Distance=xm);
        elseif xm < -0.1
            moveleft(drone,Distance=abs(xm));
        end
        pause(2);
        if  ym > 0.1
            moveup(drone,Distance=ym);
        elseif ym < -0.1
            movedown(drone,Distance=abs(ym));
        end
        pause(2);
        break
    end
end
moveforward(drone,Distance=2.5);
pause(2);
[frame,ts] = snapshot(cameraObj);
if red_detection(frame)
    turn(drone,deg2rad(90));
end
pause(1);
% 3단계
moveback(drone,Distance=0.5);
pause(1);
while 1
    moveup(drone,Distance=0.2);
    pause(2);
    [frame,ts] = snapshot(cameraObj);
    pause(1);
    [is_cc,x,y] = serch_circle(frame);
    disp(is_cc);
    if is_cc
        img_size = size(frame);  % 이미지 크기 얻기
        ct = img_size(1:2) / 2;  % 이미지의 중심 좌표 계산
        x_move = ceil(ct(2)-x)/30;
        y_move = ceil(ct(1)-y)/30;
        xm = x_move/100;
        ym = y_move/100;
        if xm > 0.1
            moveright(drone,Distance=xm);
        elseif xm < -0.1
            moveleft(drone,Distance=abs(xm));
        end
        pause(2);
        if  ym > 0.1
            moveup(drone,Distance=ym);
        elseif ym < -0.1
            movedown(drone,Distance=abs(ym));
        end
        pause(2);
        break
    end
end
moveforward(drone,Distance=2.5);
pause(2);
turn(drone,deg2rad(45));
pause(2);
moveforward(drone,Distance=3);
land(drone);

function [is_Circle,x,y] = serch_circle(image)

    is_Circle = 0;
    x = 0;
    y = 0;

    % 이미지를 HSV 색 공간으로 변환
    hsvImage = rgb2hsv(image);
    
    % 하늘색 범위 지정 (HSV)
    lowerblue = [0.5, 0.15, 0.4];
    upperblue = [0.65, 1, 1];
    
    % 하늘색 영역 마스크 생성
    blueMask = (hsvImage(:,:,1) >= lowerblue(1) & hsvImage(:,:,1) <= upperblue(1) ...
        & hsvImage(:,:,2) >= lowerblue(2) & hsvImage(:,:,2) <= upperblue(2) ...
        & hsvImage(:,:,3) >= lowerblue(3) & hsvImage(:,:,3) <= upperblue(3));
    
    % 초록색 영역만 남기고 나머지는 검은색으로 설정
    resultImage = image;
    resultImage(repmat(~blueMask, [1 1 3])) = 0;
    
    % Canny 에지 감지 적용
    grayImage = rgb2gray(resultImage);
    threshold = [0.05 0.15]; % 에지 감지 임계값 설정
    sigma = 10; % 가우시안 필터의 표준 편차 설정
    cannyImage = edge(grayImage, 'Canny', threshold, sigma);
    bw = bwareaopen(cannyImage,9);
    bw = imfill(bw,'holes');
    
    [B,L] = bwboundaries(bw,'noholes');
    % % 두 번째 이미지 보여주기
    % figure;  % 새 창에서 이미지 표시
    % imshow(cannyImage);
    % title('이미지 1'); 

    % figure;  % 새 창에서 이미지 표시
    imshow(label2rgb(L,@jet,[.5 .5 .5]));
    % title('이미지 2'); 
    hold on
    for k = 1:length(B)
      boundary = B{k};
      plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
    end
    stats = regionprops(L,'Area','Centroid','MajorAxisLength','MinorAxisLength');
    
    threshold = 0.88;
    
    % loop over the boundaries
    for k = 1:length(B)
    
      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};
    
      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));
      
      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;
      diameter = stats(k).MajorAxisLength;
      
      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;

      % display the results
      metric_string = sprintf('%2.2f',metric);
    
      % mark objects above the threshold with a black circle
      if metric > threshold && diameter > 100
          is_Circle = 1;
          centroid = stats(k).Centroid;
          x = centroid(1);
          y = centroid(2);
          plot(x,y,'ko');
          disp(diameter);
          plot(centroid(1),centroid(2),'ko');
      end
      text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
       'FontSize',14,'FontWeight','bold')
    end
end

function is_red = red_detection(image)

    is_red = 0;

    image = rgb2hsv(image);
    
    h = image(:,:,1);
    detect_h = ((h >= 0.9) | (h <= 0.05));
    
    s = image(:,:,2);
    detect_s = (s >= 0.2) & (s <= 1);
    
    v = image(:,:,3);
    detect_v = (v >= 0.2) & (v <= 1);
    
    detect_Rdot = detect_h & detect_s & detect_v;
    
    canny_img = edge(detect_Rdot, 'Canny', 0.9, 8);
    
    fill_img = imfill(canny_img, 'holes');
    figure;
    imshow(fill_img);
    
    [B,L] = bwboundaries(fill_img,'noholes');
    % % 두 번째 이미지 보여주기
    % figure;  % 새 창에서 이미지 표시
    % imshow(cannyImage);
    % title('이미지 1'); 

    % figure;  % 새 창에서 이미지 표시
    imshow(label2rgb(L,@jet,[.5 .5 .5]));
    % title('이미지 2'); 
    hold on
    for k = 1:length(B)
      boundary = B{k};
      plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
    end
    
    stats = regionprops(L,'Area','Centroid','MajorAxisLength','MinorAxisLength');
    
    threshold = 0.85;
    
    % loop over the boundaries
    for k = 1:length(B)
    
      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};
    
      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));
      
      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;
      
      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;
      diameter = stats(k).MajorAxisLength;

      % display the results
      metric_string = sprintf('%2.2f',metric);
    
      % mark objects above the threshold with a black circle
      if metric > threshold
          is_red = 1;
          centroid = stats(k).Centroid;
          plot(centroid(1),centroid(2),'ko');
      end
      text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
       'FontSize',14,'FontWeight','bold')
    end
end

function ct_move(dn,xm,ym)
    xm = xm/100;
    ym = ym/100;
    pause(2);
    if xm > 0.1
        moveright(dn,Distance=xm);
    elseif xm < -0.1
        moveleft(dn,Distance=abs(xm));
    end
    pause(2);
    if  ym > 0.1
        moveup(dn,Distance=ym);
    elseif ym < -0.1
        movedown(dn,Distance=abs(ym));
    end
    pause(2);
end
