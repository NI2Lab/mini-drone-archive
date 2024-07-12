%% InhaAerospace_finalcode
clc
clear

%% Bobby
%Bobby on
bobby = ryze();             %드론연결
bobbycam = camera(bobby);   %드론 카메라 연결
%preview(bobbycam)          %드론 preview On

% Bobby takeoff
takeoff(bobby)              %드론 takeoff

%moveup(bobby,'Distance',0.2)%시야각 확장

moveback(bobby,'Distance',0.3)%시야각 확장
%fprintf("move back")
max_cap = 25;
 img = snapshot(bobbycam);
 img_size = size(img);
 img_vec = zeros(img_size(1),img_size(2),max_cap);
 black = zeros(img_size(1),img_size(2));
%% 색상 타겟 배열(첫번째 빨강1,초록2,보라,3,두번째 빨강4)
  target_num = 1;
  r = 1;
  rot_n =0;
while 1
%% ----------링의 중점 탐색----------%%
while 1
%% 최적 이미지 검출
%30장의 snapsht 촬영, blue 색조픽셀이 가장 많은 이미지 검출(파랑1,빨강2,초록3,보라4)
color = 1;
max_cap = 25;
pause(1)
    for i = 1:max_cap
        img = snapshot(bobbycam);
        hsv_img = rgb2hsv(img); % RGB 이미지를 HSV 이미지로 변환
        H = hsv_img(:,:,1);     % HSV 데이터의 색조 추출
        img_ = ((H>0.588)&(H<0.665));
        if isempty(img)
            mark_sum(i) = 0;        
        else
            mark_sum(i) = sum(img_,'all');
            img_vec(:,:,i) = img_;
        end
    end     
    [~,ind] = max(mark_sum);
     blue=img_vec(:,:,ind);

%% Cam의 center
[cam_length_x,cam_length_y] = size(blue);
cam_center_x =round(0.5*cam_length_y);
cam_center_y =round(0.5*cam_length_x)-150;  %실제 드론의 위치와 snapshot의 위치를 보정함

%% 이미지 수축
%이미지의 블러 효율을 높이기 위해 imresize 함수를 사용하여 이미지의 해상도를 낮춤
C_shrink =0.8;    %이미지를 C_shrink 만큼 수축시킴
img_cont = imresize(blue, [round(cam_length_x*C_shrink),round(cam_length_y*C_shrink)]);

%% 이미지 블러처리
Cb =20;
image_size = size(img_cont);
for i = 1:image_size(1)
    colum = img_cont(i,:);
    for j = ((Cb/2) + 1) : length(colum) - (20/2)
        if sum(colum(j - (Cb*0.5):j + (Cb*0.5))) >= 20
            img_cont(i,j) = 1;
        elseif sum(colum(j - (Cb*0.5):j + (Cb*0.5))) < Cb*0.85
            img_cont(i,j) = 0;
        end
    end
end
for j = 1:image_size(2)
    row =img_cont(:,j);
    for i = ((Cb/2) + 1) : length(row) - (Cb/2)
        if sum(row(i - (Cb*0.5): i + (Cb*0.5))) >= Cb
            img_cont(i,j) = 1;
        elseif sum(row(i - (Cb*0.5): i + (Cb*0.5))) < Cb*0.85
            img_cont(i,j) = 0;
        end
    end
end
blured_img = img_cont;

%% 객체 선정으로 노이즈 제거
% bwconncomp 함수 사용
CC = bwconncomp(blured_img,4);
stats =regionprops(CC,'Area');
Areas = [stats.Area];
img = false(size(blured_img));

for i = 1:3
    [~,ind]=max(Areas);
    img(CC.PixelIdxList{ind}) = true;
    Areas(ind) = NaN;
end

%% 큰 노이즈 제거를 위한 이미지 블러처리(큰 노이즈 분해)
Cb = 10;
image_size = size(img);
for i = 1:image_size(1)
    colum = img(i,:);
    for j = ((Cb/2) + 1) : length(colum) - (Cb/2)
        if sum(colum(j - (Cb*0.5):j + (Cb*0.5))) >= Cb
            img(i,j) = 1;
        elseif sum(colum(j - (Cb*0.5):j + (Cb*0.5))) < Cb*0.85
            img(i,j) = 0;
        end
    end
end
for j = 1:image_size(2)
    row =img(:,j);
    for i = ((Cb/2) + 1) : length(row) - (Cb/2)
        if sum(row(i - (Cb*0.5): i + (Cb*0.5))) >= Cb
            img(i,j) = 1;
        elseif sum(row(i - (Cb*0.5): i + (Cb*0.5))) < Cb*0.85
            img(i,j) = 0;
        end
    end
