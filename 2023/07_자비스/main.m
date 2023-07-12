%% 코드 초기화 및 기본 세팅
    clc;
    close all;
    clear;
   
    drone=ryze();
    cam=camera(drone);
    
    takeoff(drone);
    pause(1);
    
    %초기 높이 조절  1m =< 드론 <=2m : 이상적인 높이 1.2m 
    
    [height,] = readHeight(drone);
    
    if (height<1.2)
        moveup(drone,'Distance',1.2-height,'Speed',0.4)
    elseif (hegith>1.2)
        movedown(drone,'Distance',1.2-height,'Speed',0.4)
    end
    
    pause(1);
    
    [n_height,] = readHeight(drone); %1.2m높이출력

    fprintf('현재드론높이:%.2f',n_height)

%%파란색 사각형 내부 원의 중점 찾기

  e_b=0;
  back=0;
  no_circle=1;
  escape2=0;
  back_ct=0;
  
  while (e_b==0)

    frame=snapshot(cam);
    img_rgb = frame; % 이미지를 불러옵니다.
       
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_s = img_hsv(:,:,2); % S   채널

    img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

    %드론의 중점좌표
    mySize = size(img_rgb);
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;

    pause(1);
    
    %img_hsv_blue 2진화 이미지 생성    
    for i = 1: size(img_hsv_blue, 1)
        for j = 1:size(img_hsv_blue, 2)
            if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란 hsv조정
                img_hsv_blue(i, j) = 1;
            end
        end
    end


    blue_pixel = sum(img_hsv_blue,"all"); %파란 사각형의 픽셀의 수

    filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
    [m, n] = size(filled_image);  % filled_image의 크기 확인
    
    pause(1);

    circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
     % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end
 
      fprintf('sum(circle_image,"all")=%d\n',sum(circle_image,"all"))  %circle_image = 파란색 사각형의 내부의 원의 픽셀의 수
      fprintf('sum(img_hsv_blue,"all")=%d\n',sum(img_hsv_blue,"all"))  %circle_image = 파란색 사각형의 픽셀의 수
     
       imshow(img_hsv_blue)
       imshow(circle_image)

      % 1.원이 모두 다 보일 경우 
      if   (sum(circle_image,"all") >=130000)  
           fprintf('원이 잘보입니다!!x\n') 

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출
            imshow(circle_image)
            plot(centroids(:,1),centroids(:,2),'r*') %원의 중점 표시
            plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론이 보는 화면의 중점 표시
            hold off
        
        %드론의 x좌표와 원의 x좌표 맞추기    
            ct=0;
        while (ct>5 || ((center_drone_x + 20 > cir_x) && (center_drone_x -20 < cir_x))==0)     
             frame=snapshot(cam);
            img_rgb = frame; % 이미지를 불러옵니다.
       
            img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

            img_hsv_h = img_hsv(:,:,1); % Hue 채널
            img_hsv_s = img_hsv(:,:,2); % S   채널

            img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

            %드론의 중점좌표
            mySize = size(img_rgb);
            a = mySize(:,1);
            b = mySize(:,2);
    
            center_drone_x = b / 2;
            center_drone_y = a / 2;
    
            %img_hsv_blue 2진화 이미지 생성    
            for i = 1: size(img_hsv_blue, 
                for j = 1:size(img_hsv_blue, 2)
                    if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란색 hsv조정
                        img_hsv_blue(i, j) = 1;
                    end
                end
            end
    
            filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
            [m, n] = size(filled_image);  % filled_image의 크기 확인

            circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
            % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출
                    
            %드론의 중점을 원의 중점에 위치
            if (center_drone_x > cir_x)
                fprintf('왼쪽으로 ㄱㄱ')
                disp(center_drone_x - cir_x)
                moveleft(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);
            elseif(center_drone_x < cir_x)
                fprintf('\n오른쪽으로 ㄱㄱ')
                disp(center_drone_x - cir_x)
                moveright(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);    
            end
        end  
        
        fprintf('\nx축 일치\n')
            
        %드론의 중심y좌표와 원의 중심y좌표 맞추기 
            ct=0;
        while (ct>5 || ((center_drone_y + 20 > cir_y) && (center_drone_y -20 < cir_y))==0)  
            
             frame=snapshot(cam);
            img_rgb = frame; % 이미지를 불러옵니다.
       
            img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

            img_hsv_h = img_hsv(:,:,1); % Hue 채널
            img_hsv_s = img_hsv(:,:,2); % S   채널

            img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

            %드론의 중점좌표
            mySize = size(img_rgb);
            a = mySize(:,1);
            b = mySize(:,2);
    
            center_drone_x = b / 2;
            center_drone_y = a / 2;
    
            %img_hsv_blue 2진화 이미지 생성    
            for i = 1: size(img_hsv_blue, 
                for j = 1:size(img_hsv_blue, 2)
                    if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란색 hsv조정
                        img_hsv_blue(i, j) = 1;
                    end
                end
            end
    
            filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
            [m, n] = size(filled_image);  % filled_image의 크기 확인

            circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
            % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출                    
            
            if (center_drone_y+20 < cir_y)
                fprintf('\n아래쪽으로 ㄱㄱ')
                disp(center_drone_y - cir_y)
                movedown(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);
            elseif(center_drone_y-20 > cir_y)
                fprintf('\n위쪽으로 ㄱㄱ')
                disp(center_drone_y - cir_y)
                moveup(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);                
            end
        end
            fprintf('\ny축 일치\n')

            if back>=1
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               moveforward(drone,'distance',back*0.4,'Speed',0.1);
               pause(1); 
               e_b=1;
            else
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               e_b=1; % while탈출 => 원의 중점과 드론의 중점 일치
            end  
        
        
    % 2.원이 부분보일 때 - circle_image가 너무 작거나 제대로 인식x  ===>임계값 설정필요
    elseif  sum(circle_image,"all") < 130000             
       
        % 2(1):멀리있는 경우
        if  sum(img_hsv_blue,"all") < 200000 
            left_side = sum(imcrop(img_hsv_blue,[0 0 center_drone_x center_drone_y*2]),'all');
            right_side = sum(imcrop(img_hsv_blue,[center_drone_x 0 center_drone_x center_drone_y*2]),'all');
            up_side = sum(imcrop(img_hsv_blue,[0 0 center_drone_x*2 center_drone_y]),'all');
            down_side = sum(imcrop(img_hsv_blue,[0 360 center_drone_x*2 center_drone_y*2]),'all');

            diff_lr=left_side-right_side;
            diff_ud=up_side-down_side;
         
            fprintf('diff_lr = %d  diff_ud = %d\n',diff_lr, diff_ud)

            if(diff_lr>80000) %좌우비교 ==> 임계값 설정 필요
                fprintf('왼쪽으로 0.3m이동\n')
                moveleft(drone,'Distance',0.3,'Speed',0.1);
                pause(2); 
            elseif(diff_lr<-80000)
                fprintf('오른쪽으로 0.3m이동\n')
                moveright(drone,'Distance',0.3,'Speed',0.1);
                pause(2);              
            end
            fprintf('좌우이동정지\n')
            escape2=escape2+1;
         
            if(diff_ud>70000) %상하비교 ==> 임계값 설정 필요
                fprintf('위쪽으로 0.2m이동\n')
                moveup(drone,'Distance',0.2,'Speed',0.1);
                pause(2); 
            elseif(diff_ud<-70000)
                fprintf('아래쪽으로 0.2m이동\n')
                movedown(drone,'Distance',0.2,'Speed',0.1);
                pause(2); 
            end
            fprintf('상하이동정지\n')
            escape2=escape2+1;

         
            %좌우상하의 픽셀값이 거의 엇비슷한데 원이 안나타나는 경우
         if escape2>=12                   
            moveforward(drone,'distance',0.8,'Speed',0.1);
            pause(1);
            moveforward(drone,'distance',0.7,'Speed',0.1);
            pause(1);
            eb_1=1;
            if back>=1
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               moveforward(drone,'distance',back*0.4,'Speed',0.1);
               pause(1); 
               eb_1=1;
            end
         end   
         
         
        % 2(2):가까이 있는 경우 
        elseif sum(img_hsv_blue,"all") > 200000 
                moveback(drone,'Distance',0.2,'Speed',0.1);
                back=back+1;
                pause(2); 
        end

       % 3.원이 보이지 않은경우
      elseif blue_pixel < 800   
            fprintf('blue_pixel=%d\n',blue_pixel)
            fprintf('원이 보이지 않는다\n')
        
            if back_ct <2 %먼저 뒤로 이동
                moveback(drone,'Distance',0.3,'Speed',0.1);             
                back=back+1; %전체 back횟수
                back_ct=back_ct+1; %원이 보이지 않을 때 back횟수
                pause(1);
            elseif back_ct==2 && mod(no_circle,2)==1
                fprintf('오른쪽으로 (0.3*no_circle)m이동\n')
                moveright(drone,'Distance',0.2*no_circle,'Speed',0.3)
                no_circle=no_circle+1;
                fprintf('no_circle=%d\n',no_circle)
                pause(2);
            elseif back_ct==2 && mod(no_circle,2)==0
                fprintf('왼쪽으로 (0.3*no_circle)m이동\n')
                moveleft(drone,'Distance',0.2*no_circle,'Speed',0.3)
                no_circle=no_circle+1;
                fprintf('no_circle=%d\n',no_circle)
                pause(2);
            end     
      end
  end

   frame=snapshot(cam);
 
    img_rgb = frame; % 이미지를 불러옵니다.
   
    %드론의 중심좌표
    mySize = size(img_rgb);
    
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;
    
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1);% Hue 채널
    img_hsv_s = img_hsv(:,:,2);% Hue 채널
   
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.01 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)   %%%%%%%%빨강이HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off

    r = 0;
    x = 0;
    y = 0;

  %드론의 X좌표와 빨간색 표적의 X좌표 맞추기 
  while ((x>3) || ((center_drone_x + 15 > red_x) && (center_drone_x -15 < red_x)))==0
    
    frame=snapshot(cam);
      
    img_rgb = frame; % 이미지를 불러옵니다.
   
    %드론의 중심좌표
    mySize = size(img_rgb);
    
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;
    
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_S = img_hsv(:,:,2); % S   채널
    
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.02 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)  %%%%%%%%빨강이HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off      
            
      if (center_drone_x > red_x)
        fprintf('\n왼쪽으로 ㄱㄱ')
        disp(center_drone_x - red_x)
        moveleft(drone,'distance',0.2,'Speed',0.2);
        x=x+1;
        fprintf(' x의 값은 %d\n',x)
        pause(1);
     elseif(center_drone_x < red_x)
        fprintf('\n오른쪽으로 ㄱㄱ')
        moveright(drone,'distance',0.2,'Speed',0.1);
        disp(center_drone_x - red_x)
        x=x+1;
        pause(1);
        fprintf(" x의 값은 %d\n",x)          
     end
  end

  fprintf('\nx축 일치\n')
  fprintf('x = %d',x)


  %드론의 y좌표와 빨간색 표적의 y좌표 맞추기
  while ((y>3) || ((center_drone_y + 20 > red_y) && (center_drone_y -20 < red_y)))==0
    
    frame=snapshot(cam);   
    img_rgb = frame; % 이미지를 불러옵니다.
   
    %드론의 중심좌표
    mySize = size(img_rgb);
    
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;
    
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_s = img_hsv(:,:,2); % S   채널
   
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.02 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)  %%%%%%%%%% 빨강HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off      
      
     if (center_drone_y < red_y)
        fprintf('\n아래쪽으로 ㄱㄱ')
        movedown(drone,'distance',0.2,'Speed',0.1);
        disp(center_drone_y - red_y)
        y=y+1;
        fprintf(' y의 값은 %d\n',y)
        pause(1);
    elseif(center_drone_y > red_y)
        fprintf('\n위쪽으로 ㄱㄱ')
        moveup(drone,'distance',0.2,'Speed',0.1);
        disp(center_drone_y - red_y)
        y=y+1;
        fprintf(' y의 값은 %d\n',y)
        pause(1);
      
    end
  end
   
  fprintf('\ny축 일치\n')
  fprintf('y = %d',y)
  

