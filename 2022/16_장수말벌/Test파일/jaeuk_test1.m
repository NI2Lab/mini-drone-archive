src = imread("문제2.png");

src_hsv = rgb2hsv(src);
thdown_green = [0.25, 40/240, 80/240];         % 임계값 설정.
thup_green = [0.40, 240/240, 240/240];

[rows, cols, channels] = size(src_hsv);        % 이미지의 가로,세로 픽셀 수 저장
dst_hsv1 = double(zeros(size(src_hsv)));       % 검정 이미지 생성
dst_hsv2 = double(zeros(size(src_hsv)));
dst_h = dst_hsv1(:, :, 1);
dst_s = dst_hsv1(:, :, 2);
dst_v = dst_hsv1(:, :, 3);

%cnt_rows=0; cnt_cols=0;
%sum_rows=0; sum_cols=0;
    
for row = 1:rows
    for col = 1:cols
        if thdown_green(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_green(1) ...
                && thdown_green(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_green(2) ...
                && thdown_green(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_green(3)
            dst_hsv1(row, col, :) = [0, 0, 1];
        else
            dst_hsv2(row, col, :) = [0, 0, 1];
        end
    end
end
    
dst_rgb1 = hsv2rgb(dst_hsv1);
dst_rgb2 = hsv2rgb(dst_hsv2);

dst_gray1 = rgb2gray(dst_rgb1);
dst_gray = edge(dst_gray1,'Canny');
%figure,imshow(dst_gray)
corners1 = pgonCorners(dst_gray, 4);       % 바깥사각형 코너 좌표 검출

p1 = corners1(4, :);         % 좌상단
p2 = corners1(3, :);         % 우상단
p3 = corners1(1, :);         % 좌하단
p4 = corners1(2, :);         % 우하단

roi_x = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];  % roi범위 소량 확장
roi_y = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];  % roi범위 소량 확장
roi = roipoly(dst_gray1, roi_x, roi_y);         % 코너 좌표만큼 안쪽 이미지 roi

dst_img = dst_rgb2 .* roi;       
dst_gray = rgb2gray(dst_img);

count_pixel = 0;
center_row = 0;
center_col = 0;
for row = 1:rows                                
    for col = 1:cols
        if dst_gray(row, col) == 1          
            count_pixel = count_pixel + 1;      %검출될때마다 픽셀수 세기
            center_row = center_row + row;      %검출될때마다 가로좌표 더하기
            center_col = center_col + col;      %검출될때마다 세로좌표 더하기
        end        
    end
end

center_row = center_row / count_pixel;
center_col = center_col / count_pixel;
    
answer = [center_col, center_row]          % 센터좌표 검출

subplot(2, 3, 1); imshow(src);
subplot(2, 3, 2); imshow(dst_rgb1);
subplot(2, 3, 3); imshow(dst_rgb2);
subplot(2, 3, 4); imshow(dst_img);
subplot(2, 3, 5); imshow(dst_gray1); hold on;
plot(center_col, center_row, 'r*'); hold off;
subplot(2, 3, 6); imshow(src); hold on;
plot(center_col, center_row, 'r*'); hold off;

% Result
%imshow(src);
%hold on;
%plot(p1(2), p1(1), 'ro');   % 좌상단
%plot(p2(2), p2(1), 'go');   % 우상단
%plot(p3(2), p3(1), 'bo');   % 좌하단
%plot(p4(2), p4(1), 'yo');   % 우하단
%plot([p1(2), p4(2)], [p1(1), p4(1)], 'LineWidth', 2);
%plot([p2(2), p3(2)], [p2(1), p3(1)], 'LineWidth', 2);
%plot(anser(1), anser(2), 'r*');   % 중심좌표
%hold off;





function corners = pgonCorners(BW,k,N)
%Method of detecting the corners in a binary image of a convex polygon with 
%a known number of vertices. Uses a linear programming approach.
%
%   corners = pgonCorners(BW,k)
%   corners = pgonCorners(BW,k,N)
%             
%IN:          
%             
%    BW: Input binary image    
%     k: Number of vertices to search for.     
%     N: Number of angular samples partitioning the unit circle (default=360).
%        Affects the resolution of the search.
%             
%OUT:         
%             
%   corners: Detected corners in counter-clockwise order as a k x 2 matrix.
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
