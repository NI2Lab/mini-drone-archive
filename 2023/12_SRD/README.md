# 2023 미니드론 자율주행 경진대회

# 대회 진행 전략  

  드론으로 찍은 사진을 통해 파란색 객체를 분석하여 가장 큰 객체의 중점을 인식하고 중점으로 이동하는 원리를 사용하였다. 이때 가우스 필터, 이미지 침식, 팽창 등 이미지 처리 기술을 사용하여 노이즈를 최대한 제거하였다.
      
      
      
    
# 알고리즘 설명  

  파란색 천막을 hsv 이미지로 변환한 후 파란색 부분의 중심을 찾는 방식을 사용하였다. 중심을 찾는 과정은 드론의 현재 위치와 객체의 중점을 구한 후 좌표값을 통해 단위 벡터를 계산한 후 드론을 제어하였다. 일정한 거리에 들어오게 되면 원의 크기를 읽은 후 원의 크기에 따라 전진하는 거리를 제어한다. 링을 통과한 후 색을 감지하면 색에 맞는 드론의 움직임을 제어한다. 색을 판단하는 방법은 hsv이미지의 값을 읽으면 된다. 예를들어 빨간색일때는 hsv(i,j,1), hsv(i,j,2), hsv(i,j,3)의 값이 [1 0 0]이다. 이렇게 색을 감지하여 if문을 통해 드론의 움직임을 제어한다. 마지막으로 노란색 원에 착륙하는 방법은 30~60도 사이로 마지막 천막이 위치하므로 우선 30도 드론을 회전한 후 마지막 천막의 중점과 현재 드론의 중점이 일치할때까지 드론을 회전한다. 중점이 일치하게 되면 드론을 전진시키면서 이전과 동일한 방식으로 원의 넓이에 따라 이동하는 거리 계산하여 노란색 원 위에 착륙하도록 하였다.
      
      
# 소스 코드 설명  