while ((r>5)==0)
    
    frame=snapshot(cam);
    img_rgb = frame; % 이미지를 불러옵니다.

    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_s = img_hsv(:,:,2); % S   채널
   
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.02 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)   %%%%%빨강이 HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off
    
    fprintf('\n빨간색 임계값:%d',sum(img_hsv_red,'all'))

    if (sum(img_hsv_red,'all') >= 4000) && (sum(img_hsv_red,'all') <= 9000) %임계값 설정
        fprintf('\n표적 발견')
        turn(drone,deg2rad(90));
        r=r+5;
        fprintf(' r의 값은 %d',r)
        pause(1);
    elseif (sum(img_hsv_red,'all') > 9000)       
        fprintf('\n표적 너무 가까움')
        moveback(drone,'distance',0.2,'Speed',0.1);
        r=r+1;
        fprintf(" r의 값은 %d",r)
        pause(1);      
    elseif (sum(img_hsv_red,'all') < 4000)       
        fprintf('\n표적 너무 멈')
        moveforward(drone,'distance',0.2,'Speed',0.1);
        r=r+1;
        fprintf(' r의 값은 %d',r)
        pause(1);   
    end
end
    
    fprintf('r = %d',r)

    %%파란색 사각형 내부 원의 중점 찾기

  e_b=0;
  back=0;
  no_circle=1;
  escape2=0;
  back_ct=0;
  
  while (e_b==0)

    frame=snapshot(cam);
    img_rgb = frame; % 이미지를 불러옵니다.
       
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_s = img_hsv(:,:,2); % S   채널

    img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

    %드론의 중점좌표
    mySize = size(img_rgb);
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;

    pause(1);
    
    %img_hsv_blue 2진화 이미지 생성    
    for i = 1: size(img_hsv_blue, 1)
        for j = 1:size(img_hsv_blue, 2)
            if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란 hsv조정
                img_hsv_blue(i, j) = 1;
            end
        end
    end


    blue_pixel = sum(img_hsv_blue,"all"); %파란 사각형의 픽셀의 수

    filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
    [m, n] = size(filled_image);  % filled_image의 크기 확인
    
    pause(1);

    circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
     % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end
 
      fprintf('sum(circle_image,"all")=%d\n',sum(circle_image,"all"))  %circle_image = 파란색 사각형의 내부의 원의 픽셀의 수
      fprintf('sum(img_hsv_blue,"all")=%d\n',sum(img_hsv_blue,"all"))  %circle_image = 파란색 사각형의 픽셀의 수
     
       imshow(img_hsv_blue)
       imshow(circle_image)

      % 1.원이 모두 다 보일 경우 
      if   (sum(circle_image,"all") >=130000)  
           fprintf('원이 잘보입니다!!x\n') 

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출
            imshow(circle_image)
            plot(centroids(:,1),centroids(:,2),'r*') %원의 중점 표시
            plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론이 보는 화면의 중점 표시
            hold off
        
        %드론의 x좌표와 원의 x좌표 맞추기    
            ct=0;
        while (ct>5 || ((center_drone_x + 20 > cir_x) && (center_drone_x -20 < cir_x))==0)     
             frame=snapshot(cam);
            img_rgb = frame; % 이미지를 불러옵니다.
       
            img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

            img_hsv_h = img_hsv(:,:,1); % Hue 채널
            img_hsv_s = img_hsv(:,:,2); % S   채널

            img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

            %드론의 중점좌표
            mySize = size(img_rgb);
            a = mySize(:,1);
            b = mySize(:,2);
    
            center_drone_x = b / 2;
            center_drone_y = a / 2;
    
            %img_hsv_blue 2진화 이미지 생성    
            for i = 1: size(img_hsv_blue, 
                for j = 1:size(img_hsv_blue, 2)
                    if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란색 hsv조정
                        img_hsv_blue(i, j) = 1;
                    end
                end
            end
    
            filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
            [m, n] = size(filled_image);  % filled_image의 크기 확인

            circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
            % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출
                    
            %드론의 중점을 원의 중점에 위치
            if (center_drone_x > cir_x)
                fprintf('왼쪽으로 ㄱㄱ')
                disp(center_drone_x - cir_x)
                moveleft(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);
            elseif(center_drone_x < cir_x)
                fprintf('\n오른쪽으로 ㄱㄱ')
                disp(center_drone_x - cir_x)
                moveright(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);    
            end
        end  
        
        fprintf('\nx축 일치\n')
            
        %드론의 중심y좌표와 원의 중심y좌표 맞추기 
            ct=0;
        while (ct>5 || ((center_drone_y + 20 > cir_y) && (center_drone_y -20 < cir_y))==0)  
            
             frame=snapshot(cam);
            img_rgb = frame; % 이미지를 불러옵니다.
       
            img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

            img_hsv_h = img_hsv(:,:,1); % Hue 채널
            img_hsv_s = img_hsv(:,:,2); % S   채널

            img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

            %드론의 중점좌표
            mySize = size(img_rgb);
            a = mySize(:,1);
            b = mySize(:,2);
    
            center_drone_x = b / 2;
            center_drone_y = a / 2;
    
            %img_hsv_blue 2진화 이미지 생성    
            for i = 1: size(img_hsv_blue, 
                for j = 1:size(img_hsv_blue, 2)
                    if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란색 hsv조정
                        img_hsv_blue(i, j) = 1;
                    end
                end
            end
    
            filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
            [m, n] = size(filled_image);  % filled_image의 크기 확인

            circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
            % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출                    
            
            if (center_drone_y+20 < cir_y)
                fprintf('\n아래쪽으로 ㄱㄱ')
                disp(center_drone_y - cir_y)
                movedown(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);
            elseif(center_drone_y-20 > cir_y)
                fprintf('\n위쪽으로 ㄱㄱ')
                disp(center_drone_y - cir_y)
                moveup(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);                
            end
        end
            fprintf('\ny축 일치\n')

            if back>=1
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               moveforward(drone,'distance',back*0.4,'Speed',0.1);
               pause(1); 
               e_b=1;
            else
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               e_b=1; % while탈출 => 원의 중점과 드론의 중점 일치
            end  
        
        
    % 2.원이 부분보일 때 - circle_image가 너무 작거나 제대로 인식x  ===>임계값 설정필요
    elseif  sum(circle_image,"all") < 130000             
       
        % 2(1):멀리있는 경우
        if  sum(img_hsv_blue,"all") < 200000 
            left_side = sum(imcrop(img_hsv_blue,[0 0 center_drone_x center_drone_y*2]),'all');
            right_side = sum(imcrop(img_hsv_blue,[center_drone_x 0 center_drone_x center_drone_y*2]),'all');
            up_side = sum(imcrop(img_hsv_blue,[0 0 center_drone_x*2 center_drone_y]),'all');
            down_side = sum(imcrop(img_hsv_blue,[0 360 center_drone_x*2 center_drone_y*2]),'all');

            diff_lr=left_side-right_side;
            diff_ud=up_side-down_side;
         
            fprintf('diff_lr = %d  diff_ud = %d\n',diff_lr, diff_ud)

            if(diff_lr>80000) %좌우비교 ==> 임계값 설정 필요
                fprintf('왼쪽으로 0.3m이동\n')
                moveleft(drone,'Distance',0.3,'Speed',0.1);
                pause(2); 
            elseif(diff_lr<-80000)
                fprintf('오른쪽으로 0.3m이동\n')
                moveright(drone,'Distance',0.3,'Speed',0.1);
                pause(2);              
            end
            fprintf('좌우이동정지\n')
            escape2=escape2+1;
         
            if(diff_ud>70000) %상하비교 ==> 임계값 설정 필요
                fprintf('위쪽으로 0.2m이동\n')
                moveup(drone,'Distance',0.2,'Speed',0.1);
                pause(2); 
            elseif(diff_ud<-70000)
                fprintf('아래쪽으로 0.2m이동\n')
                movedown(drone,'Distance',0.2,'Speed',0.1);
                pause(2); 
            end
            fprintf('상하이동정지\n')
            escape2=escape2+1;

         
            %좌우상하의 픽셀값이 거의 엇비슷한데 원이 안나타나는 경우
         if escape2>=12                   
            moveforward(drone,'distance',0.8,'Speed',0.1);
            pause(1);
            moveforward(drone,'distance',0.7,'Speed',0.1);
            pause(1);
            eb_1=1;
            if back>=1
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               moveforward(drone,'distance',back*0.4,'Speed',0.1);
               pause(1); 
               eb_1=1;
            end
         end   
         
         
        % 2(2):가까이 있는 경우 
        elseif sum(img_hsv_blue,"all") > 200000 
                moveback(drone,'Distance',0.2,'Speed',0.1);
                back=back+1;
                pause(2); 
        end

       % 3.원이 보이지 않은경우
      elseif blue_pixel < 800   
            fprintf('blue_pixel=%d\n',blue_pixel)
            fprintf('원이 보이지 않는다\n')
        
            if back_ct <2 %먼저 뒤로 이동
                moveback(drone,'Distance',0.3,'Speed',0.1);             
                back=back+1; %전체 back횟수
                back_ct=back_ct+1; %원이 보이지 않을 때 back횟수
                pause(1);
            elseif back_ct==2 && mod(no_circle,2)==1
                fprintf('오른쪽으로 (0.3*no_circle)m이동\n')
                moveright(drone,'Distance',0.2*no_circle,'Speed',0.3)
                no_circle=no_circle+1;
                fprintf('no_circle=%d\n',no_circle)
                pause(2);
            elseif back_ct==2 && mod(no_circle,2)==0
                fprintf('왼쪽으로 (0.3*no_circle)m이동\n')
                moveleft(drone,'Distance',0.2*no_circle,'Speed',0.3)
                no_circle=no_circle+1;
                fprintf('no_circle=%d\n',no_circle)
                pause(2);
            end     
      end
  end

   frame=snapshot(cam);
 
    img_rgb = frame; % 이미지를 불러옵니다.
   
    %드론의 중심좌표
    mySize = size(img_rgb);
    
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;
    
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1);% Hue 채널
    img_hsv_s = img_hsv(:,:,2);% Hue 채널
   
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.01 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)   %%%%%%%%빨강이HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off

    r = 0;
    x = 0;
    y = 0;

  %드론의 X좌표와 빨간색 표적의 X좌표 맞추기 
  while ((x>3) || ((center_drone_x + 15 > red_x) && (center_drone_x -15 < red_x)))==0
    
    frame=snapshot(cam);
      
    img_rgb = frame; % 이미지를 불러옵니다.
   
    %드론의 중심좌표
    mySize = size(img_rgb);
    
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;
    
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_S = img_hsv(:,:,2); % S   채널
    
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.02 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)  %%%%%%%%빨강이HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off      
            
      if (center_drone_x > red_x)
        fprintf('\n왼쪽으로 ㄱㄱ')
        disp(center_drone_x - red_x)
        moveleft(drone,'distance',0.2,'Speed',0.2);
        x=x+1;
        fprintf(' x의 값은 %d\n',x)
        pause(1);
     elseif(center_drone_x < red_x)
        fprintf('\n오른쪽으로 ㄱㄱ')
        moveright(drone,'distance',0.2,'Speed',0.1);
        disp(center_drone_x - red_x)
        x=x+1;
        pause(1);
        fprintf(" x의 값은 %d\n",x)          
     end
  end

  fprintf('\nx축 일치\n')
  fprintf('x = %d',x)


  %드론의 y좌표와 빨간색 표적의 y좌표 맞추기
  while ((y>3) || ((center_drone_y + 20 > red_y) && (center_drone_y -20 < red_y)))==0
    
    frame=snapshot(cam);   
    img_rgb = frame; % 이미지를 불러옵니다.
   
    %드론의 중심좌표
    mySize = size(img_rgb);
    
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;
    
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_s = img_hsv(:,:,2); % S   채널
   
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.02 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)  %%%%%%%%%% 빨강HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off      
      
     if (center_drone_y < red_y)
        fprintf('\n아래쪽으로 ㄱㄱ')
        movedown(drone,'distance',0.2,'Speed',0.1);
        disp(center_drone_y - red_y)
        y=y+1;
        fprintf(' y의 값은 %d\n',y)
        pause(1);
    elseif(center_drone_y > red_y)
        fprintf('\n위쪽으로 ㄱㄱ')
        moveup(drone,'distance',0.2,'Speed',0.1);
        disp(center_drone_y - red_y)
        y=y+1;
        fprintf(' y의 값은 %d\n',y)
        pause(1);
      
    end
  end
   
  fprintf('\ny축 일치\n')
  fprintf('y = %d',y)
  

