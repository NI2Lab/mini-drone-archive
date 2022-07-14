for k = 1:1
    if k == 1
        src = imread("문제1.png");
    end
    
    src_hsv = rgb2hsv(src);
    thdown_green = [0.25, 40/240, 80/240];         
    thup_green = [0.40, 1, 1];

    [rows, cols, channels] = size(src_hsv);

    dst_h = src_hsv(:, :, 1);
    dst_s = src_hsv(:, :, 2);
    dst_v = src_hsv(:, :, 3);

    dst_hsv1 = double(zeros(size(dst_h)));       
    dst_hsv2 = double(zeros(size(dst_h)));

    for row = 1:rows
        for col = 1:cols
           if thdown_green(1) < dst_h(row, col) && dst_h(row, col) < thup_green(1) ...
               && thdown_green(2) < dst_s(row, col) && dst_s(row, col) < thup_green(2) ...
               && thdown_green(3) < dst_v(row, col) && dst_v(row, col) < thup_green(3)
               dst_hsv1(row, col) = 1;
            else
                dst_hsv2(row, col) = 1;
            end
        end
    end
    figure,imshow(dst_hsv1)
    figure,imshow(dst_hsv2)

    %상하좌우 맞추기
    while 1
        %좌우 부터
        lcnt = 0;
        rcnt = 0;
        for row = 1:rows                                
            for col = 1:cols
                %좌
                if row < 360
                    lcnt = lcnt + 1;
                %우
                else
                    rcnt = rcnt + 1;
                end        
            end
        end
        %상하
        ucnt = 0;
        dcnt = 0;
        for row = 1:rows                                
            for col = 1:cols
                %상
                if row < 480
                    ucnt = ucnt + 1;
                %하
                else
                    dcnt = dcnt + 1;
                end        
            end
        end
        if (lcnt - rcnt) > 2000
            moveleft(drone, 'distance', 0.2);
        elseif (rcnt - lcnt) > 2000
            moveright(drone, 'distance', 0.2);
        elseif (ucnt - dcnt) > 2000
            moveup(drone, 'distance', 0.2);
        elseif (dcnt - ucnt) > 2000
            movedown(drone, 'distance', 0.2);
        else
            break;
        end
    end
    
    dst_gray1 = im2gray(dst_hsv1);
    canny1 = edge(dst_gray1,'Canny');        

    count = 0;
    count1 = 0;
    %모서리 구하기 이거 고쳐야됨
    while 1
        corners = pgonCorners(canny1,4);
        %모서리 개수    
        for i = 1:size(corners)
            count = count + 1;
        end
        %너무 가까울 때나 모서리가 안보일 때
        if count < 4
            %만약 이전에 모서리가 4개가 다 검출되다가 안되는 것이라면
            if count1 == 4
                moveforward(drone,'distance',1);
            else
                moveback(drone, 'distance', 0.2);
            end
        else
            break;
        end
        count1 = count;
    end

    roi = roipoly(dst_gray1,corners(:,2),corners(:,1));
    dst_img = dst_hsv2 .* roi;
    dst_gray = im2gray(dst_img);

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
    
    answer = [center_col, center_row];          % 센터좌표 검출
    
    %중심좌표와 드론의 중심이 비슷할 때
    if abs(center_row - rows/2) < 200 && abs(center_col - cols/2) < 200
        moveforward(drone,'distance', 0.2);
    end
    
    subplot(2, 3, 1); imshow(dst_img);
    subplot(2, 3, 2); imshow(dst_gray1); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    subplot(2, 3, 3); imshow(src); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    
    %{
    dst_gray = im2gray(dst_img);
    canny = edge(dst_gray,'Canny');
    
    corner = pgonCorners(canny,4);
    hold on
    plot(corner(:,2),corner(:,1),'yo','MarkerFaceColor','r',...
                                'MarkerSize',12,'LineWidth',2);
    hold off
    polyin = polyshape(corner(:,2),corner(:,1)); 
    [x,y] = centroid(polyin); 
    hold on
    plot(x,y,'r*')
    hold off
    disp(k + ": " + x + "," + y) 
    %}
end