end
blured_img = img;

%% 객체 선정으로 큰 노이즈 제거
CC = bwconncomp(blured_img,8);
stats =regionprops(CC,'Area');
Areas = [stats.Area];
img = false(size(blured_img));

[~,ind]=max(Areas);
img(CC.PixelIdxList{ind}) = true;

%% 링의 모서리의 위치 탐색
[crow,ccol] = find(img==1);  %블러처리한 링의 끝단 부분을 탐색

% 가림막 링의 모서리 위치들(해상도 변경 이전 점들)
edge_top_target = min(crow)*(1/C_shrink);
edge_bottom_target = max(crow)*(1/C_shrink);
edge_left_target = min(ccol)*(1/C_shrink);
edge_right_target = max(ccol)*(1/C_shrink);
edge_horizon_center = mean(ccol)*(1/C_shrink);
edge_vertical_center = mean(crow)*(1/C_shrink);

%% 이미지 crop
% 표적(링) 이외의 노이즈들을 무시하고, 링의 내부를 탐색하기 위해 표적의 테두리를 기준으로
% 이미지를 crop함
C_crop = 1;     %crop 비율계수
croped_img = imcrop(blue, [edge_left_target*C_crop,edge_top_target,abs(edge_right_target-edge_left_target)/C_crop,abs(edge_top_target-edge_bottom_target)]);

%% 표적 근처의 잔여 노이즈 제거
%표적 근처의 잔여 노이즈를 blur처리하여 밀도를 낮추고, bwconncomp 함수를 사용하여 노이즈를 제거함.
Cb = 60;
image_size = size(croped_img);
for i = 1:image_size(1)
    colum = croped_img(i,:);
    for j = ((Cb/2) + 1) : length(colum) - (Cb/2)
        if sum(colum(j - (Cb*0.5):j + (Cb*0.5))) >= Cb
            croped_img(i,j) = 1;
        elseif sum(colum(j - (Cb*0.5):j + (Cb*0.5))) < Cb*0.85
            croped_img(i,j) = 0;
        end
    end
end
for j = 1:image_size(2)
    row =croped_img(:,j);
    for i = ((Cb/2) + 1) : length(row) - (Cb/2)
        if sum(row(i - (Cb*0.5): i + (Cb*0.5))) >= Cb
            croped_img(i,j) = 1;
        elseif sum(row(i - (Cb*0.5): i + (Cb*0.5))) < Cb*0.85
            croped_img(i,j) = 0;
        end
    end
end
crop_blured_img = croped_img;

CC = bwconncomp(crop_blured_img,8);
stats =regionprops(CC,'Area');
Areas = [stats.Area];
crop_blured_img = false(size(crop_blured_img));

[~,ind]=max(Areas);
crop_blured_img(CC.PixelIdxList{ind}) = true;

%% 링의 모서리 계산
% crop, blur 된 이미지의 center
horizon_center = edge_horizon_center - edge_left_target ;
vertical_center = edge_vertical_center - edge_top_target;

row_ = double(crop_blured_img(floor(vertical_center),:));
col_ = double(crop_blured_img(:,floor(horizon_center)));

cir_right = find(row_(floor(horizon_center):end) == 1, 1, "first") + horizon_center;
fliped_row = flip(row_(1:floor(horizon_center)));
cir_left = -find(fliped_row == 1, 1, 'first') + horizon_center;

cir_bottom = find(col_(floor(vertical_center):end) == 1, 1, 'first') + vertical_center;
fliped_col = flip(col_(1:floor(vertical_center)));
cir_top = -find(fliped_col == 1, 1, "first") + vertical_center;

