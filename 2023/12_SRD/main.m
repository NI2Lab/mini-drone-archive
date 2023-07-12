clear all;

area_meas = 0;
standard_circle = [480, 220];
max_curvature = 0;
max_curvature_index = 0;

centroid = zeros(size(standard_circle));

drone=ryze();
cam=camera(drone);
takeoff(drone);

move(drone, [-0.4 0 -0.5]);

while 1
    max_curvature = 0;
    max_curvature_index = 0;
    frame=snapshot(cam);    % snapshot 함수를 통해 카메라 객체 cam의 사진을 frame에 저장
    frame2img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [R, C, X]=size(frame2img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img=zeros(size(frame2img));   % img2 변수를 사용하기 위해 사전할당을 통해 처리
    
    % 행, 열에 값을 대입해주는 것이기에 이중 for문을 통해 조건에 따라 다른 값들을 img2에 대입
    for i =1:R
        for j=1:C
            if frame2img(i,j,1) - frame2img(i,j,2) > -5 || frame2img(i,j,1) - frame2img(i,j,3) > -5|| frame2img(i,j,2) - frame2img(i,j,3) > -40 % 파란색 링 색깔을 인식하기 위한 조건
                % 해당 조건에 해당하는 경우, img2의 R, G, B 모든 요소의 값에 최대치인 255를 대입
                img(i,j,1) = 255;  
                img(i,j,2) = 255;
                img(i,j,3) = 255;
    
            else
                % 그 외의 경우, img2의 R, G, B 모든 요소의 값에 0을 대입
                img(i,j,:) = 0;
                img(i,j,2) = 0;
                img(i,j,3) = 0;
            end   
    
        end
    end
    
    % 파란색 크로마키 내의 구멍의 원을 그리는 작업
    normailize_img = img/255; 
    
    img2gray = rgb2gray(normailize_img);
    
    se = strel("rectangle",[10 10]);
    se2 = strel("rectangle",[20 20]);
    i = imerode(img2gray, se); % erode
    i2 = imopen(i,se2); % open
    
    gray2bi = imbinarize(i2);
    gray2bi = bwareaopen(gray2bi, 8000);
    
    gray2bi = bwareafilt(gray2bi, 3);
    % gray2bi = imcomplement(gray2bi);     


    %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
    [B,L,n,A] = bwboundaries(gray2bi);
    %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
    
    % 그려진 각 영역의 Area(면적)과 Centroid(중점), Circularity(곡률) 정보를 저장하는 stats 선언
    stats = regionprops(L,'Area','Centroid','Circularity');
    
    % 원이라고 판단하는 기준 수치 threshold 값을 0.8로 설정, 원 결정 기준 설정
    threshold = 0.7;
    circle_count = 0;
    
    figure(2),imshow(gray2bi);
    axis on; hold on;
    
    % loop over the boundaries
    for k = 1:length(B), boundary = B{k};

        % obtain the area calculation corresponding to label 'k'
        area = stats(k).Area;
        metric = stats(k).Circularity;
        centroid = stats(k).Centroid;

        % display the results
        metric_string = sprintf('%2.2f',metric);
        area_string = sprintf('%d',area);    
        centroid_string = sprintf('%d',centroid);
        
        if metric > max_curvature
            if centroid(1) > 960 || centroid(1) < 0 || centroid(2) > 720 || centroid(2) < 0
                continue;
            else
                max_curvature = metric;
                max_curvature_index = k;
            end
        end
    
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold

            if centroid(1) > 960 || centroid(1) < 0 || centroid(2) > 720 || centroid(2) < 0
                continue;
            else
                area_meas=stats(k).Area;        % 해당 영역의 면적을 area_meas에 저장
                centroid = stats(k).Centroid;   % 해당 영역의 중점을 centroid에 저장
                circle_count=circle_count+1;
            end
        end
        text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',8,'FontWeight','bold')
        text(boundary(1,2)-15,boundary(1,1)+33,area_string,'Color','r','FontSize',8,'FontWeight','bold')
        text(centroid(1),centroid(2),centroid_string,'Color','g','FontSize',8,'FontWeight','bold')
    end
    
    if circle_count == 1
        fprintf("circle\n");
        area_meas       %%% 원 넓이값 출력 %%%
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표

        plot(centroid(1),centroid(2),'g+','LineWidth',7);
        Dis = centroid - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        boundary = B{max_curvature_index};
        plot(boundary(:,2), boundary(:,1), 'g','LineWidth',5);

        if(abs(Dis(1))<60 && abs(Dis(2))<80)   % 1 라운드는 값을 알기에 절대적 크기 설정

            moveforward(drone,'Distance',2.2,'Speed',0.8);
            break;

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1);
        end

    else        
        len = length(B{max_curvature_index});
        total_sum = (sum(B{max_curvature_index}))/len;

        fprintf("not circle\n");

        area_meas = stats(max_curvature_index).Area   %%% 가장 큰 곡률 영역값 출력 %%%

        total_sum_x = total_sum(1,2);
        total_sum_y = total_sum(1,1);

        total_sum = [total_sum_x, total_sum_y]      %%% 가장 큰 곡률 영역 중점값 출력 %%%

        plot(total_sum(:,1),total_sum(:,2),'b+',"LineWidth",7);

        boundary = B{max_curvature_index};

        plot(boundary(:,2), boundary(:,1), 'b','LineWidth',5);
        
        offset = 140;

        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표

        Dis = centroid - drone_pos ;
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        if(abs(Dis(1))<60 && abs(Dis(2))<80)
            
            disp("center_found");
            moveforward(drone,'Distance',2.2,'Speed',0.8);
            break;

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1);
        end
    end
   
