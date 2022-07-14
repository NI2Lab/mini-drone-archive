for k = 1:5
    if k == 1
        src = imread("문제1.png");
    elseif k == 2
        src = imread("문제2.png");
    elseif k == 3
        src = imread("문제3.png");
    elseif k == 4
        src = imread("문제4.png");
    elseif k == 5
        src = imread("문제5.png");
    end
    
    src_hsv = rgb2hsv(src);
    thdown_green = [0.25, 40/240, 80/240];         % 임계값 설정.
    thup_green = [0.40, 1, 1];

    [rows, cols, channels] = size(src_hsv);        % 이미지의 가로,세로 픽셀 수 저장

    dst_h = src_hsv(:, :, 1);
    dst_s = src_hsv(:, :, 2);
    dst_v = src_hsv(:, :, 3);

    dst_hsv1 = double(zeros(size(dst_h)));       % 색깔만 확인하는 0 배열 생성
    dst_hsv2 = double(zeros(size(dst_h)));

    % 위에서 받은 hsv값으로 구별할 수 있도록 고침
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
    % rgb로 안바꿔도 im2gray사용하면 돌아감
    dst_gray1 = im2gray(dst_hsv1);
    canny1 = edge(dst_gray1,'Canny');        %canny 사용

    corners = pgonCorners(canny1,4);
    % 코너가 4개가 아닐 때 몇개의 코너가 있는지 확인
    count = 0;
    for i = 1:size(corners)
        count = count + 1;
    end

    a = [0 0 0 0]; % a4: 좌상 a3: 우상 a1: 좌하 a2: 우하 위치에 있을 때
    if count == 3       % 문제3번처럼 한 구석이 안나올 때
        for i = 1:size(corners)
            if corners(i,1) >= 718
                a(1) = a(1)+1;
                a(2) = a(2)+1;
            end
            if corners(i,1) <= 2
                a(3) = a(3)+1;
                a(4) = a(4)+1;
            end
            if corners(i,2) >= 958
                a(2) = a(2)+1;
                a(3) = a(3)+1;
            end
            if corners(i,2) <= 2
                a(4) = a(4)+1;
                a(1) = a(1)+1;
            end
        end
    end
    % roi를 할 수 있도록 순서를 재배치 하고 가장 끝쪽 값을 넣어줌
    for i = 1:4
        if a(i) == 2
            if i == 4
                corners(i,2) = 4;
                corners(i,1) = 4;
            else
                for j = 4:-1:i+1
                    corners(j,1) = corners(j-1,1);
                    corners(j,2) = corners(j-1,2);
                end
                if i == 1 
                    corners(i,2) = 4;
                    corners(i,1) = 716;
                elseif i == 2
                    corners(i,2) = 956;
                    corners(i,1) = 716;
                elseif i == 3
                    corners(i,1) = 4;
                    corners(i,2) = 956;           
                end
            end
        end
    end
    % 값이 잘 나올 수 있도록 roi값을 줄여줌
    for i = 1:4
        if i == 1
            corners(i,1) = corners(i,1)-4;
            corners(i,2) = corners(i,2)+4;
        end
        if i == 2
            corners(i,1) = corners(i,1)-4;
            corners(i,2) = corners(i,2)-4;
        end  
        if i == 3
            corners(i,1) = corners(i,1)+4;
            corners(i,2) = corners(i,2)-4;
        end  
        if i == 4
            corners(i,1) = corners(i,1)+4;
            corners(i,2) = corners(i,2)+4;
        end  
    end

%{
만약 코너가 두개밖에 없을 때 , 안짰음 대충 잡아놓은거 만약 쓴다면 위에와 같이 사용하면 됨
A = [0 0 0 0]; %A1:상 A2: 하 A3: 좌 A4: 우
if size(corners) == 3
    for i = 1:size(corners)
        if corners(i,1) > 718
            if corners(i,2) <2 || corners(i,2) > 958
                A(2) = A(2)+1;
            end
        end
        if corners(i,1) < 2
            if corners(i,2) <2 || corners(i,2) > 958
                A(1) = A(1)+1;
            end
        end
        if corners(i,2) > 958
            if corners(i,1) <2 || corners(i,1) > 718
                A(4) = A(4)+1;
            end
        end
        if corners(i,2) < 2
            if corners(i,1) <2 || corners(i,1) > 718
                A(3) = A(3)+1;
            end
        end
    end
end
%}
    % roi
    roi = roipoly(canny1,corners(:,2),corners(:,1));
    % 합침
    dst_img = dst_hsv2 .* roi;   
    figure,imshow(dst_img)

    dst_gray = im2gray(dst_img);
    canny = edge(dst_gray,'Canny');
    %마지막 코너 구하기
    corner = pgonCorners(canny,4);
    hold on
    plot(corner(:,2),corner(:,1),'yo','MarkerFaceColor','r',...
                                'MarkerSize',12,'LineWidth',2);
    hold off
    polyin = polyshape(corner(:,2),corner(:,1)); %코너 모양의 다각형 생성
    [x,y] = centroid(polyin); %중점 좌표 구하는 함수
    hold on
    plot(x,y,'r*')
    hold off
    disp(k + ": " + x + "," + y) %중점좌표 구함
end

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