while ((r>5)==0)
    
    frame=snapshot(cam);
    img_rgb = frame; % 이미지를 불러옵니다.

    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_s = img_hsv(:,:,2); % S   채널
   
    img_hsv_red = double(zeros(size(img_hsv_h))); 

    for i = 1: size(img_hsv_red, 1)
        for j = 1:size(img_hsv_red, 2)
             if (img_hsv_h(i, j) > 0.097 && img_hsv_h(i, j) < 1 && img_hsv_h(i, j) < 0.02 && img_hsv_h(i, j) >0 ) && (img_hsv_s(i, j) > 0.76 && img_hsv_s(i, j) < 0.84)   %%%%%빨강이 HSV
                img_hsv_red(i, j) = 1;
            end
        end
    end

    % 표적 출력
    imshow(img_hsv_red)   
    hold on;

    s=regionprops(img_hsv_red,'centroid'); %표적의 중점찾기
    centroids=cat(1,s.Centroid);
    red_x = centroids(:, 1); % x좌표 추출
    red_y = centroids(:, 2); % y좌표 추출

    plot(centroids(:,1),centroids(:,2),'r*') %표적 중점 표시
    plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론중점표시
    hold off
    
    fprintf('\n빨간색 임계값:%d',sum(img_hsv_red,'all'))

    if (sum(img_hsv_red,'all') >= 4000) && (sum(img_hsv_red,'all') <= 9000) %임계값 설정
        fprintf('\n표적 발견')
        turn(drone,deg2rad(90));
        r=r+5;
        fprintf(' r의 값은 %d',r)
        pause(1);
    elseif (sum(img_hsv_red,'all') > 9000)       
        fprintf('\n표적 너무 가까움')
        moveback(drone,'distance',0.2,'Speed',0.1);
        r=r+1;
        fprintf(" r의 값은 %d",r)
        pause(1);      
    elseif (sum(img_hsv_red,'all') < 4000)       
        fprintf('\n표적 너무 멈')
        moveforward(drone,'distance',0.2,'Speed',0.1);
        r=r+1;
        fprintf(' r의 값은 %d',r)
        pause(1);   
    end