end

%%%%%%%%%%%%%%% case 1 turn right %%%%%%%%%%%%%%

while 1  
   
    frame1 = snapshot(cam); % 사진 찍기
    imwrite(frame1,'case1.png');
    
    a = imread('case1.png');
    
    hsv = imbinarize(a);
    
    % x, y좌표 값 바꿔서 넣어줘야 함

    for i=1:size(hsv,1)
        for j = 1:size(hsv,2)
            if hsv(i,j,1) == 1 && hsv(i,j,2) == 0 && hsv(i,j,3) == 0 % RED일때 = [1, 0, 0]
                temp = i;
                temp2 = j; % 각 단계마다 if문 조건식 수정하면 됨
            else
                hsv(i,j,1) = 0; % 초록색이 아닌 경우 hsv의 값을 0으로 변경
                hsv(i,j,2) = 0;
                hsv(i,j,3) = 0;
            end
    
        end
    end
    
    if hsv(temp,temp2,1) == 1 && hsv(temp,temp2,2) == 0 && hsv(temp,temp2,3) == 0  % 빨간색일때
        turn(drone,deg2rad(90));% 시계방향으로 90도 회전
        break; % while 탈출
    end
end

%%%%%%%%%%%%%%% case1 turn right end %%%%%%%%%%%%%

%%%%%%%%%%%%%%% case 2 start %%%%%%%%%%%%%%%%%%%%%%
move(drone, [-0.4 0 -0.3]);
pause(1.5);

