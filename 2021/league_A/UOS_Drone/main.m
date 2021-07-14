function main
    diff=0;                 % 구멍 또는 표식의 허용 범위
    x=0; y=0;               % 구멍 또는 표식의 기준 좌표
    cx_h=0; cy_h=0;         % 구멍의 픽셀 좌표
    cx_r=0; cy_r=0;         % 표식의 픽셀 좌표
    
    step=1; mission=1;         % 단계 및 미션 절차를 나타내는 변수(step : 1-3 단계, mission : 1-3 미션)
    search=1; up=1; right=1; down=2; left=2;    % 구멍 또는 표식을 찾는 탐색 알고리즘 변수
    
    droneObj=ryze();        % 드론 객체 선언
    cameraObj=camera(droneObj); % 카메라 객체 선언
    
    takeoff(droneObj);      % 이륙
    pause(0.1);
    
    while 1
        switch step
           % 1단계
            case 1
                % 프레임을 가져와 RGB 색공간을 HSV 색공간으로 변환
                frame=snapshot(cameraObj);
                hsv_img=rgb2hsv(frame);
                h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);
                
                % 특정 범위를 설정하여 파란색 천과 빨간색 표식을 이진화
                mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1);
                hole=imcomplement(mask);
                se=strel('disk',10);        % 노이즈 제거를 위해 모폴로지 닫기 연산 수행
                hole=imclose(hole,se);
                
                rect=((0.95<h)|(h<0.04))&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
                
                % 구멍의 이진 이미지를 영역으로 분할하여 넓이, 중심점, 원형률 속성을 구함
                % 구멍이 원인 성질을 이용하여 영역의 넓이가 작거나 원형률이 작은 영역을 제거함
                stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.82);
                stats_h(A,:) = [];
                
                % 표식의 이진 이미지를 영역으로 분할하여 넓이, 중심점 속성을 구함
                % 영역의 넓이가 작은 영역을 제거함
                stats_r=regionprops('table', rect, 'Area', 'Centroid');
                B=find(stats_r.Area <= 200);
                stats_r(B,:) = [];
                
                % 구멍의 이진 이미지 내 영역이 존재하고 미션 1일 때
                if size(stats_h, 1)>0 && mission==1
                    % 원형률이 가장 큰 영역을 구멍으로 판단하고 중심 좌표를 가져옴
                    [~,Ih]=max(stats_h.Circularity);
                    cx_h=round(stats_h.Centroid(Ih,1)); cy_h=round(stats_h.Centroid(Ih,2));
                    search=1; up=1; right=1; down=2; left=2;
                else
                    % 미션 1에서 구멍의 이진 이미지 내 영역을 찾지 못했을 경우 탐색하는 알고리즘
                    if mission==1
                        if search==1
                            [height,~]=readHeight(droneObj)
                        end
                        switch search
                            case 1
                                moveup(droneObj,'Distance', 0.3*up);
                                pause(0.2);
                                if height+0.3*up<1.7
                                    up=up+2;
                                end
                                search=2;
                                continue;
                            case 2
                                moveright(droneObj,'Distance', 0.3*right);
                                pause(0.2);
                                right=right+2;
                                search=3;
                                continue;
                            case 3
                                movedown(droneObj,'Distance', 0.3*down);
                                pause(0.2);
                                if height-0.3*down>0.3
                                    down=down+2;
                                end
                                search=4;
                                continue;
                            case 4
                                moveleft(droneObj,'Distance', 0.3*left);
                                pause(0.2);
                                left=left+2;
                                search=1;
                                continue;
                        end
                    end
                end
                
                % 표식의 이진 이미지에서 영역이 존재할 경우
                if size(stats_r, 1)>0
                    % 영역의 넓이가 가장 넓은 영역을 표식으로 판단하고 중심 좌표를 가져옴
                    [~,Ir]=max(stats_r.Area);
                    cx_r=round(stats_r.Centroid(Ir,1)); cy_r=round(stats_r.Centroid(Ir,2));
                    search=1; up=1; right=1; down=2; left=2;
                    % 미션 1에서 표식 영역의 넓이가 300~3000 사이일 때 미션 2로 전환
                    if mission==1 && 200<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                        mission=2;
                    
                    % 미션 2 또는 3에서 표식 영역의 넓이가 3000 이상일 때, 2단계로 넘어감
                    elseif mission>1 && stats_r.Area(Ir)>=3000
                        turn(droneObj, deg2rad(-90));
                        pause(0.2);
                        moveforward(droneObj,'Distance', 1.1, 'speed', 1);
                        step=step+1;
                        mission=1;
                        continue;
                    end
                    
                % 미션 2 또는 3에서 표식의 이진 이미지 내에서 영역을 찾지 못했을 경우 탐색하는 알고리즘
                elseif mission>1
                    if search==1
                        [height,~]=readHeight(droneObj)
                    end
                    switch search
                        case 1
                            moveup(droneObj,'Distance', 0.2*up);
                            pause(0.2); 
                            search=2;
                            continue;
                        case 2
                            moveright(droneObj,'Distance', 0.2*right);
                            pause(0.2);
                            search=3;
                            continue;
                        case 3
                            movedown(droneObj,'Distance', 0.2*down);
                            pause(0.2);
                            search=4;
                            continue;
                        case 4
                            moveleft(droneObj,'Distance', 0.2*left);
                            pause(0.2);
                            search=1;
                            continue;
                    end
                end
                
                % 미션 1에서 찾은 영역이 존재하면 구멍의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                if mission==1 && size(stats_h, 1)>0
                    cx=cx_h; cy=cy_h;
                    x=480; y=225;
                    diff=20;
                    disp("hole");
                % 미션 2 또는 3에서 찾은 영역이 존재하면 표식의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                elseif mission>1 && size(stats_r, 1)>0
                    cx=cx_r; cy=cy_r;
                    x=480; y=190;
                    diff=15;
                    stats_r.Area(Ir)
                    disp("rect");
                else
                % 아무런 영역도 존재하지 않을 때 예외 처리
                    cx=-1; cy=-1;
                end
                
                if cx>=0 && cy>=0
                    % 기준 좌표가 존재할 때 기준 좌표와 픽셀 좌표가 벗어난 방향으로 드론을 제어
                    dx=0; dy=cx-x; dz=cy-y;
                    if dy>diff && dz>diff
                        dy=0.1; dz=0.2;
                    elseif dy>diff && dz<-diff
                        dy=0.1; dz=-0.2;
                    elseif dy<-diff && dz>diff
                        dy=-0.1; dz=0.2;
                    elseif dy<-diff && dz<-diff
                        dy=-0.1; dz=-0.2;
                    else
                        % 기준 좌표와 픽셀 좌표가 허용 범위 내에 존재할 때
                        % 미션 1의 경우 조금씩 앞으로 제어
                        if mission==1
                            dx=0.3; dy=0; dz=0.1;
                        % 미션 2의 경우 구멍을 통과하고 미션 3으로 전환
                        elseif mission==2
                            pause(0.2);
                            moveforward(droneObj,'Distance', 1.35, 'speed', 1);
                            mission=3;
                            continue;
                        % 미션 3의 경우 조금씩 앞으로 제어
                        else
                            dx=0.2; dy=0; dz=0.1;
                        end
                    end
                    move(droneObj,[dx dy dz]);
                    pause(0.2);
                end
                
                % 프레임, 구멍, 표식 영상 및 중 좌표 표시
                subplot(2,2,1)
                imshow(frame)
                
                subplot(2,2,2)
                imshow(hole)
                hold on
                if size(stats_h, 1)>0
                    plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                end
                hold off
                
                subplot(2,2,3)
                imshow(rect)
                hold on
                if size(stats_r, 1)>0
                    plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                end
                hold off
                
           % 2단계
            case 2
                % 프레임을 가져와 RGB 색공간을 HSV 색공간으로 변환
                frame=snapshot(cameraObj);
                hsv_img=rgb2hsv(frame);
                h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);
                
                % 특정 범위를 설정하여 파란색 천과 빨간색 표식을 이진화
                mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1);
                hole=imcomplement(mask);
                se=strel('disk',10);        % 노이즈 제거를 위해 모폴로지 닫기 연산 수행
                hole=imclose(hole,se);
                
                rect=((0.95<h)|(h<0.04))&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
                
                % 구멍의 이진 이미지를 영역으로 분할하여 넓이, 중심점, 원형률 속성을 구함
                % 구멍이 원인 성질을 이용하여 영역의 넓이가 작거나 원형률이 작은 영역을 제거함
                stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.82);
                stats_h(A,:) = [];
                
                % 표식의 이진 이미지를 영역으로 분할하여 넓이, 중심점 속성을 구함
                % 영역의 넓이가 작은 영역을 제거함
                stats_r=regionprops('table', rect, 'Area', 'Centroid');
                B=find(stats_r.Area <= 300);
                stats_r(B,:) = [];
                
                % 구멍의 이진 이미지 내 영역이 존재하고 미션 1일 때
                if size(stats_h, 1)>0 && mission==1
                    % 원형률이 가장 큰 영역을 구멍으로 판단하고 중심 좌표를 가져옴
                    [~,Ih]=max(stats_h.Circularity);
                    cx_h=round(stats_h.Centroid(Ih,1)); cy_h=round(stats_h.Centroid(Ih,2));
                    search=1; up=1; right=1; down=2; left=2;
                else
                    % 미션 1에서 구멍의 이진 이미지 내 영역을 찾지 못했을 경우 탐색하는 알고리즘
                    if mission==1
                        if search==1
                            [height,~]=readHeight(droneObj)
                        end
                        switch search
                            case 1
                                moveup(droneObj,'Distance', 0.3*up);
                                pause(0.2);
                                if height+0.3*up<1.7
                                    up=up+2;
                                end
                                search=2;
                                continue;
                            case 2
                                moveright(droneObj,'Distance', 0.8*right);
                                pause(0.2);
                                right=right+2;
                                search=3;
                                continue;
                            case 3
                                movedown(droneObj,'Distance', 0.3*down);
                                pause(0.2);
                                if height-0.3*down>0.3
                                    down=down+2;
                                end
                                search=4;
                                continue;
                            case 4
                                moveleft(droneObj,'Distance', 0.8*left);
                                pause(0.2);
                                left=left+2;
                                search=1;
                                continue;
                        end
                    end
                end
                
                % 표식의 이진 이미지에서 영역이 존재할 경우
                if size(stats_r, 1)>0
                    % 영역의 넓이가 가장 넓은 영역을 표식으로 판단하고 중심 좌표를 가져옴
                    [~,Ir]=max(stats_r.Area);
                    cx_r=round(stats_r.Centroid(Ir,1)); cy_r=round(stats_r.Centroid(Ir,2));
                    search=1; up=1; right=1; down=2; left=2;
                    % 미션 1에서 표식 영역의 넓이가 300~3000 사이일 때 미션 2로 전환
                    if mission==1 && 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                        mission=2;
                    
                    % 미션 2 또는 3에서 표식 영역의 넓이가 3000 이상일 때, 3단계로 넘어감
                    elseif mission>1 && stats_r.Area(Ir)>=3000
                        turn(droneObj, deg2rad(-90));
                        pause(0.2);
                        moveforward(droneObj,'Distance', 1.1, 'speed', 1);
                        step=step+1;
                        mission=1;
                        continue;
                    end
                    
                % 미션 2 또는 3에서 표식의 이진 이미지 내에서 영역을 찾지 못했을 경우 탐색하는 알고리즘
                elseif mission>1
                    if search==1
                        [height,~]=readHeight(droneObj)
                    end
                    switch search
                        case 1
                            moveup(droneObj,'Distance', 0.2*up);
                            pause(0.2);
                            search=2;
                            continue;
                        case 2
                            moveright(droneObj,'Distance', 0.2*right);
                            pause(0.2);
                            search=3;
                            continue;
                        case 3
                            movedown(droneObj,'Distance', 0.2*down);
                            pause(0.2);
                            search=4;
                            continue;
                        case 4
                            moveleft(droneObj,'Distance', 0.2*left);
                            pause(0.2);
                            search=1;
                            continue;
                    end
                end
                
                % 미션 1에서 찾은 영역이 존재하면 구멍의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                if mission==1 && size(stats_h, 1)>0
                    cx=cx_h; cy=cy_h;
                    x=480; y=225;
                    diff=15;
                    disp("hole");
                % 미션 2 또는 3에서 찾은 영역이 존재하면 표식의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                elseif mission>1 && size(stats_r, 1)>0
                    cx=cx_r; cy=cy_r;
                    x=480; y=190;
                    diff=10;
                    stats_r.Area(Ir)
                    disp("rect");
                else
                % 아무런 영역도 존재하지 않을 때 예외 처리
                    cx=-1; cy=-1;
                end
                
                if cx>=0 && cy>=0
                    % 기준 좌표가 존재할 때 기준 좌표와 픽셀 좌표가 벗어난 방향으로 드론을 제어
                    dx=0; dy=cx-x; dz=cy-y;
                    if dy>diff && dz>diff
                        dy=0.1; dz=0.2;
                    elseif dy>diff && dz<-diff
                        dy=0.1; dz=-0.2;
                    elseif dy<-diff && dz>diff
                        dy=-0.1; dz=0.2;
                    elseif dy<-diff && dz<-diff
                        dy=-0.1; dz=-0.2;
                    else
                        % 기준 좌표와 픽셀 좌표가 허용 범위 내에 존재할 때
                        % 미션 1의 경우 조금씩 앞으로 제어
                        if mission==1
                            dx=0.3; dy=0; dz=0.1;
                        % 미션 2의 경우 구멍을 통과하고 미션 3으로 전환
                        elseif mission==2
                            pause(0.2);
                            moveforward(droneObj,'Distance', 1.2, 'speed', 1);
                            mission=3;
                            continue;
                        % 미션 3의 경우 조금씩 앞으로 제어
                        else
                            dx=0.2; dy=0; dz=0.1;
                        end
                    end
                    move(droneObj,[dx dy dz]);
                    pause(0.2);
                end
                
                % 프레임, 구멍, 표식 영상 및 중 좌표 표시
                subplot(2,2,1)
                imshow(frame)
                
                subplot(2,2,2)
                imshow(hole)
                hold on
                if size(stats_h, 1)>0
                    plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                end
                hold off
                
                subplot(2,2,3)
                imshow(rect)
                hold on
                if size(stats_r, 1)>0
                    plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                end
                hold off
                
           % 3단계
            case 3
                % 프레임을 가져와 RGB 색공간을 HSV 색공간으로 변환
                frame=snapshot(cameraObj);
                hsv_img=rgb2hsv(frame);
                h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);
                
                % 특정 범위를 설정하여 파란색 천과 보라색 표식을 이진화
                mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1);
                hole=imcomplement(mask);
                se=strel('disk',10);        % 노이즈 제거를 위해 모폴로지 닫기 연산 수행
                hole=imclose(hole,se);
                
                rect=(0.7<h)&(h<0.8)&(0.1<s)&(s<=1)&(0.2<v)&(v<=1);
                
                % 구멍의 이진 이미지를 영역으로 분할하여 넓이, 중심점, 원형률 속성을 구함
                % 구멍이 원인 성질을 이용하여 영역의 넓이가 작거나 원형률이 작은 영역을 제거함
                stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.82);
                stats_h(A,:) = [];
                
                % 표식의 이진 이미지를 영역으로 분할하여 넓이, 중심점 속성을 구함
                % 영역의 넓이가 작은 영역을 제거함
                stats_r=regionprops('table', rect, 'Area', 'Centroid');
                B=find(stats_r.Area <= 300);
                stats_r(B,:) = [];
                
                % 구멍의 이진 이미지 내 영역이 존재하고 미션 1일 때
                if size(stats_h, 1)>0 && mission==1
                    % 원형률이 가장 큰 영역을 구멍으로 판단하고 중심 좌표를 가져옴
                    [~,Ih]=max(stats_h.Circularity);
                    cx_h=round(stats_h.Centroid(Ih,1)); cy_h=round(stats_h.Centroid(Ih,2));
                    search=1; up=1; right=1; down=2; left=2;
                else
                    % 미션 1에서 구멍의 이진 이미지 내 영역을 찾지 못했을 경우 탐색하는 알고리즘
                    if mission==1
                        if search==1
                            [height,~]=readHeight(droneObj)
                        end
                        switch search
                            case 1
                                moveup(droneObj,'Distance', 0.3*up);
                                pause(0.2);
                                if height+0.3*up<1.7
                                    up=up+2;
                                end
                                search=2;
                                continue;
                            case 2
                                moveright(droneObj,'Distance', 0.8*right);
                                pause(0.2);
                                right=right+2;
                                search=3;
                                continue;
                            case 3
                                movedown(droneObj,'Distance', 0.3*down);
                                pause(0.2);
                                if height-0.3*down>0.3
                                    down=down+2;
                                end
                                search=4;
                                continue;
                            case 4
                                moveleft(droneObj,'Distance', 0.8*left);
                                pause(0.2);
                                left=left+2;
                                search=1;
                                continue;
                        end
                    end
                end
                
                % 표식의 이진 이미지에서 영역이 존재할 경우
                if size(stats_r, 1)>0
                    % 영역의 넓이가 가장 넓은 영역을 표식으로 판단하고 중심 좌표를 가져옴
                    [~,Ir]=max(stats_r.Area);
                    cx_r=round(stats_r.Centroid(Ir,1)); cy_r=round(stats_r.Centroid(Ir,2));
                    search=1; up=1; right=1; down=2; left=2;
                    % 미션 1에서 표식 영역의 넓이가 300~3000 사이일 때 미션 2로 전환
                    if mission==1 && 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                        mission=2;
                    
                    % 미션 2 또는 3에서 표식 영역의 넓이가 3000 이상일 때, 전체 루프를 빠져나감
                    elseif mission>1 && stats_r.Area(Ir)>=3000
                        break
                    end
                    
                % 미션 2 또는 3에서 표식의 이진 이미지 내에서 영역을 찾지 못했을 경우 탐색하는 알고리즘
                elseif mission>1
                    if search==1
                        [height,~]=readHeight(droneObj)
                    end
                    switch search
                        case 1
                            moveup(droneObj,'Distance', 0.2*up);
                            pause(0.2);
                            search=2;
                            continue;
                        case 2
                            moveright(droneObj,'Distance', 0.2*right);
                            pause(0.2);
                            search=3;
                            continue;
                        case 3
                            movedown(droneObj,'Distance', 0.2*down);
                            pause(0.2);
                            search=4;
                            continue;
                        case 4
                            moveleft(droneObj,'Distance', 0.2*left);
                            pause(0.2);
                            search=1;
                            continue;
                    end
                end
                
                % 미션 1에서 찾은 영역이 존재하면 구멍의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                if mission==1 && size(stats_h, 1)>0
                    cx=cx_h; cy=cy_h;
                    x=480; y=225;
                    diff=15;
                    disp("hole");
                % 미션 2 또는 3에서 찾은 영역이 존재하면 표식의 픽셀 좌표를 기준 좌표로 설정하고, 그에 맞는 변수 설정
                elseif mission>1 && size(stats_r, 1)>0
                    cx=cx_r; cy=cy_r;
                    x=480; y=190;
                    diff=10;
                    stats_r.Area(Ir)
                    disp("rect");
                else
                % 아무런 영역도 존재하지 않을 때 예외 처리
                    cx=-1; cy=-1;
                end
                
                if cx>=0 && cy>=0
                    % 기준 좌표가 존재할 때 기준 좌표와 픽셀 좌표가 벗어난 방향으로 드론을 제어
                    dx=0; dy=cx-x; dz=cy-y;
                    if dy>diff && dz>diff
                        dy=0.1; dz=0.2;
                    elseif dy>diff && dz<-diff
                        dy=0.1; dz=-0.2;
                    elseif dy<-diff && dz>diff
                        dy=-0.1; dz=0.2;
                    elseif dy<-diff && dz<-diff
                        dy=-0.1; dz=-0.2;
                    else
                        % 기준 좌표와 픽셀 좌표가 허용 범위 내에 존재할 때
                        % 미션 1의 경우 조금씩 앞으로 제어
                        if mission==1
                            dx=0.3; dy=0; dz=0.1;
                        % 미션 2의 경우 구멍을 통과하고 미션 3으로 전환
                        elseif mission==2
                            pause(0.2);
                            moveforward(droneObj,'Distance', 1.2, 'speed', 1);
                            mission=3;
                            continue;
                        % 미션 3의 경우 조금씩 앞으로 제어
                        else
                            dx=0.2; dy=0; dz=0.1;
                        end
                    end
                    move(droneObj,[dx dy dz]);
                    pause(0.2);
                end
                
                % 프레임, 구멍, 표식 영상 및 중 좌표 표시
                subplot(2,2,1)
                imshow(frame)
                
                subplot(2,2,2)
                imshow(hole)
                hold on
                if size(stats_h, 1)>0
                    plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                end
                hold off
                
                subplot(2,2,3)
                imshow(rect)
                hold on
                if size(stats_r, 1)>0
                    plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                end
                hold off
                
        end  
    end

    land(droneObj);
end
