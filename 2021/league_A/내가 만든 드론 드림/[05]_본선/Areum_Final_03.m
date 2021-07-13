% src = imread('Validation.png');
% src_hsv = rgb2hsv(src);

% 드론 객체 선언, 카메라 키기
clear()
droneObj = ryze();
cameraObj = camera(droneObj);
takeoff(droneObj);


% v = VideoReader('tmp.mp4');


thdown_blue = [0.5, 0.35, 0.25];        % 파란색 임계값 범위
thup_blue = [0.75, 240/240, 240/240];
thdown_red = [0.0, 40/240, 65/240];     % 빨간색 점의 임계값 범위
thup_red = [0.0, 240/240, 240/240];
thdown_purple = [0.25, 35/240, 45/240]; % 보라색 점의 임계값 범위
thup_purple = [0.3, 240/240, 240/240];
tmp = 0;
while 1
    tmp=tmp+1;
    src = snapshot(cameraObj);
%     src = imread('./datasets/test03.jpg');
    src_hsv = rgb2hsv(src);
%     imshow(src);
    
    dst_hsv1 = double(zeros(size(src_hsv)));
    dst_hsv2 = double(zeros(size(src_hsv)));
    [rows, cols, channels] = size(src_hsv);

    fir = 0; sec = 0; thi = 0; fou = 0;
    isRed = 0; isPurple = 0;
    cnt_red = 0; cnt_purple = 0;
    for row = 1:rows
        for col = 1:cols
            if thdown_blue(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_blue(1) ...
            && thdown_blue(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_blue(2) ...
            && thdown_blue(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_blue(3)
                dst_hsv1(row, col, :) = [0, 0, 1];   % White
                dst_hsv2(row, col, :) = [0, 0, 0];   % Black
                
                if (row < rows/2) && (col > cols/2)
                    fir = fir+1;
                elseif (row < rows/2) && (col < cols/2)
                    sec = sec+1;
                elseif (row > rows/2) && (col < cols/2)
                    thi = thi+1;
                elseif (row > rows/2) && (col > cols/2)
                    fou = fou+1;
                end
            else
                dst_hsv1(row, col, :) = [0, 0, 0];   % Black
                dst_hsv2(row, col, :) = [0, 0, 1];   % White
            end
            
            if thdown_red(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_red(1) ...
            && thdown_red(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_red(2) ...
            && thdown_red(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_red(3)
                isRed = 1;      % 빨강 표식 발견
                cnt_red = cnt_red + 1;  % 빨강 표식 픽셀 수 세기
            elseif thdown_purple(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_purple(1) ...
            && thdown_purple(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_purple(2) ...
            && thdown_purple(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_purple(3)
                isPurple = 1;   % 보라 표식 발견
                cnt_purple = cnt_purple + 1;    % 보라 표식 픽셀 수 세기
            end
        
        end
    end
    
    inCam = 1;
    % 링이 카메라에 잘렸을 경우
    A = [fir, sec, thi, fou];
    m = max(A);
    if ((m == fir) && (sec==0 && thi==0 && fou==0))    % 1사분면에 있는 초록색의 픽셀 개수가 max
       disp('1 사분면 검출');
       inCam = 0;
       moveright(droneObj, 'distance', 0.5)
       moveup(droneObj, 'distance', 0.5)
    end
    if ((m == sec) && (fir==0 && thi==0 && fou==0))    % 2사분면에 있는 초록색의 픽셀 개수가 max
       disp('2 사분면 검출');
       inCam = 0;
       moveleft(droneObj, 'distance', 0.5)
       moveup(droneObj, 'distance', 0.5)
    end
    if ((m == thi) && (fir==0 && sec==0 && fou==0))    % 3사분면에 있는 초록색의 픽셀 개수가 max
       disp('3 사분면 검출');
       inCam = 0;
       moveleft(droneObj, 'distance', 0.5)
       movedown(droneObj, 'distance', 0.5)
    end
    if ((m == fou) && (fir==0 && sec==0 && thi==0))    % 4사분면에 있는 초록색의 픽셀 개수가 max
       disp('4 사분면 검출');
       inCam = 0;
       moveright(droneObj, 'distance', 0.5)
       movedown(droneObj, 'distance', 0.5)
    end
    
    if isequal(inCam, 1)    % 동그라미가 카메라 안에 있을 경우에만 실행
        try
            disp('원 발견 -원의 중점 찾기');
            thres_dst1 = hsv2rgb(dst_hsv1);
            thres_dst2 = hsv2rgb(dst_hsv2);
            gray_thres_dst1 = rgb2gray(thres_dst1);
            count_pixel = 0;
            center_row = 0;
            center_col = 0;

            corners1 = pgonCorners(gray_thres_dst1, 4);

            roix = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];    % ROI 범위 소량 확장
            roiy = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];    % ROI 범위 소량 확장
            roi = roipoly(thres_dst1, roix, roiy);
            thres_dst = thres_dst2 .* roi;
            gray_thres_dst = rgb2gray(thres_dst);

            for row = 1:rows
                for col = 1:cols
                    if gray_thres_dst(row, col) == 1
                        count_pixel = count_pixel + 1;
                        center_row = center_row + row;
                        center_col = center_col + col;    
                    end        
                end
            end
            center_row = center_row / count_pixel;
            center_col = center_col / count_pixel;

            dif_x = cols/2 - center_col
            dif_y = rows/2 - center_row    % 카메라 중점 - 원의 중점
            go = 0;

            if((dif_x <= -50 || dif_x >= 50) && (dif_y <= -40 || dif_y >= 40))     % 중점의 오차범위가 40 내외가 될 때까지 반복 (값 정확 X)
                disp('중심 맞추기');
                if dif_x <= -300
                    moveright(droneObj, 'distance', 0.3)
                elseif dif_x <= -150
                    moveright(droneObj, 'distance', 0.25)
                elseif dif_x <= 0
                    moveright(droneObj, 'distance', 0.2)
                elseif dif_x <= 150
                    moveleft(droneObj, 'distance', 0.2)
                elseif dif_x <= 300
                    moveleft(droneObj, 'distance', 0.25)
                else
                    moveleft(droneObj, 'distance', 0.3)
                end

                if dif_y <= -300
                    movedown(droneObj, 'distance', 0.5)
                elseif dif_y <= -150
                    movedown(droneObj, 'distance', 0.4)
                elseif dif_y <= 0
                    movedown(droneObj, 'distance', 0.35)
                elseif dif_y <= 150
                    moveup(droneObj, 'distance', 0.2)
                elseif dif_y <= 300
                    moveup(droneObj, 'distance', 0.2)
                else
                    moveup(droneObj, 'distance', 0.25)
                end
            else
                go = 1;
            end
            if go == 1
%                 movedown(droneObj, 'distance', 0.4)
                moveforward(droneObj, 'distance', 2)
                land(droneObj)
                break
            end
            
%             disp('앞으로 전진');
%             if(cnt_red <= 20 || cnt_purple <= 20)       % 해당 픽셀 수가 특정 값일 때 앞으로 이동 (값 정확 X)
%                 moveforward(droneObj, 'distance', 1)
%             elseif(cnt_red <= 40 || cnt_purple <= 40)
%                 moveforward(droneObj, 'distance', 0.5)
%             end
            
%             if isequal(isRed, 1)    % 표식이 빨간색이라면 90도 좌회전
%                 turn(droneObj, deg2rad(-90))
%             elseif isequal(isPurple, 1)     % 표식이 보라색이라면 착륙
%                 land(droneObj)
%                 break;
%             end
            
        catch exception
            disp('error-Trying to find the circle...');
             if (thi==0 && fou==0)
               moveup(droneObj, 'distance', 0.3)
            elseif (fir==0 && sec==0)
               movedown(droneObj, 'distacne', 0.3)
             elseif (sec==0 && thi==0)
               moveright(droneObj, 'distance', 0.3)
             elseif (fir==0 && fou==0)
               moveleft(droneObj, 'distance', 0.3)
            end
        end
    end
    
    subplot(2, 2, 1), imshow(src); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    subplot(2, 2, 2), imshow(gray_thres_dst); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    subplot(2, 2, 3), imshow(dst_hsv1);
    subplot(2, 2, 4), imshow(dst_hsv2);
%     saveas(fig,'tmp.png')
    
    if tmp >= 10
        land(droneObj)
        break
    end
end



%%%%%%%%%%%%%%%%%%%%%%%함수%%%%%%%%%%%%%%%%%%%
function corners = pgonCorners(BW,k,N)
   if nargin<3, N=360; end
  
    theta=linspace(0,360,N+1); theta(end)=[];
    IJ=bwboundaries(BW);
    IJ=IJ{1};
    centroid=mean(IJ);
    IJ=IJ-centroid;
    
    c=nan(size(theta));
    
    for i=1:N
        [~,c(i)]=max(IJ*[cosd(theta(i));sind(theta(i))]);
    end
    
    Ih=IJ(c,1); Jh=IJ(c,2);
    
    [H,~,~,binX,binY]=histcounts2(Ih,Jh,k);
     bin=sub2ind([k,k],binX,binY);
    
    [~,binmax] = maxk(H(:),k);
    
    [tf,loc]=ismember(bin,binmax);
    
    IJh=[Ih(tf), Jh(tf)];
    G=loc(tf);
    
    C=splitapply(@(z)mean(z,1),IJh,G);
    
    [~,perm]=sort( cart2pol(C(:,2),C(:,1)),'descend' );
    
    corners=C(perm,:)+centroid;
end
