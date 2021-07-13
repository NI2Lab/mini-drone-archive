% src = imread('Validation.png');
% src_hsv = rgb2hsv(src);

% 드론 객체 선언, 카메라 키기
% droneObj = ryze()
% cameraObj = camera(droneObj);

%%%%%%%%%조건을 넣어서 동그라미 검출이 되었을 때 중점 구하기 // 바깥 while문을 무한반복문으로.. 완전히 이동시킨 후에
%%%%%%%%%사진을 다시 찍어서 검색

v = VideoReader('tmp.mp4');
while hasFrame(v)
    src = readFrame(v);
    src_hsv = rgb2hsv(src);
    thdown_green = [0.25, 40/240, 80/240];
    thup_green = [0.40, 240/240, 240/240];   % 나중에 blue로 바꿔야 함.
    imshow(src);
    
    dst_hsv1 = double(zeros(size(src_hsv)));
    dst_hsv2 = double(zeros(size(src_hsv)));
    [rows, cols, channels] = size(src_hsv);

    fir = 0; sec = 0; thi = 0; fou = 0;
    for row = 1:rows
        for col = 1:cols
            if thdown_green(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_green(1) ...
            && thdown_green(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_green(2) ...
            && thdown_green(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_green(3)
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
        end
    end
    
    % 링이 카메라에 잘렸을 경우
    A = [fir, sec, thi, fou]
    m = max(A);
    while ((m == fir) && (sec==0 && thi==0 && fou==0))    % 1사분면에 있는 초록색의 픽셀 개수가 max
       moveright(droneObj, 'distance', 0.3)
       moveup(droneObj, 'distance', 0.3)
    end
    while ((m == sec) && (fir==0 && thi==0 && fou==0))    % 2사분면에 있는 초록색의 픽셀 개수가 max
       moveleft(droneObj, 'distance', 0.3)
       moveup(droneObj, 'distance', 0.3)
    end
    while ((m == thi) && (fir==0 && sec==0 && fou==0))    % 3사분면에 있는 초록색의 픽셀 개수가 max
       moveleft(droneObj, 'distance', 0.3)
       movedown(droneObj, 'distance', 0.3)
    end
    while ((m == fou) && (fir==0 && sec==0 && thi==0))    % 4사분면에 있는 초록색의 픽셀 개수가 max
       moveright(droneObj, 'distance', 0.3)
       movedown(droneObj, 'distance', 0.3)
    end
    
    thres_dst1 = hsv2rgb(dst_hsv1);
    thres_dst2 = hsv2rgb(dst_hsv2);
    gray_thres_dst1 = rgb2gray(thres_dst1);

    corners1 = pgonCorners(gray_thres_dst1, 4);

    roix = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];    % ROI 범위 소량 확장
    roiy = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];    % ROI 범위 소량 확장
    roi = roipoly(thres_dst1, roix, roiy);
    thres_dst = thres_dst2 .* roi;
    gray_thres_dst = rgb2gray(thres_dst);

    count_pixel = 0;
    center_row = 0;
    center_col = 0;
    for row = 1:rows
        for col = 1:cols
            if gray_thres_dst(row, col) == 1
                count_pixel = count_pixel + 1;
                center_row = center_row + row;
                center_col = center_col + col;    
            end        
        end
    end
    center_row = center_row / count_pixel
    center_col = center_col / count_pixel
    
    move_x = rows/2 - center_row
    move_y = cols/2 - center_col
    % 픽셀 수를 미터로 변환하여 이동시키기...
    
    
    
    
    
    
    
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