```
clear all;

area_meas = 0;
standard_circle = [480, 220];
max_curvature = 0;
max_curvature_index = 0;

centroid = zeros(size(standard_circle));

drone=ryze();
cam=camera(drone);
takeoff(drone);

moveup(drone,'Distance',0.5);
moveback(drone,'Distance',0.4);

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
    gray2bi = imclose(gray2bi,se);
    gray2bi = bwareafilt(gray2bi, 3);
    
    [B,L,n,A] = bwboundaries(gray2bi);
    
    % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    stats = regionprops(L,'Area','Centroid');
    
    % 원이라고 판단하는 기준 수치 threshold 값을 0.7로 설정, 원 결정 기준 설정
    threshold = 0.7;
    circle_count = 0;
    
    gray2bi = imcomplement(gray2bi);    
    gray2bi = bwareaopen(gray2bi,80);
    
    figure(2),imshow(gray2bi);
    axis on; hold on;
    
    % loop over the boundaries
    for k = 1:length(B), boundary = B{k};
        
        % compute a simple estimate of the object's perimeter
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));
    
        % obtain the area calculation corresponding to label 'k'
        area = stats(k).Area;
    
        % compute the roundness metric
        metric = 4*pi*area/perimeter^2;
        
        if metric > max_curvature
            max_curvature = metric;
            max_curvature_index = k;
        end

        % display the results
        metric_string = sprintf('%2.2f',metric);
    
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold
            area_meas=stats(k).Area;        % 해당 영역의 면적을 area_meas에 저장
            centroid = stats(k).Centroid;   % 해당 영역의 중점을 centroid에 저장
            plot(centroid(1),centroid(2),'r+');  % centroid(중점)을 figure 1에 plot 
            circle_count=circle_count+1;
            fprintf("AREA : %d\n", area_meas);
            text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',14,'FontWeight','bold')
        end
    end
    
    if circle_count == 1
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
       
        Dis = centroid - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        
        fprintf("Circle\n");

        if(abs(Dis(1))<60 && abs(Dis(2))<80)   % 1 라운드는 값을 알기에 절대적 크기 설정

            moveforward(drone,'Distance',2.4,'Speed',0.8);
            break;

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1);
        end

    else        
        
        gray2bi = imcomplement(gray2bi);    
        gray2bi = bwareaopen(gray2bi,8000);

        fprintf("not Circle\n");

        len = length(B{max_curvature_index});
        total_sum = (sum(B{max_curvature_index}))/len;
        
        total_sum_x = total_sum(1,2);
        total_sum_y = total_sum(1,1);
        
        total_sum = [total_sum_x, total_sum_y];

        plot(total_sum(:,1),total_sum(:,2),'w-');
        
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표

        %%%%%%%%% 값 확인 %%%%%%%%%%
        Dis = total_sum - drone_pos ;
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        if(abs(Dis(1))<60 && abs(Dis(2))<80)
            
            disp("center_found");
            moveforward(drone,'Distance',2.4,'Speed',0.8);
            break;

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1);
        end
    end
   
end

%%%%%%%%%%%%%%% case1 turn right %%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%% case1 turn right end %%%%%%%%%%%%%%

moveup(drone,'Distance',0.6);
moveback(drone,'Distance',0.4);

while 1
    max_curvature = 0;
    max_curvature_index = 0;
    frame=snapshot(cam);    % snapshot 함수를 통해 카메라 객체 cam의 사진을 frame에 저장
    % frame=imread("10.jpg");
    frame2img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [R, C, X]=size(frame2img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img=zeros(size(frame2img));   % img2 변수를 사용하기 위해 사전할당을 통해 처리
    % img=zeros(size(frame2img));   % img3 변수를 사용하기 위해 사전할당을 통해 처리
    
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
    gray2bi = imclose(gray2bi,se);
    gray2bi = bwareafilt(gray2bi, 3);

    [B,L,n,A] = bwboundaries(gray2bi);
    
    % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    stats = regionprops(L,'Area','Centroid');
    
    % 원이라고 판단하는 기준 수치 threshold 값을 0.7로 설정, 원 결정 기준 설정
    threshold = 0.7;
    circle_count = 0;
    
    gray2bi = imcomplement(gray2bi);    
    gray2bi = bwareaopen(gray2bi,80);
    
    figure(2),imshow(gray2bi);
    axis on; hold on;
    
    % loop over the boundaries
    for k = 1:length(B), boundary = B{k};
        
        % compute a simple estimate of the object's perimeter
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));
    
        % obtain the area calculation corresponding to label 'k'
        area = stats(k).Area;
    
        % compute the roundness metric
        metric = 4*pi*area/perimeter^2;

        if metric > max_curvature
            max_curvature = metric;
            max_curvature_index = k;
        end
    
        % display the results
        metric_string = sprintf('%2.2f',metric);
    
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold
            area_meas=stats(k).Area;        % 해당 영역의 면적을 area_meas에 저장
            centroid = stats(k).Centroid;   % 해당 영역의 중점을 centroid에 저장
            plot(centroid(1),centroid(2),'r+');  % centroid(중점)을 figure 1에 plot 
            circle_count=circle_count+1;
            text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',14,'FontWeight','bold')
        end
    end
    
    if circle_count == 1
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
       
        Dis = centroid - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        
        fprintf("Circle\n");

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
        
        gray2bi = imcomplement(gray2bi);    
        gray2bi = bwareaopen(gray2bi,8000);
    
        fprintf("not Circle\n");

        len = length(B{max_curvature_index});
        total_sum = (sum(B{max_curvature_index}))/len;
    
        % total_sum=total_sum/n;
        
        total_sum_x = total_sum(1,2);
        total_sum_y = total_sum(1,1);
        
        total_sum = [total_sum_x, total_sum_y];

        plot(total_sum(:,1),total_sum(:,2),'b+');
        % Dis = total_sum - standard_notcircle;
        
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
       
        Dis = total_sum - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        if(abs(Dis(1))<60 && abs(Dis(2))<80)
            
            disp("center_found");
            moveforward(drone,'Distance',1.2,'Speed',0.8);
            break;

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1);
        end
    end

end

moveforward(drone,'Distance',0.8,'Speed',0.8);

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

moveup(drone,'Distance',0.6);
moveback(drone,'Distance',0.4);

while 1
    max_curvature = 0;
    max_curvature_index = 0;
    frame=snapshot(cam);    % snapshot 함수를 통해 카메라 객체 cam의 사진을 frame에 저장
    % frame=imread("10.jpg");
    frame2img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [R, C, X]=size(frame2img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img=zeros(size(frame2img));   % img2 변수를 사용하기 위해 사전할당을 통해 처리
    % img=zeros(size(frame2img));   % img3 변수를 사용하기 위해 사전할당을 통해 처리
    
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
    gray2bi = imclose(gray2bi,se);
    gray2bi = bwareafilt(gray2bi, 3);

    [B,L,n,A] = bwboundaries(gray2bi);
    
    % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    stats = regionprops(L,'Area','Centroid');
    
    % 원이라고 판단하는 기준 수치 threshold 값을 0.7로 설정, 원 결정 기준 설정
    threshold = 0.7;
    circle_count = 0;
    
    gray2bi = imcomplement(gray2bi);    
    gray2bi = bwareaopen(gray2bi,80);
    
    figure(2),imshow(gray2bi);
    axis on; hold on;
    
    % loop over the boundaries
    for k = 1:length(B), boundary = B{k};
        
        % compute a simple estimate of the object's perimeter
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));
    
        % obtain the area calculation corresponding to label 'k'
        area = stats(k).Area;
    
        % compute the roundness metric
        metric = 4*pi*area/perimeter^2;

        if metric > max_curvature
            max_curvature = metric;
            max_curvature_index = k;
        end
    
        % display the results
        metric_string = sprintf('%2.2f',metric);
    
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold
            area_meas=stats(k).Area;        % 해당 영역의 면적을 area_meas에 저장
            centroid = stats(k).Centroid;   % 해당 영역의 중점을 centroid에 저장
            plot(centroid(1),centroid(2),'r+');  % centroid(중점)을 figure 1에 plot 
            circle_count=circle_count+1;
            text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',14,'FontWeight','bold')
        end        
    end
    
    if circle_count == 1
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
       
        Dis = centroid - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        
        fprintf("Circle\n");

        if(abs(Dis(1))<40 && abs(Dis(2))<80)    % x 좌표 차이, y 좌표 차이가 27보다 작을 경우 앞으로 전진
            
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
        
        gray2bi = imcomplement(gray2bi);    
        gray2bi = bwareaopen(gray2bi,8000);
    
        % total_sum=zeros(size(B{1}));
        fprintf("not Circle\n");

        len = length(B{max_curvature_index});
        total_sum = (sum(B{max_curvature_index}))/len;
    
        % total_sum=total_sum/n;
        
        total_sum_x = total_sum(1,2);
        total_sum_y = total_sum(1,1);
        
        total_sum = [total_sum_x, total_sum_y];

        plot(total_sum(:,1),total_sum(:,2),'b+');
        % Dis = total_sum - standard_notcircle;
        
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
       
        Dis = total_sum - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        if(abs(Dis(1))<40 && abs(Dis(2))<80)
            
            disp("center_found");
            moveforward(drone,'Distance',1.2,'Speed',0.8);
            break;

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1);
        end
    end

end


%%%%%%%%%%%%%%%%%%%%%% case 3 turn around %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while 1  
   
    frame1 = snapshot(cam); % 사진찍기
    imwrite(frame1,'case1.png');
    
    a = imread('case1.png');
    
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
    
    if hsv(temp,temp2,1)==0&&hsv(temp,temp2,2)==1&&hsv(temp,temp2,3)==0  % 초록색일때
        turn(drone,deg2rad(30));% 시계방향으로 30도 회전
        fprintf("turn around 30 degree\n");
        subimage(hsv);
        break; % while탈출
    end
end

%%%%%%%%%%%%%%%%%%%%%% case 3 turn around end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

moveright(drone,'Distance',0.4);

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
    
    se = strel("disk",10);
    se2 = strel("rectangle",[20 20]);
    i = imerode(img2gray, se); % erode
    i2 = imopen(i,se2); % open
    
    gray2bi = imbinarize(i2);
    gray2bi = bwareaopen(gray2bi, 8000);
    gray2bi = imclose(gray2bi,se);   
    gray2bi = bwareaopen(gray2bi,1000); % 80
    gray2bi = bwareafilt(gray2bi, 2);  
    
    %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
    [B,L,n,A] = bwboundaries(gray2bi);
    %%%%%%%%% 여기서 bwboundaries를 쓰기에 여기서 모든 영역처리가 수행됨 %%%%%%%%%%
    
    % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    stats = regionprops(L,'Area','Centroid','Circularity'); % stats = regionprops(L,'Area','Centroid');
    
    % 원이라고 판단하는 기준 수치 threshold 값을 0.7로 설정, 원 결정 기준 설정
    threshold = 0.7;
    circle_count = 0;
    
    % figure(2),imshow(gray2bi);
    axis on; hold on;
    
    % loop over the boundaries
    for k = 1:length(B), boundary = B{k};
        
        % % compute a simple estimate of the object's perimeter
        % delta_sq = diff(boundary).^2;
        % perimeter = sum(sqrt(sum(delta_sq,2)));
    
        % obtain the area calculation corresponding to label 'k'
        area = stats(k).Area;
        metric = stats(k).Circularity;

        if metric > max_curvature
            max_curvature = metric;
            max_curvature_index = k;
        end
    
        % display the results
        metric_string = sprintf('%2.2f',metric);
    
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold  
            circle_count=circle_count+1;
            text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y','FontSize',14,'FontWeight','bold')
        end
    end
    
    if circle_count == 1
        fprintf("circle\n");
        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
        area_meas = stats(max_curvature_index).Area
        centroid = stats(max_curvature_index).Centroid;
        plot(centroid(1),centroid(2),'g+','LineWidth',10);  % centroid(중점)을 figure 1에 plot
        Dis = centroid - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        boundary = B{max_curvature_index};
        plot(boundary(:,2), boundary(:,1), 'g','LineWidth',5);


        if(abs(Dis(1))<60 && abs(Dis(2))<80)    
    
            if 550000<=area_meas
                disp("flag find");
                land(drone);          
                break;

            else
                disp("moveforward");
                moveforward(drone,'Distance',0.4,'Speed',0.8);   
                pause(1.5);
            end            

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1.5);
        end

    else        
        %%%%%%% 애초에 위에서 bwboundaries를 써서 여기서 의미가 없음 %%%%%%
        % gray2bi = imcomplement(gray2bi);    
        % gray2bi = bwareaopen(gray2bi,8000);
        % gray2bi = bwareafilt(gray2bi, 2);   
        %%%%%%% 애초에 위에서 bwboundaries를 써서 여기서 의미가 없음 %%%%%%

        len = length(B{max_curvature_index});
        total_sum = (sum(B{max_curvature_index}))/len;
        fprintf("not circle\n");
        area_meas=stats(max_curvature_index).Area

        total_sum_x = total_sum(1,2);
        total_sum_y = total_sum(1,1);
        
        total_sum = [total_sum_x, total_sum_y];

        plot(total_sum(:,1),total_sum(:,2),'b+','LineWidth',10);

        boundary = B{max_curvature_index};
        plot(boundary(:,2), boundary(:,1), 'b','LineWidth',5);

        offset = 140;
        drone_pos = [size(gray2bi,2)./2, size(gray2bi,1)./2-offset]; % 드론의 현재 좌표
       
        Dis = total_sum - drone_pos ; 
        norm_x = Dis(1)/norm(Dis(1));
        norm_y = Dis(2)/norm(Dis(2));
        norm_vector = [norm_x norm_y];

        if(abs(Dis(1))<60 && abs(Dis(2))<80)

            if 550000<=area_meas
                disp("flag find");
                land(drone);  
                break;

            else 

                disp("moveforward");
                moveforward(drone,'Distance',0.4,'Speed',0.8);
                pause(1.5);                

            end

        else
            move(drone, [0 norm_vector(1)*0.2 norm_vector(2)*0.2], 'Speed', 0.5);
            pause(1.5);
        end
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
    img_hsv_purple = double(zeros(size(img_hsv_h)));

    for i = 1: size(img_hsv_purple, 1)
    
        for j = 1:size(img_hsv_purple, 2)
    
            if (img_hsv_h(i, j) > 0.5 && img_hsv_h(i, j) < 0.7) && (img_hsv_v(i, j) < 0.97) && (img_hsv_s(i,j) > 0.51)
                img_hsv_purple(i, j) = 1;
            else
                img_hsv_purple(i, j) = 0;
            end
        end
    end
    
    
    BW=bwareaopen(img_hsv_purple, 1000); % 픽셀크기 1000 이하 제거
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
        moveback(drone, 0.5)
        fprintf("Too small blue circle")
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
        %turn(drone,deg2rad(-turn_ori));

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
                img_hsv_purple = double(zeros(size(img_hsv_h)));
            
                for i = 1: size(img_hsv_purple, 1)
                
                    for j = 1:size(img_hsv_purple, 2)
                
                        if (img_hsv_h(i, j) > 0.5 && img_hsv_h(i, j) < 0.7) && (img_hsv_v(i, j) < 0.97) && (img_hsv_s(i,j) > 0.51)
                            img_hsv_purple(i, j) = 1;
                        else
                            img_hsv_purple(i, j) = 0;
                        end
                    end
                end
                
                
                BW=bwareaopen(img_hsv_purple, 1000); % 픽셀크기 1000 이하 제거
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
                    moveback(drone, 0.5)
                    fprintf("Too small blue circle")
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

            find_dis = 1
            first =1;
        %elseif dis_y > 150 && first ==1 % 각도를 못찾은 상태
         %   move(drone,[0 n_y*0.2 n_z*0],'Speed',0.5);
          %  first =0

        elseif first ==1 % 각도를 찾은 상태
            fprintf("find degree\n")
            if dis_y <45
                distance_y2 = dis_y
                    if area_blue > 5000 && area_blue < 8500
                        fprintf("find purple start\n")
                        %% 보라색 인식
                        while 1
                            
                            frame4 = snapshot(cam); % 사진찍기
                            imwrite(frame4, 'purple.png');

                            img_rgb = imread('purple.png');
                        
                            img_hsv = rgb2hsv(img_rgb);
                            
                            img_hsv_h = img_hsv(:,:,1);
                            img_hsv_s = img_hsv(:,:,2);
                            img_hsv_v = img_hsv(:,:,3);
                            img_hsv_purple = double(zeros(size(img_hsv_h)));
                        
                            for i = 1: size(img_hsv_purple, 1)
                            
                                for j = 1:size(img_hsv_purple, 2)
                            
                                    if (img_hsv_h(i, j) > 0.65 && img_hsv_h(i, j) < 0.86) && (img_hsv_v(i, j) < 0.97) && (img_hsv_s(i,j) > 0.2)
                                        img_hsv_purple(i, j) = 1;
                                    else
                                        img_hsv_purple(i, j) = 0;
                                    end
                                end
                            end

                            BW=bwareaopen(img_hsv_purple, 500); % 픽셀크기 1000 이하 제거
                            se = strel("disk", 3);
                            se2 = strel("disk",6);
                            i = imerode(BW, se); % 침식
                            i2 = imdilate(i,se2); % 팽창
                            se3 = strel("disk",2);
                            i3 = imdilate(i2,se3); % open
                            i4=imfill(i3,"holes");
                            BW2 = bwareafilt(i4,1);
                            area_purple = bwarea(BW2)
                            
                            center = regionprops(BW2,'centroid'); % BW 이진화그림의 객체의 중심을 찾아주는 함수
                            center_purple = cat(1,center.Centroid);
                            
                            offset = 140;
                            drone_pos=[size(BW2,2)./2, size(BW2,1)./2-offset];
                            d_y=drone_pos(1,1); % 드론의 중점의 y축 저장
                            d_z=drone_pos(1,2); % 드론의 중점의 z축 저장
                            o_y_purple = center_purple(1); %  보라색 객체의 y축
                            o_z_purple = center_purple(2); %  보라색 객체의 z축
                    

                            dis_y=norm(d_y-o_y_purple); % 드론의 중점과 객체의 중점사이의 거리 측정
                            dis_z=norm(d_z-o_z_purple); % 드론의 중점과 객체의 중점사이의 거리 측정
                            
                            n_y = (o_y_purple-d_y)/dis_y; % 단위벡터 계산
                            n_z = (o_z_purple-d_z)/dis_z; % 단위벡터 계산
                            
                            imshow(BW2), hold on;
                            hold on
                            plot(o_y_purple,o_z_purple,'b*')
                            plot(d_y,d_z,'r+') % 드론의 위치를 plot해주는 함수
                            hold off
                            
                            if dis_y < 30
                             if area_blue > 5000 && area_blue < 5500
                                 fprintf("move 0.5m")
                                 move(drone,[0.4 n_y*0 n_z*0],'Speed',0.5);
                                 land(drone);
                                 break;
                             elseif area_blue >= 5500 && area_blue < 6000
                                 fprintf("move 0.4m")
                                 move(drone,[0.3 n_y*0 n_z*0],'Speed',0.5);
                                 land(drone);
                                 break;
                             elseif area_blue >= 6000 && area_blue < 6500
                                 fprintf("move 0.3m")
                                 move(drone,[0.3 n_y*0 n_z*0],'Speed',0.5);
                                 land(drone);
                                 break;
                             else 
                                 fprintf("move 0.2m")
                                 move(drone,[0.2 n_y*0 n_z*0],'Speed',0.5);
                                 land(drone);
                                 break;
                             end
                            else
                                move(drone,[0 n_y*0.2 n_z*0],'Speed',0.5);
                            end
                        end
                    elseif area_blue > 10000
                         move(drone,[-1 0 -0.7],'Speed',0.5);
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







    


```    
    