end
    
    fprintf('r = %d',r)

    %%파란색 사각형 내부 원의 중점 찾기

  e_b=0;
  back=0;
  no_circle=1;
  escape2=0;
  back_ct=0;
  
  while (e_b==0)

    frame=snapshot(cam);
    img_rgb = frame; % 이미지를 불러옵니다.
       
    img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

    img_hsv_h = img_hsv(:,:,1); % Hue 채널
    img_hsv_s = img_hsv(:,:,2); % S   채널

    img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

    %드론의 중점좌표
    mySize = size(img_rgb);
    a = mySize(:,1);
    b = mySize(:,2);
    
    center_drone_x = b / 2;
    center_drone_y = a / 2;

    pause(1);
    
    %img_hsv_blue 2진화 이미지 생성    
    for i = 1: size(img_hsv_blue, 1)
        for j = 1:size(img_hsv_blue, 2)
            if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란 hsv조정
                img_hsv_blue(i, j) = 1;
            end
        end
    end


    blue_pixel = sum(img_hsv_blue,"all"); %파란 사각형의 픽셀의 수

    filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
    [m, n] = size(filled_image);  % filled_image의 크기 확인
    
    pause(1);

    circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
     % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end
 
      fprintf('sum(circle_image,"all")=%d\n',sum(circle_image,"all"))  %circle_image = 파란색 사각형의 내부의 원의 픽셀의 수
      fprintf('sum(img_hsv_blue,"all")=%d\n',sum(img_hsv_blue,"all"))  %circle_image = 파란색 사각형의 픽셀의 수
     
       imshow(img_hsv_blue)
       imshow(circle_image)

      % 1.원이 모두 다 보일 경우 
      if   (sum(circle_image,"all") >=130000)  
           fprintf('원이 잘보입니다!!x\n') 

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출
            imshow(circle_image)
            plot(centroids(:,1),centroids(:,2),'r*') %원의 중점 표시
            plot(center_drone_x, center_drone_y, 'MarkerSize', 10, 'Marker', 'o') %드론이 보는 화면의 중점 표시
            hold off
        
        %드론의 x좌표와 원의 x좌표 맞추기    
            ct=0;
        while (ct>5 || ((center_drone_x + 20 > cir_x) && (center_drone_x -20 < cir_x))==0)     
             frame=snapshot(cam);
            img_rgb = frame; % 이미지를 불러옵니다.
       
            img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

            img_hsv_h = img_hsv(:,:,1); % Hue 채널
            img_hsv_s = img_hsv(:,:,2); % S   채널

            img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

            %드론의 중점좌표
            mySize = size(img_rgb);
            a = mySize(:,1);
            b = mySize(:,2);
    
            center_drone_x = b / 2;
            center_drone_y = a / 2;
    
            %img_hsv_blue 2진화 이미지 생성    
            for i = 1: size(img_hsv_blue, 
                for j = 1:size(img_hsv_blue, 2)
                    if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란색 hsv조정
                        img_hsv_blue(i, j) = 1;
                    end
                end
            end
    
            filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
            [m, n] = size(filled_image);  % filled_image의 크기 확인

            circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
            % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출
                    
            %드론의 중점을 원의 중점에 위치
            if (center_drone_x > cir_x)
                fprintf('왼쪽으로 ㄱㄱ')
                disp(center_drone_x - cir_x)
                moveleft(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);
            elseif(center_drone_x < cir_x)
                fprintf('\n오른쪽으로 ㄱㄱ')
                disp(center_drone_x - cir_x)
                moveright(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);    
            end
        end  
        
        fprintf('\nx축 일치\n')
            
        %드론의 중심y좌표와 원의 중심y좌표 맞추기 
            ct=0;
        while (ct>5 || ((center_drone_y + 20 > cir_y) && (center_drone_y -20 < cir_y))==0)  
            
             frame=snapshot(cam);
            img_rgb = frame; % 이미지를 불러옵니다.
       
            img_hsv = rgb2hsv(img_rgb); % RGB 이미지를 HSV 이미지로 전환

            img_hsv_h = img_hsv(:,:,1); % Hue 채널
            img_hsv_s = img_hsv(:,:,2); % S   채널

            img_hsv_blue = double(zeros(size(img_hsv_h))); %img_hsv_blue배열 생성

            %드론의 중점좌표
            mySize = size(img_rgb);
            a = mySize(:,1);
            b = mySize(:,2);
    
            center_drone_x = b / 2;
            center_drone_y = a / 2;
    
            %img_hsv_blue 2진화 이미지 생성    
            for i = 1: size(img_hsv_blue, 
                for j = 1:size(img_hsv_blue, 2)
                    if (img_hsv_h(i, j) > 0.577 && img_hsv_h(i, j) < 0.598) && (img_hsv_s(i, j) > 0.728 && img_hsv_s(i, j) < 0.832) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 파란색 hsv조정
                        img_hsv_blue(i, j) = 1;
                    end
                end
            end
    
            filled_image = imfill(img_hsv_blue, 'holes'); %사각형 내부 원이 보인다면 원을 채움
    
            [m, n] = size(filled_image);  % filled_image의 크기 확인

            circle_image = zeros(m, n); % 비교 결과를 담을 행렬 circle_image 행렬생성
   
            % 요소 비교 및 결과 할당 = 파란색 사각형의 내부의 원 생성
            for i = 1:m
                for j = 1:n
                    if filled_image(i, j) == img_hsv_blue(i, j)
                        circle_image(i, j) = 0;
                    else
                        circle_image(i, j) = 1;
                    end
                end
            end

            s=regionprops(circle_image,'centroid'); % 원의 중점을 찾기
            centroids=cat(1,s.Centroid);
            cir_x = centroids(:, 1); % x좌표 추출
            cir_y = centroids(:, 2); % y좌표 추출                    
            
            if (center_drone_y+20 < cir_y)
                fprintf('\n아래쪽으로 ㄱㄱ')
                disp(center_drone_y - cir_y)
                movedown(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);
            elseif(center_drone_y-20 > cir_y)
                fprintf('\n위쪽으로 ㄱㄱ')
                disp(center_drone_y - cir_y)
                moveup(drone,'distance',0.2,'Speed',0.1);
                ct=ct+1;
                pause(2);                
            end
        end
            fprintf('\ny축 일치\n')

            if back>=1
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               moveforward(drone,'distance',back*0.4,'Speed',0.1);
               pause(1); 
               e_b=1;
            else
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               e_b=1; % while탈출 => 원의 중점과 드론의 중점 일치
            end  
        
        
    % 2.원이 부분보일 때 - circle_image가 너무 작거나 제대로 인식x  ===>임계값 설정필요
    elseif  sum(circle_image,"all") < 130000             
       
        % 2(1):멀리있는 경우
        if  sum(img_hsv_blue,"all") < 200000 
            left_side = sum(imcrop(img_hsv_blue,[0 0 center_drone_x center_drone_y*2]),'all');
            right_side = sum(imcrop(img_hsv_blue,[center_drone_x 0 center_drone_x center_drone_y*2]),'all');
            up_side = sum(imcrop(img_hsv_blue,[0 0 center_drone_x*2 center_drone_y]),'all');
            down_side = sum(imcrop(img_hsv_blue,[0 360 center_drone_x*2 center_drone_y*2]),'all');

            diff_lr=left_side-right_side;
            diff_ud=up_side-down_side;
         
            fprintf('diff_lr = %d  diff_ud = %d\n',diff_lr, diff_ud)

            if(diff_lr>80000) %좌우비교 ==> 임계값 설정 필요
                fprintf('왼쪽으로 0.3m이동\n')
                moveleft(drone,'Distance',0.3,'Speed',0.1);
                pause(2); 
            elseif(diff_lr<-80000)
                fprintf('오른쪽으로 0.3m이동\n')
                moveright(drone,'Distance',0.3,'Speed',0.1);
                pause(2);              
            end
            fprintf('좌우이동정지\n')
            escape2=escape2+1;
         
            if(diff_ud>70000) %상하비교 ==> 임계값 설정 필요
                fprintf('위쪽으로 0.2m이동\n')
                moveup(drone,'Distance',0.2,'Speed',0.1);
                pause(2); 
            elseif(diff_ud<-70000)
                fprintf('아래쪽으로 0.2m이동\n')
                movedown(drone,'Distance',0.2,'Speed',0.1);
                pause(2); 
            end
            fprintf('상하이동정지\n')
            escape2=escape2+1;

         
            %좌우상하의 픽셀값이 거의 엇비슷한데 원이 안나타나는 경우
         if escape2>=12                   
            moveforward(drone,'distance',0.8,'Speed',0.1);
            pause(1);
            moveforward(drone,'distance',0.7,'Speed',0.1);
            pause(1);
            eb_1=1;
            if back>=1
               moveforward(drone,'distance',0.8,'Speed',0.1);
               pause(1);
               moveforward(drone,'distance',0.7,'Speed',0.1);
               pause(1); 
               moveforward(drone,'distance',back*0.4,'Speed',0.1);
               pause(1); 
               eb_1=1;
            end
         end   
         
         
        % 2(2):가까이 있는 경우 
        elseif sum(img_hsv_blue,"all") > 200000 
                moveback(drone,'Distance',0.2,'Speed',0.1);
                back=back+1;
                pause(2); 
        end

       % 3.원이 보이지 않은경우
      elseif blue_pixel < 800   
            fprintf('blue_pixel=%d\n',blue_pixel)
            fprintf('원이 보이지 않는다\n')
        
            if back_ct <2 %먼저 뒤로 이동
                moveback(drone,'Distance',0.3,'Speed',0.1);             
                back=back+1; %전체 back횟수
                back_ct=back_ct+1; %원이 보이지 않을 때 back횟수
                pause(1);
            elseif back_ct==2 && mod(no_circle,2)==1
                fprintf('오른쪽으로 (0.3*no_circle)m이동\n')
                moveright(drone,'Distance',0.2*no_circle,'Speed',0.3)
                no_circle=no_circle+1;
                fprintf('no_circle=%d\n',no_circle)
                pause(2);
            elseif back_ct==2 && mod(no_circle,2)==0
                fprintf('왼쪽으로 (0.3*no_circle)m이동\n')
                moveleft(drone,'Distance',0.2*no_circle,'Speed',0.3)
                no_circle=no_circle+1;
                fprintf('no_circle=%d\n',no_circle)
                pause(2);
            end     
      end
  end

  land(drone);
