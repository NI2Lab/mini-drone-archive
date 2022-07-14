droneObj = ryze()
cameraObj = camera(droneObj);
level = 1;
takeoff(droneObj);
moveup(droneObj,'distance',0.2,'speed',1)
center_x = 480;
center_y = 200;
j = 1;
movelr = true;
moveud = true;
stopmove = true;
nohole = false;
distance = 0;
adj_x = 0;
adj_y = 0;
num = 0;

disp("Level 1 start");
while (1)    
    frame = snapshot(cameraObj);

    hold off;
    subplot(2,1,1);
    imshow(frame)

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
       
    detect_ring = (0.6<h)&(h<0.66)&(0.55<s)&(s<0.9);
    detect_red = ((0.95<h)&(h<1)|(0<h)&(h<0.05))&(0.85<s)&(s<1);
    %detect_red = (0.38<h) & (h<0.43) & (0.55<s);
    detect_green = (0.38<h) & (h<0.43) & (0.55<s);
    detect_purple = (h>0.725) & (h<0.775) & (s>0.5); 
    
    if (level == 1) 
        disp("Level 1 end");
        while sum(detect_green,'all') < 700
            moveforward(droneObj,'distance',0.5,'speed', 1)
            frame = snapshot(cameraObj);
            subplot(2,1,1);
            imshow(frame)
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            detect_green = (0.38<h) & (h<0.43) & (0.55<s); 
        end
        imshow(detect_green);
        moveforward(droneObj,'distance',0.5,'speed',1)
        turn(droneObj,deg2rad(90))
        moveforward(droneObj,'distance',0.5,'speed',1)
        level = level + 1;
        disp("Level 2 start");
        continue;
    elseif (level == 2 && sum(detect_purple,'all') > 200) 
        disp("Level 2 end");
        imshow(detect_purple);
        moveright(droneObj,'distance',0.8,'speed',1)
        turn(droneObj,deg2rad(135))
        moveforward(droneObj,'distance',0.5,'speed',1)
        level = level + 1;
        disp("Level 3 start");
        continue;    
    elseif (level == 3 && sum(detect_red,'all') > 200) 
        disp("Level 3 end");
        imshow(detect_red);
        moveforward(droneObj,'distance',0.2,'speed',1)
        land(droneObj);
        break;
    elseif  sum(detect_ring,'all') > 0
        % bwareafilt: 가장 큰 n=1개의 영역만 남기기
        detect_ring = bwareafilt(detect_ring, 1);
        pass = detect_ring;
        pass = imfill(pass,'holes');
        [row, col] = find(pass);
        locmin = min(col);
        locmax = max(col);
        ring_center = (locmin + locmax) / 2;

        detect_ring= imcomplement(detect_ring);
        store = detect_ring;
        if sum(store,'all') <= 80000
            moveback(droneObj,'distance',0.3,'speed',1)
            continue
        end

        detect_ring = bwareafilt(detect_ring, 2);
        

        % bwareafilt: 가장 작은 영역만 남기기
        compare = bwareafilt(detect_ring, 1, 'largest');
        detect_ring = bwareafilt(detect_ring, 1, 'smallest');
        
        while 1
            if sum(pass,'all') == 0
                hold off
                break
            end

            [B,L,N] = bwboundaries(detect_ring);
            
            subplot(2,1,2);
            imshow(detect_ring); 
            hold on;
            for k=1:length(B)
               boundary = B{k};
               if(k >= N)
                 plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
               end
            end
            c = regionprops(detect_ring,'centroid');
            centroids = cat(1,c.Centroid);
            plot(centroids(:,1),centroids(:,2),'b*');        
            disp("X coord: " + centroids(:,1) + "   Y coord: " + centroids(:,2));
            
            if ((sum(detect_ring,'all') < 50) && sum(detect_ring,'all') > 10) || isequal(compare, detect_ring)
                disp("test");       
                detect_ring = store;
                detect_ring = bwareafilt(detect_ring, 1);
                detect_ring= imcomplement(detect_ring);
                subplot(2,1,2);
                imshow(detect_ring); 
                stopmove = false;
                nohole = true;
                continue
            end
            nohole = false;

            find_circle = pass;
            for i = 1:960
                find_circle(1,i) = 1;
            end
    
            for i = 1:960
                find_circle(720,i) = 1;
            end
            
            if ring_center <= 481
                for i = 1:720
                    find_circle(i,1) = 1;
                end
            else
                for i = 1:720
                    find_circle(i,960) = 1;
                end
            end
    
            find_circle = imfill(find_circle,'holes');
            
            a = round(centroids(:,1));
            b = round(centroids(:,2));
            if find_circle(b,a) == 1
                break
            else
                detect_ring = store;
                detect_ring = bwareafilt(detect_ring, 1); 
                j = j + 1;
            end
            if j == 3
                moveback(droneObj,'distance',0.2,'speed',1)
                break
            end
        end
        j = 1;

        center = [center_x,center_y];
        goal = [centroids(:,1), centroids(:,2)];
        if level == 2
            distance = 100;
        elseif level == 3
            distance = 75;
        end
        sub_x = center_x - centroids(:,1);
        sub_y = center_y - centroids(:,2);

        disp("X 차이: " + sub_x + ", Y 차이: " + sub_y);
        
        if abs(center_x - centroids(:,1)) >= 300
            adj_x = 0.3;
        elseif abs(center_x - centroids(:,1)) < 300 &&  ( abs(center_x - centroids(:,1)) >= 250 )
            adj_x = 0.2;
        elseif abs(center_x - centroids(:,1)) < 250 &&  ( abs(center_x - centroids(:,1)) >= 100 )
            adj_x = 0.1;
        elseif abs(center_x - centroids(:,1)) < 100
            adj_x = 0;
        end

        if abs(center_y - centroids(:,2)) >= 300
            adj_y = 0.3;
        elseif abs(center_y - centroids(:,2)) > 300 &&  ( abs(center_y - centroids(:,2)) >= 250 )
            adj_y = 0.2;
        elseif abs(center_y - centroids(:,2)) >= 100 &&  ( abs(center_y - centroids(:,2)) < 250 )
            adj_y = 0.1;
        elseif abs(center_y - centroids(:,2)) < 100
            adj_y = 0;
        end

        if norm(center-goal) > distance
            if movelr && (center_x - centroids(:,1)) >= 45
                if nohole == true
                    moveleft(droneObj,'distance',0.4 + adj_x,'speed',1) 
                else
                    moveleft(droneObj,'distance',0.2 + adj_x,'speed',1) 
                end 
            elseif (center_x - centroids(:,1)) < -45
                if nohole == true
                    moveright(droneObj,'distance',0.4 + adj_x,'speed',1) 
                else
                    moveright(droneObj,'distance',0.2 + adj_x,'speed',1) 
                end
            else
                movelr = false;
            end
            num = num + 1;

            if moveud && (center_y - centroids(:,2)) >= 45
                if nohole == true
                    moveup(droneObj,'distance',0.4 + adj_y,'speed',1) 
                else
                    moveup(droneObj,'distance',0.2 + adj_y,'speed',1) 
                end
            elseif (center_y - centroids(:,2)) <= -45
                if nohole == true
                    movedown(droneObj,'distance',0.4 + adj_y,'speed',1) 
                else
                    movedown(droneObj,'distance',0.2 + adj_y,'speed',1) 
                end 
            else 
                moveud = false;
            end
            num = num + 1;
            
            if num >= 6
                moveback(droneObj,'distance',0.3,'speed',1)
                num = 0;
                continue
            end

            if stopmove == false
                movelr = true;
                moveud = true;
            end
            continue;
        else
            detect_ring = pass;
            while(sum(detect_ring,'all') > 10)
                moveforward(droneObj,'distance',0.6,'speed',1)
                frame = snapshot(cameraObj);
                subplot(2,1,1);
                imshow(frame)
            
                hsv = rgb2hsv(frame);
                h = hsv(:,:,1);
                s = hsv(:,:,2);
                v = hsv(:,:,3);
                detect_ring = (0.6<h)&(h<0.66)&(0.55<s)&(s<0.9);
                subplot(2,1,2);
                imshow(detect_ring)
            end
            movelr = true;
            moveud = true;
            stopmove = true;
            num = 0;
            moveforward(droneObj,'distance',0.5,'speed',1)
            
            continue;
        end
    else
        % 파란색 링이나 마커가 안 보일 경우는?
        moveback(droneObj,'distance',0.2,'speed',1) 
    end
end   