k = isempty(cir_top) + isempty(cir_bottom) + isempty(cir_left) + isempty(cir_right);
if k == 0   %k는 탐색할 수 없는 점의 개수
    c_center_x = 0.5 * (cir_right + cir_left);
    c_center_y = 0.5 * (cir_top + cir_bottom);
    plot(c_center_x, c_center_y, 'x')
    
    center_x = c_center_x + edge_left_target;
    center_y = c_center_y + edge_top_target;
    fprintf("the center of ring : (%f, %f)\n", center_x, center_y);
    
    %이미지 모니터링
    imshow(blue)
    hold on
    plot(center_x, center_y, '+', 'MarkerSize', 10, 'Color', 'r', 'LineWidth', 1)
    plot(edge_horizon_center,edge_top_target,'x', 'MarkerSize', 10)
    plot(edge_horizon_center,edge_bottom_target,'x', 'MarkerSize', 10)
    plot(edge_left_target,edge_vertical_center,'x', 'MarkerSize', 10)
    plot(edge_right_target,edge_vertical_center,'x', 'MarkerSize', 10)
    plot(edge_horizon_center,edge_vertical_center,'o', 'MarkerSize', 10)
    plot(cam_center_x,cam_center_y,'x', 'MarkerSize', 10, 'Color', 'b', 'LineWidth', 5)
    hold off
    x_distance = center_x - cam_center_x;
    y_distance = center_y - cam_center_y;
    fprintf("x_dist : %f,y_dist : %f\n",x_distance,y_distance)
    %% 드론 제어
    x_coef = 1;
    critical_distance = 65;      %[pixel]
    if r == 1
        critical_distance = 85;
        x_coef = 0.85;
    end
    %제어 종료조건

    if rot_n ~= 1
    %x축 위치 조정
        if (abs(x_distance) < critical_distance*x_coef) && (abs(y_distance) < critical_distance )
        fprintf("bobby found center of ring!\n")
        rot_n = 0;
            break
        end
        if abs(x_distance) > critical_distance 
            if sign(x_distance) ==-1
                moveleft(bobby,'Distance',0.2)
                pause(0.01)

                fprintf("move left\n")
            elseif sign(x_distance) == 1
                moveright(bobby,'Distance',0.2)
                pause(0.01)

                fprintf("move right\n")
            end
        end

    %y축 위치 조정
        if (abs(x_distance) < critical_distance*x_coef) && (abs(y_distance) < critical_distance )
        fprintf("bobby found center of ring!\n")
        rot_n = 0;
            break
        end
        if abs(y_distance) > critical_distance
            if sign(y_distance) == -1
                moveup(bobby,'Distance',0.2)
            
            
                fprintf("move up\n")
            elseif sign(y_distance) == 1
                movedown(bobby,'Distance',0.2)
            
                fprintf("move down\n")
            end
    
        end
        if (abs(x_distance) < critical_distance*x_coef) && (abs(y_distance) < critical_distance )
        fprintf("bobby found center of ring!\n")
        rot_n = 0;
            break
        end
    else%% rotate n이 1인경우 (돌아야 하는 경우) 
            if sign(x_distance) == -1
                turn(bobby,deg2rad(-(60/960)*abs(x_distance))) 
                fprintf("turn left\n")
            elseif sign(x_distance) == 1
                turn(bobby,deg2rad((60/960)*abs(x_distance)))
                fprintf("turn left\n")
            end
            if abs(y_distance) > critical_distance
            if sign(y_distance) == -1
                moveup(bobby,'Distance',0.2)
                fprintf("move up\n")
            elseif sign(y_distance) == 1
                movedown(bobby,'Distance',0.2)
            
                fprintf("move down\n")
            end
            end
            if (abs(x_distance) < critical_distance-5) && (abs(y_distance) < critical_distance )
                fprintf("bobby found center of ring!\n")
                break
            end

    end
else
    %링 위의 점4개를 찾지 못한다면 뒤로 이동하여 다시 탐색함.
    fprintf("center of the ring cannot be found!\n");
    moveback(bobby,'Distance',0.2,'Speed',1)
    pause(0.1)
    moveup(bobby,'Distance',0.2,'Speed',1)
    continue
end %이미지 탐색 종료
end %----------이미지 중점탐색 종료----------%