while 1
    max_curvature = 0;
    max_curvature_index = 0;
    frame=snapshot(cam);          % snapshot 함수를 통해 카메라 객체 cam의 사진을 frame에 저장
    frame2img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [R, C, X]=size(frame2img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img=zeros(size(frame2img));   % img2 변수를 사용하기 위해 사전할당을 통해 처리
    
    % 행, 열에 값을 대입해주는 것이기에 이중 for문을 통해 조건에 따라 다른 값들을 img2에 대입
    for i =1:R
        for j=1:C
            if frame2img(i,j,1) - frame2img(i,j,2) > -5 || frame2img(i,j,1) - frame2img(i,j,3) > -5|| frame2img(i,j,2) - frame2img(i,j,3) > -40 % 파란색 링 색깔을 인식하기 위한 조건
                % 해당 조건에 해당하는 경우, img2의 R, G, B 모든 요소의 값에 최대치인 255를 대입
                img(i,j,1) = 255;  
                img(i,j,2) = 255;
                img(i,j,3) = 255;
    
            else
                % 그 외의 경우, img2의 R, G, B 모든 요소의 값에 0을 대입
                img(i,j,:) = 0;
                img(i,j,2) = 0;
                img(i,j,3) = 0;
            end
    
        end
    end
    
    % 파란색 크로마키 내의 구멍의 원을 그리는 작업
    normailize_img = img/255;
    
    img2gray = rgb2gray(normailize_img);
    
    se = strel("rectangle",[10 10]);
    se2 = strel("rectangle",[20 20]);
    i = imerode(img2gray, se); % erode
    i2 = imopen(i,se2); % open

    gray2bi = imbinarize(i2);
    gray2bi = bwareaopen(gray2bi, 8000);
    
    gray2bi = bwareafilt(gray2bi, 3);
    % gray2bi = imcomplement(gray2bi);
    
    try 
        %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
        [B,L,n,A] = bwboundaries(gray2bi);
        %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
        
        stats = regionprops(L,'Area','Centroid','Circularity');
    
        threshold = 0.7;
        circle_count = 0;
        
        figure(2),imshow(gray2bi);
        axis on; hold on;
        
        % loop over the boundaries
        for k = 1:length(B), boundary = B{k};
    
            % obtain the area calculation corresponding to label 'k'
            area = stats(k).Area;
            metric = stats(k).Circularity;
            centroid = stats(k).Centroid;
    
            % display the results
            metric_string = sprintf('%2.2f',metric);
            area_string = sprintf('%d',area);    
            centroid_string = sprintf('%d',centroid);
            
            if metric > max_curvature
                if centroid(1) > 960 || centroid(1) < 0 || centroid(2) > 720 || centroid(2) < 0
                    continue;
                else
                    max_curvature = metric;
                    max_curvature_index = k;
                end
            end
        
            % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
            if metric > threshold
    
                if centroid(1) > 960 || centroid(1) < 0 || centroid(2) > 720 || centroid(2) < 0
                    continue;
                else
                    area_meas=stats(k).Area;        % 해당 영역의 면적을 area_meas에 저장
                    centroid = stats(k).Centroid;   % 해당 영역의 중점을 centroid에 저장
                    circle_count=circle_count+1;
                end
            end
            text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',8,'FontWeight','bold')
            text(boundary(1,2)-15,boundary(1,1)+33,area_string,'Color','r','FontSize',8,'FontWeight','bold')
            text(centroid(1),centroid(2),centroid_string,'Color','g','FontSize',8,'FontWeight','bold')
        end
        
        if circle_count == 1
            fprintf("circle\n");
            area_meas   %%% 값 출력 %%%
            offset = 140;
            drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
            plot(centroid(1),centroid(2),'g+','LineWidth',7);
            Dis = centroid - drone_pos ; 
            norm_x = Dis(1)/norm(Dis(1));
            norm_y = Dis(2)/norm(Dis(2));
            norm_vector = [norm_x norm_y];
    
            boundary = B{max_curvature_index};
            plot(boundary(:,2), boundary(:,1), 'g','LineWidth',5);
    
            if(abs(Dis(1))<60 && abs(Dis(2))<80)
                
                % 거리에 따른 원의 넓이를 실험적으로 측정했고, 그에 따른 전진 거리를 설정(-0.4m)
                if 50000<=area_meas && area_meas<60000
                    disp("3.2m moveforward");
                    moveforward(drone,'Distance',3.2,'Speed',0.8);
                              
                elseif 60000<=area_meas && area_meas<74000
                    disp("3.0m moveforward");
                    moveforward(drone,'Distance',3.0,'Speed',0.8);
                    
                elseif 74000<=area_meas && area_meas<85000
                    disp("2.8m moveforward");
                    moveforward(drone,'Distance',2.8,'Speed',0.8);
                    
                elseif 85000<=area_meas && area_meas<105000
                    disp("2.6m moveforward");
                    moveforward(drone,'Distance',2.6,'Speed',0.8);
                    
                elseif 105000<=area_meas && area_meas<130000
                    disp("2.4m moveforward");
                    moveforward(drone,'Distance',2.4,'Speed',0.8);
                    
                elseif 130000<=area_meas && area_meas<165000
                    disp("2.2m moveforward");
                    moveforward(drone,'Distance',2.2,'Speed',0.8);
                    
                elseif 160000<=area_meas && area_meas<220000
                    disp("2.0m moveforward");
                    moveforward(drone,'Distance',2.0,'Speed',0.8);
                    
                elseif 220000<=area_meas && area_meas<360000
                    disp("1.8m moveforward");
                    moveforward(drone,'Distance',1.8,'Speed',0.8);
                    
                elseif 360000<=area_meas && area_meas<460000
                    disp("1.6m moveforward");
                    moveforward(drone,'Distance',1.6,'Speed',0.8);          
        
                elseif 460000<=area_meas && area_meas<600000
                    disp("1.4m moveforward");
                    moveforward(drone,'Distance',1.4,'Speed',0.8);
        
                elseif 600000<=area_meas
                    disp("1.2m moveforward");
                    moveforward(drone,'Distance',1.2,'Speed',0.8);            
        
                else
                    disp("3.4m moveforward");
                    moveforward(drone,'Distance',3.4,'Speed',0.8);            
                end
                break;
    
            else
                move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
                pause(1);
            end
    
        else        
            
            len = length(B{max_curvature_index});
            total_sum = (sum(B{max_curvature_index}))/len;
    
            fprintf("not circle\n");
            
            area_meas=stats(max_curvature_index).Area   %%% 값 출력 %%%
    
            total_sum_x = total_sum(1,2);
            total_sum_y = total_sum(1,1);
    
            total_sum = [total_sum_x, total_sum_y]      %%% 값 출력 %%%
    
            plot(total_sum(:,1),total_sum(:,2),'b+',"LineWidth",7);
    
            boundary = B{max_curvature_index};
            plot(boundary(:,2), boundary(:,1), 'b','LineWidth',5);
            
            offset = 140;
            drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
    
            Dis = centroid - drone_pos ;
            norm_x = Dis(1)/norm(Dis(1));
            norm_y = Dis(2)/norm(Dis(2));
            norm_vector = [norm_x norm_y];
    
            if(abs(Dis(1))<60 && abs(Dis(2))<80)
                
                disp("center_found");

                % 거리에 따른 원의 넓이가 다름 -> 그에 따른 전진 거리를 설정
                if 50000 <= area_meas && area_meas < 60000
                    disp("3.2m moveforward");
                    moveforward(drone,'Distance',3.2,'Speed',0.8);
                    break;

                elseif 60000 <= area_meas && area_meas < 74000
                    disp("3.0m moveforward");
                    moveforward(drone,'Distance',3.0,'Speed',0.8);
                    break;

                elseif 74000 <= area_meas && area_meas < 85000
                    disp("2.8m moveforward");
                    moveforward(drone,'Distance',2.8,'Speed',0.8);
                    break;

                elseif 85000 <= area_meas && area_meas < 105000
                    disp("2.6m moveforward");
                    moveforward(drone,'Distance',2.6,'Speed',0.8);
                    break;

                elseif 105000 <= area_meas && area_meas < 130000
                    disp("2.4m moveforward");
                    moveforward(drone,'Distance',2.4,'Speed',0.8);
                    break;

                elseif 130000 <= area_meas && area_meas < 165000
                    disp("2.2m moveforward");
                    moveforward(drone,'Distance',2.2,'Speed',0.8);
                    break;

                elseif 160000 <= area_meas && area_meas < 220000
                    disp("2.0m moveforward");
                    moveforward(drone,'Distance',2.0,'Speed',0.8);
                    break;

                elseif 220000<=area_meas && area_meas<360000
                    disp("1.8m moveforward");
                    moveforward(drone,'Distance',1.8,'Speed',0.8);
                    break;
                    
                elseif 360000 <= area_meas && area_meas < 460000
                    disp("1.6m moveforward");
                    moveforward(drone,'Distance',1.6,'Speed',0.8);          
                    break;

                elseif 460000 <= area_meas && area_meas < 600000
                    disp("1.4m moveforward");
                    moveforward(drone,'Distance',1.4,'Speed',0.8);
                    break;
        
                elseif 600000<=area_meas
                    disp("1.2m moveforward");
                    moveforward(drone,'Distance',1.2,'Speed',0.8);    
                    break;
        
                else
                    % % % % ERROR 여부 확인 % % % %
                    fprintf("another case");
                    pause(1.5);
                    continue;
                end
    
            else
                move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
                pause(1);
            end
        end

    catch
        fprintf("error\n");
        pause(1);
        continue;
    end

end

% 값 찾기
moveforward(drone,'Distance',0.7,'Speed',0.8);

%%%%%%%%%%%%%%% case2 turn right %%%%%%%%%%%%%%
while 1  
   
    frame1 = snapshot(cam); % 사진찍기
    imwrite(frame1,'case1.png');
    
    a = imread('case1.png');
    
    hsv = imbinarize(a);
    
    % x, y좌표 값 바꿔서 넣어줘야 함


    for i=1:size(hsv,1)
        for j = 1:size(hsv,2)
            if hsv(i,j,1)==1&&hsv(i,j,2)==0&&hsv(i,j,3)==0 % RED일때 = [1, 0, 0]
                temp = i;
                temp2 = j; % 각 단계마다 if문 조건식 수정하면 됨
            else
                hsv(i,j,1)=0; % 초록색이 아닌 경우 hsv의 값을 0으로 변경
                hsv(i,j,2)=0;
                hsv(i,j,3)=0;
            end
    
        end
    end
    
    if hsv(temp,temp2,1)==1&&hsv(temp,temp2,2)==0&&hsv(temp,temp2,3)==0  % 빨간색일때
        turn(drone,deg2rad(90));% 시계방향으로 90도 회전
        break; % while탈출
    end
end

%%%%%%%%%%%%%%% case2 turn right end %%%%%%%%%%%%%%

move(drone, [-0.4 0 -0.6]);

while 1
    max_curvature = 0;
    max_curvature_index = 0;
    frame=snapshot(cam);          % snapshot 함수를 통해 카메라 객체 cam의 사진을 frame에 저장
    frame2img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [R, C, X]=size(frame2img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img=zeros(size(frame2img));   % img2 변수를 사용하기 위해 사전할당을 통해 처리
    
    % 행, 열에 값을 대입해주는 것이기에 이중 for문을 통해 조건에 따라 다른 값들을 img2에 대입
    for i =1:R
        for j=1:C
            if frame2img(i,j,1) - frame2img(i,j,2) > -5 || frame2img(i,j,1) - frame2img(i,j,3) > -5|| frame2img(i,j,2) - frame2img(i,j,3) > -40 % 파란색 링 색깔을 인식하기 위한 조건
                % 해당 조건에 해당하는 경우, img2의 R, G, B 모든 요소의 값에 최대치인 255를 대입
                img(i,j,1) = 255;  
                img(i,j,2) = 255;
                img(i,j,3) = 255;
    
            else
                % 그 외의 경우, img2의 R, G, B 모든 요소의 값에 0을 대입
                img(i,j,:) = 0;
                img(i,j,2) = 0;
                img(i,j,3) = 0;
            end
    
        end
    end
    
    % 파란색 크로마키 내의 구멍의 원을 그리는 작업
    normailize_img = img/255; 
    
    img2gray = rgb2gray(normailize_img);
    
    se = strel("rectangle",[10 10]);
    se2 = strel("rectangle",[20 20]);
    i = imerode(img2gray, se); % erode
    i2 = imopen(i,se2); % open

    gray2bi = imbinarize(i2);
    gray2bi = bwareaopen(gray2bi, 8000);
    
    gray2bi = bwareafilt(gray2bi, 3);
    % gray2bi = imcomplement(gray2bi);

    try 
        %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
        [B,L,n,A] = bwboundaries(gray2bi);
        %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
        
        stats = regionprops(L,'Area','Centroid','Circularity');
    
        threshold = 0.7;
        circle_count = 0;
        
        figure(2),imshow(gray2bi);
        axis on; hold on;
        
            % loop over the boundaries
        for k = 1:length(B), boundary = B{k};
    
            % obtain the area calculation corresponding to label 'k'
            area = stats(k).Area;
            metric = stats(k).Circularity;
            centroid = stats(k).Centroid;
    
            % display the results
            metric_string = sprintf('%2.2f',metric);
            area_string = sprintf('%d',area);    
            centroid_string = sprintf('%d',centroid);
            
            if metric > max_curvature
                if centroid(1) > 960 || centroid(1) < 0 || centroid(2) > 720 || centroid(2) < 0
                    continue;
                else
                    max_curvature = metric;
                    max_curvature_index = k;
                end
            end
        
            % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
            if metric > threshold
    
                if centroid(1) > 960 || centroid(1) < 0 || centroid(2) > 720 || centroid(2) < 0
                    continue;
                else
                    area_meas=stats(k).Area;        % 해당 영역의 면적을 area_meas에 저장
                    centroid = stats(k).Centroid;   % 해당 영역의 중점을 centroid에 저장
                    circle_count=circle_count+1;
                end
            end
            text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',8,'FontWeight','bold')
            text(boundary(1,2)-15,boundary(1,1)+33,area_string,'Color','r','FontSize',8,'FontWeight','bold')
            text(centroid(1),centroid(2),centroid_string,'Color','g','FontSize',8,'FontWeight','bold')
        end
        
        if circle_count == 1
            fprintf("circle\n");
            area_meas   %%% 값 출력 %%%
            offset = 140;
            drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
            plot(centroid(1),centroid(2),'g+','LineWidth',7);
            Dis = centroid - drone_pos ; 
            norm_x = Dis(1)/norm(Dis(1));
            norm_y = Dis(2)/norm(Dis(2));
            norm_vector = [norm_x norm_y];
    
            boundary = B{max_curvature_index};
            plot(boundary(:,2), boundary(:,1), 'g','LineWidth',5);
    
            if(abs(Dis(1))<60 && abs(Dis(2))<80)
                
                % 거리에 따른 원의 넓이를 실험적으로 측정했고, 그에 따른 전진 거리를 설정
                if 50000<=area_meas && area_meas<60000
                    disp("3.2m moveforward");
                    moveforward(drone,'Distance',3.2,'Speed',0.8);
                              
                elseif 60000<=area_meas && area_meas<74000
                    disp("3.0m moveforward");
                    moveforward(drone,'Distance',3.0,'Speed',0.8);
                    
                elseif 74000<=area_meas && area_meas<85000
                    disp("2.8m moveforward");
                    moveforward(drone,'Distance',2.8,'Speed',0.8);
                    
                elseif 85000<=area_meas && area_meas<105000
                    disp("2.6m moveforward");
                    moveforward(drone,'Distance',2.6,'Speed',0.8);
                    
                elseif 105000<=area_meas && area_meas<130000
                    disp("2.4m moveforward");
                    moveforward(drone,'Distance',2.4,'Speed',0.8);
                    
                elseif 130000<=area_meas && area_meas<165000
                    disp("2.2m moveforward");
                    moveforward(drone,'Distance',2.2,'Speed',0.8);
                    
                elseif 160000<=area_meas && area_meas<220000
                    disp("2.0m moveforward");
                    moveforward(drone,'Distance',2,'Speed',0.8);
                    
                elseif 220000<=area_meas && area_meas<360000
                    disp("1.8m moveforward");
                    moveforward(drone,'Distance',1.8,'Speed',0.8);
                    
                elseif 360000<=area_meas && area_meas<460000
                    disp("1.6m moveforward");
                    moveforward(drone,'Distance',1.6,'Speed',0.8);          
        
                elseif 460000<=area_meas && area_meas<600000
                    disp("1.4m moveforward");
                    moveforward(drone,'Distance',1.4,'Speed',0.8);
        
                elseif 600000<=area_meas
                    disp("1.2m moveforward");
                    moveforward(drone,'Distance',1.2,'Speed',0.8);            
        
                else
                    disp("3.4m moveforward");
                    moveforward(drone,'Distance',3.4,'Speed',0.8);            
                end
                break;
    
            else
                move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
                pause(1);
            end
    
        else        
            
            len = length(B{max_curvature_index});
            total_sum = (sum(B{max_curvature_index}))/len;
    
            fprintf("not circle\n");
            
            area_meas=stats(max_curvature_index).Area   %%% 값 출력 %%%
    
            total_sum_x = total_sum(1,2);
            total_sum_y = total_sum(1,1);
    
            total_sum = [total_sum_x, total_sum_y]      %%% 값 출력 %%%
    
            plot(total_sum(:,1),total_sum(:,2),'b+',"LineWidth",7);
    
            boundary = B{max_curvature_index};
            plot(boundary(:,2), boundary(:,1), 'b','LineWidth',5);
            
            offset = 140;
            drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
    
            Dis = centroid - drone_pos ;
            norm_x = Dis(1)/norm(Dis(1));
            norm_y = Dis(2)/norm(Dis(2));
            norm_vector = [norm_x norm_y];
    
            if(abs(Dis(1))<60 && abs(Dis(2))<80)
                
                disp("center_found");

                % 거리에 따른 원의 넓이가 다름 -> 그에 따른 전진 거리를 설정
                if 50000 <= area_meas && area_meas < 60000
                    disp("3.2m moveforward");
                    moveforward(drone,'Distance',3.2,'Speed',0.8);
                    break;

                elseif 60000 <= area_meas && area_meas < 74000
                    disp("3.0m moveforward");
                    moveforward(drone,'Distance',3.0,'Speed',0.8);
                    break;

                elseif 74000 <= area_meas && area_meas < 85000
                    disp("2.8m moveforward");
                    moveforward(drone,'Distance',2.8,'Speed',0.8);
                    break;

                elseif 85000 <= area_meas && area_meas < 105000
                    disp("2.6m moveforward");
                    moveforward(drone,'Distance',2.6,'Speed',0.8);
                    break;

                elseif 105000 <= area_meas && area_meas < 130000
                    disp("2.4m moveforward");
                    moveforward(drone,'Distance',2.4,'Speed',0.8);
                    break;

                elseif 130000 <= area_meas && area_meas < 165000
                    disp("2.2m moveforward");
                    moveforward(drone,'Distance',2.2,'Speed',0.8);
                    break;

                elseif 160000 <= area_meas && area_meas < 220000
                    disp("2.0m moveforward");
                    moveforward(drone,'Distance',2,'Speed',0.8);
                    break;

                elseif 220000<=area_meas && area_meas<360000
                    disp("1.8m moveforward");
                    moveforward(drone,'Distance',1.8,'Speed',0.8);
                    break;
                    
                elseif 360000 <= area_meas && area_meas < 460000
                    disp("1.6m moveforward");
                    moveforward(drone,'Distance',1.6,'Speed',0.8);          
                    break;

                elseif 460000 <= area_meas && area_meas < 600000
                    disp("1.4m moveforward");
                    moveforward(drone,'Distance',1.4,'Speed',0.8);
                    break;
        
                elseif 600000<=area_meas
                    disp("1.2m moveforward");
                    moveforward(drone,'Distance',1.2,'Speed',0.8);    
                    break;
        
                else
                    % % % % ERROR 여부 확인 % % % %
                    fprintf("another case");
                    pause(1.5);
                    continue;
                end
    
            else
                move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
                pause(1);
            end
        end

    catch
        fprintf("error\n");
        pause(1);
        continue;
    end

end

%%%%%%%%%%%%%%%%%%%%%% case 3 turn around %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while 1  
   
    frame3 = snapshot(cam); % 사진찍기
    imwrite(frame3,'case3.png');

    a = imread('case3.png');

    hsv = imbinarize(a);
    
    % x, y좌표 값 바꿔서 넣어줘야 함

    for i=1:size(hsv,1)
        for j = 1:size(hsv,2)
            if hsv(i,j,1)==0&&hsv(i,j,2)==1&&hsv(i,j,3)==0 % GREEN일때 = [0, 1, 0]
                temp = i;
                temp2 = j; % 각 단계마다 if문 조건식 수정하면 됨
            else
                hsv(i,j,1)=0; % 초록색이 아닌 경우 hsv의 값을 0으로 변경
                hsv(i,j,2)=0;
                hsv(i,j,3)=0;
            end
    
        end
    end
    
    now_degree = 30;
    count = 0;
    first = 0;
    turn_ori = 0;
    if hsv(temp,temp2,1)==0&&hsv(temp,temp2,2)==1&&hsv(temp,temp2,3)==0  % 초록색일때
        turn(drone,deg2rad(30));% 시계방향으로 30도 회전
        fprintf("turn around 30 degree\n");
        break; % while탈출
    else
        turn(drone,deg2rad(30));% 시계방향으로 30도 회전
        fprintf("turn around 30 degree.\n");
        break; % while탈출
    end
end

%%%%%%%%%%%%%%%%%%%%%% case 3 turn around end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

moveup(drone, 0.7)

while 1
    pause(1.5)
    frame = snapshot(cam); % 사진찍기
    img_hsv = rgb2hsv(frame);
    
    img_hsv_h = img_hsv(:,:,1);
    img_hsv_h = imgaussfilt(img_hsv_h,5);
    
    
    img_hsv_s = img_hsv(:,:,2);
    img_hsv_v = img_hsv(:,:,3);
    img_hsv_cir = double(zeros(size(img_hsv_h)));

    for i = 1: size(img_hsv_cir, 1)
    
        for j = 1:size(img_hsv_cir, 2)
    
            if (img_hsv_h(i, j) > 0.5 && img_hsv_h(i, j) < 0.7) && (img_hsv_v(i, j) < 0.97) && (img_hsv_s(i,j) > 0.51)
                img_hsv_cir(i, j) = 1;
            else
                img_hsv_cir(i, j) = 0;
            end
        end
    end
    
    
    BW=bwareaopen(img_hsv_cir, 1000); % 픽셀크기 1000 이하 제거
    se = strel("disk", 3);
    se2 = strel("disk",6);
    i = imerode(BW, se); % 침식
    i2 = imdilate(i,se2); % 팽창
    i3=bwperim(i2, 8);
    se3 = strel("disk",2);
    i4 = imdilate(i3,se3); % open
    BW2 = bwareafilt(i4,1,'smallest');
    area_blue = bwarea(BW2)
    
    if area_blue < 200
        pause(2)
        moveup(drone, 0.5)
        continue;
    end

    try
        [B,L,n,A] = bwboundaries(BW2);
        total_sum=zeros(size(B{1}));
        
        for k=1:length(B), boundary=B{k};
            if(k<=n)
                plot(boundary(:,2), boundary(:,1), 'g','LineWidth',1);
                len=length(B{k});
                boundary_sum=(sum(B{k}))/len;   
                total_sum=total_sum+boundary_sum;
            else
                plot(boundary(:,2), boundary(:,1), 'r','LineWidth',1);
            end
        end
    
    
        total_sum=total_sum/n;
    catch
        fprintf("error\n")
        total_sum = [0 0];
        moveback(drone,'Distance',0.5,'speed',0.5);
        pause(0.5)
        moveup(drone,'Distance',0.3,'Speed',0.5)
        pause(0.5)
        turn(drone,deg2rad(-turn_ori));

        continue;
    end

    offset = 140;
    drone_pos=[size(BW2,2)./2, size(BW2,1)./2-offset];
    d_y=drone_pos(1,1); % 드론의 중점의 y축 저장
    d_z=drone_pos(1,2); % 드론의 중점의 z축 저장
    o_y = total_sum(1,2); % 객체의 y축
    o_z = total_sum(1,1); % 객체의 z축

    dis_y=norm(d_y-o_y); % 드론의 중점과 객체의 중점사이의 거리 측정
    dis_z=norm(d_z-o_z); % 드론의 중점과 객체의 중점사이의 거리 측정
    
    n_y = (o_y-d_y)/dis_y; % 단위벡터 계산
    n_z = (o_z-d_z)/dis_z; % 단위벡터 계산
    
    imshow(BW2), hold on;
    hold on
    plot(o_y,o_z,'b*')
    plot(d_y,d_z,'r+') % 드론의 위치를 plot해주는 함수
    hold off
    
    if dis_z <80 % 높이를 맞춘 상태
       
        if dis_y > 60 && first ==0 % 좌우 못맞춘 상태
            
            while dis_y > 60
                distance_y = dis_y % 각도 찾는 단계
            % 이미지 처리 진행
                frame = snapshot(cam); % 사진찍기
                img_hsv = rgb2hsv(frame);
                
                img_hsv_h = img_hsv(:,:,1);
                img_hsv_h = imgaussfilt(img_hsv_h,5);
                
                
                img_hsv_s = img_hsv(:,:,2);
                img_hsv_v = img_hsv(:,:,3);
                img_hsv_cir = double(zeros(size(img_hsv_h)));
            
                for i = 1: size(img_hsv_cir, 1)
                
                    for j = 1:size(img_hsv_cir, 2)
                
                        if (img_hsv_h(i, j) > 0.5 && img_hsv_h(i, j) < 0.7) && (img_hsv_v(i, j) < 0.97) && (img_hsv_s(i,j) > 0.51)
                            img_hsv_cir(i, j) = 1;
                        else
                            img_hsv_cir(i, j) = 0;
                        end
                    end
                end
                
                
                BW=bwareaopen(img_hsv_cir, 1000); % 픽셀크기 1000 이하 제거
                se = strel("disk", 3);
                se2 = strel("disk",6);
                i = imerode(BW, se); % 침식
                i2 = imdilate(i,se2); % 팽창
                i3=bwperim(i2, 8);
                se3 = strel("disk",2);
                i4 = imdilate(i3,se3); % open
                BW2 = bwareafilt(i4,1,'smallest');
                area_blue2 = bwarea(BW2)
                if area_blue2 < 200
                    pause(2)
                    moveup(drone, 0.5)
                    continue;
                end

                try
                    [B,L,n,A] = bwboundaries(BW2);
                    total_sum=zeros(size(B{1}));
                    
                    for k=1:length(B), boundary=B{k};
                        if(k<=n)
                            plot(boundary(:,2), boundary(:,1), 'g','LineWidth',1);
                            len=length(B{k});
                            boundary_sum=(sum(B{k}))/len;   
                            total_sum=total_sum+boundary_sum;
                        else
                            plot(boundary(:,2), boundary(:,1), 'r','LineWidth',1);
                        end
                    end
                
                
                    total_sum=total_sum/n;
                catch
                    fprintf("error\n")
                    total_sum = [0 0];
                    moveback(drone,'Distance',0.5,'speed',0.5);
                    pause(0.5)
                    moveup(drone,'Distance',0.3,'Speed',0.5)
                    continue;
                end
            
                offset = 140;
                drone_pos=[size(BW2,2)./2, size(BW2,1)./2-offset];
                d_y=drone_pos(1,1); % 드론의 중점의 y축 저장
                d_z=drone_pos(1,2); % 드론의 중점의 z축 저장
                o_y = total_sum(1,2); % 객체의 y축
                o_z = total_sum(1,1); % 객체의 z축
            
                dis_y=norm(d_y-o_y); % 드론의 중점과 객체의 중점사이의 거리 측정
                dis_z=norm(d_z-o_z); % 드론의 중점과 객체의 중점사이의 거리 측정
                
                n_y = (o_y-d_y)/dis_y; % 단위벡터 계산
                n_z = (o_z-d_z)/dis_z; % 단위벡터 계산
                
                imshow(BW2), hold on;
                hold on
                plot(o_y,o_z,'b*')
                plot(d_y,d_z,'r+') % 드론의 위치를 plot해주는 함수
                hold off 
                
                if n_y < 0 % 객체의 중점보다 드론이 오른쪽에 있을때
                         turn(drone,deg2rad(-5));% 반시계방향으로 -5도 회전
                         fprintf("turn left\n")
                         now_degree = now_degree - 5
                         count = count +1
                         pause(1)
                         continue;
                else % 객체의 중점보다 드론이 왼쪽에 있을때
                         turn(drone,deg2rad(5));% 시계방향으로 5도 회전
                         fprintf("turn right\n")
                         now_degree = now_degree + 5
                         count =count +1
                         pause(1)
                         continue;
                end
                
            end % while문 end

            find_dis = 1;
            first =1;

        %elseif dis_y > 150 && first ==1 % 각도를 못찾은 상태
         %   move(drone,[0 n_y*0.2 n_z*0],'Speed',0.5);
          %  first =0

        elseif first ==1 % 각도를 찾은 상태
            fprintf("find degree\n")
            if dis_y <45
                distance_y2 = dis_y
                    if area_blue > 5500 && area_blue < 8500


                        
                         fprintf("find purple start\n")
                         if area_blue > 5500 && area_blue < 6000
                             fprintf("move 0.5m")
                             move(drone,[0.4 n_y*0 n_z*0],'Speed',0.5);
                             land(drone);
                             break;
                         elseif area_blue >= 6000 && area_blue < 6500
                             fprintf("move 0.4m")
                             move(drone,[0.3 n_y*0 n_z*0],'Speed',0.5);
                             land(drone);
                             break;
                         else 
                             fprintf("move 0.2m")
                             move(drone,[0.2 n_y*0 n_z*0],'Speed',0.5);
                             land(drone);
                             break;
                         end
                    elseif area_blue > 10000
                         move(drone,[-0.5 0 -0.4],'Speed',0.5);
                    else
                        move(drone,[0.3 n_y*0 n_z*0],'Speed',0.5);
                    end

            else
                move(drone,[0 n_y*0.2 n_z*0],'Speed',0.5);
            end

        else
            move(drone,[0 n_y*0.2 n_z*0],'Speed',0.5);
            first =0;
        end

    else % 높이를 못맞춘 상태
        move(drone,[0 n_y*0 n_z*0.2],'Speed',0.5); 
    end
    
end % while end