%% 링의 중점을 확인하여 드론을 이동
cam_center_y =round(0.5*cam_length_x);  %cam의 center를 보정 전으로 설정
critical_distance = 60;
switch target_num
%% 표적이 첫 번째 빨간색일 때
    case 1  
    moveforward(bobby,'Distance',3.4,'Speed',1) %첫 번째 빨간색 표적을 향해 전진
    r = 0;
    x_coef = 1;
    while 1 
        %30장의 snapsht 촬영, blue 색조픽셀이 가장 많은 이미지 검출(첫번째 빨강1,초록2,보라,3,두번째 빨강4)
        color = target_num;
        for i = 1:max_cap
            img = snapshot(bobbycam);
            hsv_img = rgb2hsv(img); % RGB 이미지를 HSV 이미지로 변환
            H = hsv_img(:,:,1);     % HSV 데이터의 색조 추출
            if (color == 1) || (color == 4) 
                img_ = ((H>0)&(H<0.03)) | ((H>0.93)&(H<1)); %red
            elseif color == 2
                img_ = ((H>0.35)&(H<0.37));   %green
            elseif color == 3
                img_ = ((H>0.69)&(H<0.74));   %purple
            end
            if isempty(img)
                mark_sum(i) = 0;        
            else
                mark_sum(i) = sum(img_,'all');
                img_vec(:,:,i) = img_;
            end
        end     
        [~,ind] = max(mark_sum);
        red=img_vec(:,:,ind);
    %빨간색 표적 이외의 노이즈 제거
    CC = bwconncomp(red,8);
    stats =regionprops(CC,'Area');
    Areas = [stats.Area];
    red = false(size(red));
    [~,ind]=max(Areas);
    red(CC.PixelIdxList{ind}) = true;

    %빨간색 표적의 중점 탐색
    [r_row,r_col] = find(red==1);
    red_center_x = mean(r_col);
    red_center_y = mean(r_row)
    hold on
    imshow(red)
    plot(red_center_x, red_center_y,'Marker','+','MarkerSize',8,'Color','r')
    
    %빨간색 인식
        if sum(red,'all') > 691200*0.004
           fprintf("bobby found a red marker!\n")
           target_num = 2; %빨간색 마커를 인식하면, 다음 타겟 마커를 초록색으로 지정함
           turn(bobby,deg2rad(120))
           course01 = toc;
           tic
           fprintf("course 0 to 1 has %1.2f second",course01)
           moveforward(bobby,'Distance',3.2,'Speed',1)
           rot_n = 1;
            break
        else
            moveforward(bobby,'Distance',0.2)
        end %빨간색 인식 완료
    end %빨간색 이미지 탐색 종료




%% 표적이 초록색일 때
    case 2  
         rot_n = 1;
        if (abs(x_distance) > critical_distance)
            continue
        else
            rot_n = 0;
        end

        
        moveforward(bobby,'Distance',1.8,'Speed',0.6) %링의 중점을 찾고, 그 지점으로 각도 정렬후 전진.
        

        %30장의 snapsht 촬영, blue 색조픽셀이 가장 많은 이미지 검출(첫번째 빨강1,초록2,보라,3,두번째 빨강4)
        color = target_num;
        for i = 1:max_cap
            img = snapshot(bobbycam);
            hsv_img = rgb2hsv(img); % RGB 이미지를 HSV 이미지로 변환
            H = hsv_img(:,:,1);     % HSV 데이터의 색조 추출
            if (color == 1) || (color == 4) 
                img_ = ((H>0)&(H<0.03)) | ((H>0.93)&(H<1)); %red
            elseif color == 2
                img_ = ((H>0.29)&(H<0.39));   %green
            elseif color == 3
                    img_ = ((H>0.69)&(H<0.861));   %purple
            end
            if isempty(img)
                mark_sum(i) = 0;        
            else
                mark_sum(i) = sum(img_,'all');
                img_vec(:,:,i) = img_;
            end
        end     
        [~,ind] = max(mark_sum);
        green=img_vec(:,:,ind);

        %초록색 표적 이외의 노이즈 제거
        CC = bwconncomp(green,8);
        stats =regionprops(CC,'Area');
        Areas = [stats.Area];
        green = false(size(green));
        [~,ind]=max(Areas);
        green(CC.PixelIdxList{ind}) = true;
        
        
        %초록색 인식
        if  sum(green,'all') > 691200*0.0004
            imshow(green)
            fprintf("bobby found a green marker!\n")
            target_num = 3; %초록색 마커를 인식하면, 다음 타겟 마커를 보라색으로 지정함
            turn(bobby,deg2rad(-135))
            moveforward(bobby,'Distance',1,'Speed',1)
            rot_n = 1;
        else
            fprintf("bobby did not found a green marker!\n")
            moveback(bobby,'Distance',0.2)
        end %초록색 인식완료

%% 표적이 보라색일 때
    case 3  
        
        x_distance = center_x - cam_center_x;
        if abs(x_distance) > critical_distance
            continue
        else
            rot_n = 0;
            moveforward(bobby,'Distance',2.5,'Speed',0.7) %링의 중점을 찾고, 그 지점으로 각도 정렬후 전진.
        end
        
        %30장의 snapsht 촬영, blue 색조픽셀이 가장 많은 이미지 검출(첫번째 빨강1,초록2,보라,3,두번째 빨강4)
        color = target_num;
        for i = 1:max_cap
            img = snapshot(bobbycam);
            hsv_img = rgb2hsv(img); % RGB 이미지를 HSV 이미지로 변환
            H = hsv_img(:,:,1);     % HSV 데이터의 색조 추출
            if (color == 1) || (color == 4) 
                img_ = ((H>0)&(H<0.03)) | ((H>0.93)&(H<1)); %red
            elseif color == 2
                img_ = ((H>0.29)&(H<0.39));   %green
            elseif color == 3
                    img_ = ((H>0.69)&(H<0.861));   %purple
            end
            if isempty(img)
                mark_sum(i) = 0;        
            else
                mark_sum(i) = sum(img_,'all');
                img_vec(:,:,i) = img_;
            end
        end     
        [~,ind] = max(mark_sum);
        purple=img_vec(:,:,ind);

        %보라색 표적 이외의 노이즈 제거
        CC = bwconncomp(purple,8);
        stats =regionprops(CC,'Area');
        Areas = [stats.Area];
        purple = false(size(purple));
        [~,ind]=max(Areas);
        purple(CC.PixelIdxList{ind}) = true;
        
        
        %보라색 인식
        if sum(purple,'all') > 691200*0.0008
            fprintf("bobby found a purple marker!\n")
            target_num = 4; %보라색 마커를 인식하면, 다음 타겟 마커를 두 번째 빨간색으로 지정함
            turn(bobby,deg2rad(215))
            moveforward(bobby,'Distance',3.4,'Speed',0.8)
            rot_n = 1;
        else
            fprintf("bobby can't found purple marker!\n")
            moveback(bobby,'Distance',0.2)
            continue
           
        end %보라색 인식완료
        
    case 4  %표적이 두번째 빨간색일 때
        
        x_distance = center_x - cam_center_x;
        if abs(x_distance) > critical_distance
            continue
        else
            rot_n = 0;
            fprintf("arrived at final ring\n")
        end
 % 최종 빨간색 마커의 중심점을 찾고, 빨간색 마커의 픽셀수를 파악하여 착륙지점을 계산함
        while 1

        %30장의 snapoht 촬영, blue 색조픽셀이 가장 많은 이미지 검출(첫번째 빨강1,초록2,보라,3,두번째 빨강4)
        color = target_num;
        for i = 1:max_cap
            img = snapshot(bobbycam);
            hsv_img = rgb2hsv(img); % RGB 이미지를 HSV 이미지로 변환
            H = hsv_img(:,:,1);     % HSV 데이터의 색조 추출
            if (color == 1) || (color == 4) 
                img_ = ((H>0)&(H<0.03)) | ((H>0.93)&(H<1)); %red
            elseif color == 2
                img_ = ((H>0.29)&(H<0.39));   %green
            elseif color == 3
                    img_ = ((H>0.69)&(H<0.861));   %purple
            end
            if isempty(img)
                mark_sum(i) = 0;        
            else
                mark_sum(i) = sum(img_,'all');
                img_vec(:,:,i) = img_;
            end
        end     
        [~,ind] = max(mark_sum);
        red_2=img_vec(:,:,ind);


        %두 번째 빨강 표적 이외의 노이즈 제거
        CC = bwconncomp(red_2,8);
        stats =regionprops(CC,'Area');
        Areas = [stats.Area];
        red_2 = false(size(red_2));
        [~,ind]=max(Areas);
        red_2(CC.PixelIdxList{ind}) = true;

        %두 번째 빨간색 표적의 중점 탐색
        [r_row,r_col] = find(red_2==1);
        red_center_x = mean(r_col);
        red_center_y = mean(r_row);
        hold on
        imshow(red_2)
        plot(red_center_x, red_center_y,'Marker','+','MarkerSize',8,'Color','r')

        x_distance = red_center_x - cam_center_x;
        y_distance = red_center_y - cam_center_y;
        

        while (sum(red_2,'all') > (img_size(1)*img_size(2)*0.013744212)) && (sum(red_2,'all') < (img_size(1)*img_size(2)*0.0217013888))
        %두번째 빨강 인식
        if (sum(red_2,'all') < (img_size(1)*img_size(2)*0.013744212))  
            moveforward(bobby,'Distance',0.2,'Speed',0.3)

        elseif (sum(red_2,'all') > (img_size(1)*img_size(2)*0.0217013888))
            moveback(bobby,'Distance',0.2,'Speed', 0.3)
        else
            land(bobby);
            fprintf("bobby landing!\n")
            break
        end
        end %마지막 타겟 인식완료
        end %case 4번의 while문 종료
end %switch문 종료

end %전체 코드 종료
land(bobby)
