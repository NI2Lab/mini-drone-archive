
droneobj = ryze()
cameraObj = camera(droneobj);
se = strel('disk',70);
stage=1;
targetcenter_notfull=[480 300];
targetcenter_full=[480 240];
saveImage=[];
RLIn_notfull=0;
UDIn_notfull=0;
RLIn_full=0;
UDIn_full=0;
center_reset=0;
figure();hold on;
margin2_notfull=40; % 마진 범위를 50으로 늘려서 right left 반복 문제를 해결
margin2_full=60;
margin2_full_ud=70;
decrese_margin=800;
blue_pre=0;
notfullgo=0;
fullgo=0;
goCount=0;
downCount=0;
correcting_yaw = 0;
Center_restart = 0;
blueOn=0;
moveDownOn=0;
moveUpOn=0;
moveRightOn=0;
moveLeftOn=0;
takeoff(droneobj);

%% pause(0.5);
%% 원하는 높이만큼 띄우는 코드
% dist=readHeight(droneobj); %0.2가 가장 극단적 %1.7
% disp(dist);
% uptarget=1.0-dist;

% if uptarget>=0.2
%     moveup(droneobj,'Distance',uptarget,'WaitUntilDone',true);
% elseif uptarget <= -0.2
%     movedown(droneobj,'Distance',abs(uptarget),'WaitUntilDone',true); 
% end

moveup(droneobj,'Distance',0.2,'WaitUntilDone',true);

%%

while(stage == 1)
    image=snapshot(cameraObj);
%     %imshow(image);
%     imageHSV=rgb2hsv(image);
%     image1H = imageHSV(:,:,1);
%     image1S = imageHSV(:,:,2);
%     image1V = imageHSV(:,:,3);
% 
%     imageR_H = image1H <= 0.01 | image1H >= 0.97;
%     imageR_S = image1S >= 0.95 & image1S <= 1.0;
%     imageR_V = image1V >= 0.38 & image1V <= 0.41;
%     imageR_combi = imageR_H & imageR_S & imageR_V;

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_R=image1R-image1G/2-image1B/2;
    bw = image_only_R > 55;
    
    image_only_B=image1B-image1R/2-image1G/2;
    bw2 = image_only_B > 55;
    [row2, col2] = find(bw2);
    
    bw_RB=bw2 | bw;
    imshow(bw_RB);
    stats = regionprops(bw);
    centerIdx=1;
    redOn=0;
    red_close=0;
    disp('length(row2) = ');
    disp(length(row2));
    
    if (length(row2) > 50 ||  length(col2) > 50)
        blueOn=1;
    end
    
    if blueOn==0
        moveforward(droneobj,'WaitUntilDone',true,'distance',0.6);
        blueOn=1;
    end

    if (length(row2) < 50 ||  length(col2) < 50) %파랑이 없고
        stage=2;
        moveforward(droneobj,'WaitUntilDone',true,'distance',0.7);
        disp('if (length(row) < 50 || length(col) < 50) stage1 end');
        stage1image=bw;
        turn(droneobj, deg2rad(90));
        pause(0.5);
        moveforward(droneobj,'WaitUntilDone',true,'distance',0.8);
        break;
    elseif length(row2) > 50 && length(row2) < 150000
        moveforward(droneobj,1,'WaitUntilDone',true,'Speed',0.8);
        disp('movefast');
    else
        moveforward(droneobj,1,'WaitUntilDone',true,'Speed',0.5);
        disp('moveslow');
    end

end
moveup(droneobj,'Distance',0.7,'WaitUntilDone',true);
reverseOn=0;
%% stage2
while(stage == 2)
    
    image=snapshot(cameraObj);
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B > 55;
    bw_origin=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        for i = 1:numel(stats)
            if stats(i).Area>stats(centerIdx).Area
                centerIdx=i;
            end
        end
        rectangle('Position', stats(centerIdx).BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');

        stat_int=uint16(stats(centerIdx).BoundingBox);
        bw(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
    end
    [row_origin, col_origin] = find(bw_origin);

    [row, col] = find(bw);
    
%% 1m  until find red
%% 파랑이 꽉찼을 때 중앙점 수렴 및 통과하는 코드
    if fullgo==1
        downCount=0;

        goCount=0;
        while 1
            goCount=goCount+1;
            if goCount<2 
                moveforward(droneobj,0.8,'WaitUntilDone',true,'Speed',1);
            else
                moveforward(droneobj,0.8,'WaitUntilDone',true,'Speed',0.8);
            end

             bw=~bw_origin; % 원형만 남게 
        
            bw = imerode(bw,se);
            bw = imdilate(bw,se);
    
            [row, col] = find(bw);
        
            rf=mean(row);
            cf=mean(col);
            viscircles([cf rf],3);
   
            error_c=cf-targetcenter_full(1); 
             
            if abs(error_c)>margin2_full %양옆 판단, 에러가 특정 margin 밖에 있고 row가 맞춰지지 않았을 때 좀더 널널하게 판단
                if error_c>0
                    disp('right go convergence');
                    moveright(droneobj,'WaitUntilDone',true,'Distance',0.2);
                else
                    disp('left go convergence');
                    moveleft(droneobj,'WaitUntilDone',true,'Distance',0.2);
                end
            end

            image=snapshot(cameraObj);
            image1R = image(:,:,1);
            image1G = image(:,:,2);
            image1B = image(:,:,3);
        
            image_only_B=image1B-image1R/2-image1G/2;
            bw = image_only_B > 55;
            [row, col] = find(bw);
            if (length(row) < 50 || length(col) < 50)  %중심 찾은 경우
                stage=3;
                moveforward(droneobj,'WaitUntilDone',true,'distance',0.6);
                disp('if (length(row) < 50 || length(col) < 50)');
                break;
            end

        end
        
        break;

%% 파랑이 꽉차지 않았을 때 중앙점 수렴 및 통과하는 코드
    elseif notfullgo==1 && fullgo==0
        %%  하강
        downCount=0;
        movedown(droneobj,'WaitUntilDone',true,'Distance',0.3);
%         movedown(droneobj,'WaitUntilDone',true);
        disp('movedown twice');

%%      
        goCount=0;
        while 1 %전진반복문
            image=snapshot(cameraObj);
        
            image1R = image(:,:,1);
            image1G = image(:,:,2);
            image1B = image(:,:,3);
        
            image_only_B=image1B-image1R/2-image1G/2;
            bw = image_only_B > 55;
            bw_origin=bw;
            imshow(bw);
            stats = regionprops(bw);   
            centerIdx=1;
            
        
            if(~isempty(stats)) 
                for i = 1:numel(stats)
                    if stats(i).Area>stats(centerIdx).Area
                        centerIdx=i;
                    end
                end
                %rectangle('Position', stats(centerIdx).BoundingBox, ...
                    %'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
                stat_int=uint16(stats(centerIdx).BoundingBox);
                bw(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
            end

            [row, col] = find(bw);
            rf=mean(row);
            cf=mean(col);
            %viscircles([cf rf],3);
            
            error_c=cf-targetcenter_notfull(1);
            
%             if abs(error_c)>margin2_notfull %양옆 판단, 에러가 특정 margin 밖에 있을 때
%                 if error_c>0
%                     disp('right');
%                     moveright(droneobj,'WaitUntilDone',true);
%     
%                 else
%                     disp('left');
%                     moveleft(droneobj,'WaitUntilDone',true);
%     
%                 end
%             end

            [row_origin, col_origin] = find(bw_origin);
        
            [row, col] = find(bw);
            disp('length(row) = ');
            disp(length(row));
            if   (length(row) > 580000 && length(col) > 580000)
                   %파랑이 꽉찾을 때 중심점 찾는 코드로 가기
                fullimage=bw;
                fullgo=1;
                break;
            else
                moveforward(droneobj,'WaitUntilDone',true,'Distance',0.8);
            end

        end

%% 파랑이 존재하지 않는다면 올라가자  안보일 때 올라가도 파랑이 안보이는 경우는 생기지 않음(아직까진)
    elseif (length(row_origin) < 50 || length(col_origin) < 50) 
        disp('up');
        moveup(droneobj,'WaitUntilDone',true);

% 파랑이 꽉찬다면
    elseif   (length(row) > 580000 && length(col) > 580000) 
        reverseOn=1;
        bw=~bw_origin;
        
        bw = imerode(bw,se);
        bw = imdilate(bw,se);

        [row, col] = find(bw);
    
        rf=mean(row);
        cf=mean(col);
        %viscircles([cf rf],3);
    
        error_r=rf-targetcenter_full(2);
        error_c=cf-targetcenter_full(1);
%%
        if abs(error_r)>margin2_full_ud  %위아래 판단, 에러가 특정 margin 밖에 있고, Col을 맞출 때
            if error_r>0
                disp('down full');
               movedown(droneobj,'WaitUntilDone',true);
            else
                disp('up full');
              moveup(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop up down full');
            UDIn_full=UDIn_full+1;
        end
%%
        if abs(error_c)>margin2_full  %양옆 판단, 에러가 특정 margin 밖에 있고 row가 맞춰지지 않았을 때
            if error_c>0
                disp('right full');
                moveright(droneobj,'WaitUntilDone',true);
            else
                disp('left full');
                moveleft(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop right left full');
            RLIn_full=RLIn_full+1;
        end

%% 파랑생이 꽉 찼을 때 안정적으로 중심을 찾기 위해
% 양옆 혹은 위아래 하나만 중심을 찾았을 때
        if RLIn_full~=UDIn_full
            center_reset=1;
        end
        
        if center_reset==1
            UDIn_full=0;
            RLIn_full=0;
            center_reset=0;
        end
        
        if RLIn_full > 2 && UDIn_full > 2 
            fullgo=1;
            disp('fullgo=1');
        end
%% 파랑이 꽉 안 찼을 때 파랑이 보이고 상하좌우 움직일 방향 결정
    elseif notfullgo==0 && fullgo==0%if reverseOn==0 
         %% 만약 이전 파랑영역보다 현재 파랑영역이 줄어들었으면 앞으로 이동 경연때도 필요한지는 모름
%     if blue_pre > length(col_origin)+decrese_margin
%         moveforward(droneobj,'WaitUntilDone',true);
%         disp('blue is decrese');
%     end

%         blue_pre=length(col_origin);

        reverseOn=0;
        [row, col] = find(bw);
        rf=mean(row);
        cf=mean(col);
        %viscircles([cf rf],3);
        
        error_r=rf-targetcenter_notfull(2);
        error_c=cf-targetcenter_notfull(1);

        if abs(error_r)>margin2_notfull %위아래 판단, 에러가 특정 margin 밖에 있을 때
            if error_r>0
                disp('down');
                moveDownOn=1;
%                 movedown(droneobj,'WaitUntilDone',true);
            else
                disp('up');
                moveUpOn=1;
%                 moveup(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop up down');
            UDIn_notfull=UDIn_notfull+1;
        end

        if abs(error_c)>margin2_notfull %양옆 판단, 에러가 특정 margin 밖에 있을 때
            if error_c>0
                disp('right');
                moveRightOn=1;
%                 moveright(droneobj,'WaitUntilDone',true);

            else
                disp('left');
                moveLeftOn=1;
%                 moveleft(droneobj,'WaitUntilDone',true);

            end
        else
            disp('stop right left');
            RLIn_notfull=RLIn_notfull+1;
            
        end

        if RLIn_notfull==0 || UDIn_notfull==0 || RLIn_notfull~=UDIn_notfull
            if moveUpOn==1 
                if moveRightOn==1
                    move(droneobj, [0 0.2 -0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj, [0 0.2 -0.2],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 -0.2],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj,[0 -0.2 -0.2],"Speed",0.1);');
                else
                    move(droneobj, [0 0 -0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj,[0 0 -0.2],"Speed",0.1);');
                end

            elseif moveDownOn==1
                if moveRightOn==1
                    move(droneobj, [0 0.2 0.2],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj, [0 0.2 0.2],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 0.2],"WaitUntilDone",true,"Speed",0.1);  
                     disp('move(droneobj, [0 -0.2 0.2],"Speed",0.1);');
                 else
                    move(droneobj, [0 0 0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj,[0 0 0.2],"Speed",0.1);');
                end 
            elseif moveDownOn==0 && moveUpOn==0
                if moveRightOn==1
                    move(droneobj, [0 0.2 0],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj, [0 0.2 0],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 0],"WaitUntilDone",true,'Speed',0.1);
                     disp('move(droneobj, [0 -0.2 0],"Speed",0.1);');
                end
            end
            moveDownOn=0;
            moveUpOn=0;
            moveRightOn=0;
            moveLeftOn=0;
        end
        
%% 파랑생이 꽉 안찼을 때 안정적으로 중심을 찾기 위해
% 양옆 혹은 위아래 하나만 중심을 찾았을 때
        if RLIn_notfull~=UDIn_notfull
            center_reset=1;
        end
        
        if center_reset==1 
            UDIn_notfull=0;
            RLIn_notfull=0;
            center_reset=0;
        end
        
        if RLIn_notfull > 2 && UDIn_notfull > 2 
            notfullgo=1;
            disp('notfullgo');
            notfullbw=bw;
        end
        
    end

    imshow(bw);

end





%% 90도 -> 전진 -> 45도 -> 중심찾기 -> yow 조절 -> 중심찾고 전진


turn(droneobj, deg2rad(90));
moveforward(droneobj,1,"Speed",1);

turn(droneobj,deg2rad(45));
moveup(droneobj,'Distance',0.5,'WaitUntilDone',true);


disp("stage 3 in");
while(stage == 3)

    %% 
    image=snapshot(cameraObj);
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B > 55;
    bw_origin=bw;

    stats = regionprops(bw);
    centerIdx=1;

    if(~isempty(stats))
        for i = 1:numel(stats)
            if stats(i).Area>stats(centerIdx).Area
                centerIdx=i;
            end
        end
        %rectangle('Position', stats(centerIdx).BoundingBox, ...
            %'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');

        stat_int=uint16(stats(centerIdx).BoundingBox);
        bw(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
    end
    [row_origin, col_origin] = find(bw_origin);

    [row, col] = find(bw);

    %%파랑이 꽉찼을 경우
    if (length(row) > 590000 && length(col) > 590000)
         reverseOn=1;
         bw=~bw_origin;

         bw = imerode(bw,se);
         bw = imdilate(bw,se);

         [row, col] = find(bw);

         rf=mean(row);
         cf=mean(col);
         %viscircles([cf rf],3);

         error_r=rf-targetcenter_full(2);
         error_c=cf-targetcenter_full(1);

%%
        if abs(error_r)>margin2_full_ud  %위아래 판단, 에러가 특정 margin 밖에 있고, Col을 맞출 때
            if error_r>0
                disp('down full');
                movedown(droneobj,'WaitUntilDone',true);
            else
                disp('up full');
                moveup(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop up down full');
            UDIn_full=UDIn_full+1;
        end
%%
        if abs(error_c)>margin2_full  %양옆 판단, 에러가 특정 margin 밖에 있고 row가 맞춰지지 않았을 때
            if error_c>0
                disp('right full');
                moveright(droneobj,'WaitUntilDone',true);
            else
                disp('left full');
                moveleft(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop right left full');
            RLIn_full=RLIn_full+1;
        end

%% 파랑생이 꽉 찼을 때 안정적으로 중심을 찾기 위해
% 양옆 혹은 위아래 하나만 중심을 찾았을 때
        if RLIn_full~=UDIn_full
            center_reset=1;
        end
        
        if center_reset==1
            UDIn_full=0;
            RLIn_full=0;
            center_reset=0;
        end
        
        if RLIn_full > 2 && UDIn_full > 2 
            fullgo=1;
            stage = 0;
            disp('fullgo=1');
        end
     
%% 파랑이 꽉 차지 않았을 때 파랑이 보이고 상하좌우 움직일 방향 결정
    else%if reverseOn==0 
        %% 만약 이전 파랑영역보다 현재 파랑영역이 줄어들었으면 앞으로 이동 경연때도 필요한지는 모름
%             if blue_pre > length(col_origin)+decrese_margin
%                 moveforward(droneobj,'WaitUntilDone',true);
%                 disp('blue is decrese');
%             end

        blue_pre=length(col_origin);

        reverseOn=0;
        [row, col] = find(bw);
        rf=mean(row);
        cf=mean(col);
        viscircles([cf rf],3);

        error_r=rf-targetcenter_notfull(2);
        error_c=cf-targetcenter_notfull(1);

        if abs(error_r)>margin2_notfull %위아래 판단, 에러가 특정 margin 밖에 있을 때
            if error_r>0
                disp('down');
%                 movedown(droneobj,'WaitUntilDone',true);
                moveDownOn=1;
            else
                disp('up');
%                 moveup(droneobj,'WaitUntilDone',true);
                moveUpOn=1;
            end
        else
            disp('stop up down');
            UDIn_notfull=UDIn_notfull+1;
        end

        if abs(error_c)>margin2_notfull %양옆 판단, 에러가 특정 margin 밖에 있을 때
            if error_c>0
                disp('right');
%                 moveright(droneobj,'WaitUntilDone',true);
                moveRightOn=1;
            else
                disp('left');
%                 moveleft(droneobj,'WaitUntilDone',true);
                moveLeftOn=1;
            end
        else
            disp('stop right left');
            RLIn_notfull=RLIn_notfull+1;
            
        end

        if RLIn_notfull==0 || UDIn_notfull==0 || RLIn_notfull~=UDIn_notfull
            if moveUpOn==1 
                if moveRightOn==1
                    move(droneobj, [0 0.2 -0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj, [0 0.2 -0.2],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 -0.2],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj,[0 -0.2 -0.2],"Speed",0.1);');
                else
                    move(droneobj, [0 0 -0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj,[0 0 -0.2],"Speed",0.1);');
                end

            elseif moveDownOn==1
                if moveRightOn==1
                    move(droneobj, [0 0.2 0.2],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj, [0 0.2 0.2],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 0.2],"WaitUntilDone",true,"Speed",0.1);  
                     disp('move(droneobj, [0 -0.2 0.2],"Speed",0.1);');
                 else
                    move(droneobj, [0 0 0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj,[0 0 0.2],"Speed",0.1);');
                end 
            elseif moveDownOn==0 && moveUpOn==0
                if moveRightOn==1
                    move(droneobj, [0 0.2 0],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj, [0 0.2 0],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 0],"WaitUntilDone",true,'Speed',0.1);
                     disp('move(droneobj, [0 -0.2 0],"Speed",0.1);');
                end
            end
            moveDownOn=0;
            moveUpOn=0;
            moveRightOn=0;
            moveLeftOn=0;
        end

        %% 파랑생이 꽉 안찼을 때 안정적으로 중심을 찾기 위해
        % 양옆 혹은 위아래 하나만 중심을 찾았을 때
        if RLIn_notfull~=UDIn_notfull
            center_reset=1;
        end

        if center_reset==1
            UDIn_notfull=0;
            RLIn_notfull=0;
            center_reset=0;
        end

        if RLIn_notfull > 2 && UDIn_notfull > 2
            correcting_yaw=1;
            disp('correcting_yaw');
            notfullbw=bw;
            stage = 0;
        end
    
    end

    imshow(bw);
end
%% Yaw 조절
if correcting_yaw == 1
    image = snapshot(cameraObj);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B = image1B-image1R/2-image1G/2;
    bw = image_only_B > 55;
    bw_origin = bw;


    stats = regionprops(bw);
    centerIdx=1;

    if(~isempty(stats))
        for i = 1:numel(stats)
            if stats(i).Area>stats(centerIdx).Area
                centerIdx=i;
            end
        end
        rectangle('Position', stats(centerIdx).BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
        hold on;

        stat_int=uint16(stats(centerIdx).BoundingBox);
        bw(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
    end

    [row_bounding, col_bounding] = find(bw);

    cf_B=mean(col_bounding);

    bw_origin1 = imfill(bw_origin,"holes");

    [row_origin, col_origin] = find(bw_origin1);

    cf_O=mean(col_origin);

    correcting_cf = cf_B - cf_O;
    disp('correcting_cf');
    disp(correcting_cf);

    if correcting_cf > 5
        disp("turn left 10");

        turn(droneobj, deg2rad(-10));
        disp(correcting_cf);

        Center_restart = 1;

    elseif correcting_cf > 2
        disp("turn right");

        turn(droneobj, deg2rad(-5));
        disp(correcting_cf);

        Center_restart = 1;
        
    elseif correcting_cf < -5
        disp("turn right");

        turn(droneobj, deg2rad(10));
        disp(correcting_cf);

        Center_restart = 1;

    elseif correcting_cf < -2
        disp("turn right");

        turn(droneobj, deg2rad(5));
        disp(correcting_cf);

        Center_restart = 1;

    else
        disp("correcting yaw")
        Center_restart = 1;
    end

end

%% 다시 중앙 맞추고 전진
reverseOn=0;
fullgo=0;
notfullgo=0;
center_reset=1; 

while(Center_restart == 1)
    image=snapshot(cameraObj);
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B > 55;
    bw_origin=bw;

    stats = regionprops(bw);
    centerIdx=1;

    if(~isempty(stats))
        for i = 1:numel(stats)
            if stats(i).Area>stats(centerIdx).Area
                centerIdx=i;
            end
        end
        rectangle('Position', stats(centerIdx).BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');

        stat_int=uint16(stats(centerIdx).BoundingBox);
        bw(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
    end
    [row_origin, col_origin] = find(bw_origin);

    [row, col] = find(bw);

    %% 1m  until find red
    %% 파랑이 꽉찼을 때 중앙점 수렴 및 통과하는 코드
    if fullgo==1
        downCount=0;

        goCount=0;
        while 1
            goCount=goCount+1;
            if goCount<2 
                moveforward(droneobj,0.8,'WaitUntilDone',true,'Speed',1);
                disp('gocount<2 fastfast');
            else
                moveforward(droneobj,0.8,'WaitUntilDone',true,'Speed',0.8);
                disp('gocount<2 stage3');
            end

            bw=~bw_origin; % 원형만 남게

            bw = imerode(bw,se);
            bw = imdilate(bw,se);

            [row, col] = find(bw);

            rf=mean(row);
            cf=mean(col);
            viscircles([cf rf],3);

            error_c=cf-targetcenter_full(1);

            if abs(error_c)>margin2_full %양옆 판단, 에러가 특정 margin 밖에 있고 row가 맞춰지지 않았을 때 좀더 널널하게 판단
                if error_c>0
                    disp('right go');
                    moveright(droneobj,'WaitUntilDone',true,'Distance',0.2);
                else
                    disp('left go');
                    moveleft(droneobj,'WaitUntilDone',true,'Distance',0.2);
                end
            end

            image=snapshot(cameraObj);
            image1R = image(:,:,1);
            image1G = image(:,:,2);
            image1B = image(:,:,3);

            image_only_B=image1B-image1R/2-image1G/2;
            bw = image_only_B > 55;
            [row, col] = find(bw);
            if (length(row) < 50 || length(col) < 50)  %중심 찾은 경우
                stage=3;
                moveforward(droneobj,'WaitUntilDone',true,'distance',0.5);
                disp('if (length(row) < 50 || length(col) < 50)');
                break;
            end

            % 빨강 표식 크기로 종료지점 확인 파랑이 꽉찬경우
%             image=snapshot(cameraObj);
%             imageHSV=rgb2hsv(image);
%             image1H = imageHSV(:,:,1);
%             image1S = imageHSV(:,:,2);
%             image1V = imageHSV(:,:,3);
%             imageR_H = image1H <= 0.06 | image1H >= 0.94;
%             imageR_S = image1S >= 0.5 & image1S <= 1.0;
%             imageR_V = image1V >= 0.1 & image1V <= 0.9;
%             imageR_combi = imageR_H & imageR_S & imageR_V;
%             imshow(imageR_combi);
%             [rowR, colR]=find(imageR_combi);
%             if length(rowR) > 3000 %임의의 값
%                 disp('if length(rowR) > 3000 stage=3');
%                 break;
%             end

        end

        %%
        land(droneobj);
        break;

        %% 파랑이 꽉차지 않았을 때 중앙점 수렴 및 통과하는 코드
    elseif notfullgo==1 && fullgo==0
        %%  하강
        downCount=0;
        movedown(droneobj,'WaitUntilDone',true,'Distance',0.3);
        disp('movedown twice stage3_2');



        %%
        goCount=0;
        while 1 %전진반복문
                
            image=snapshot(cameraObj);
        
            image1R = image(:,:,1);
            image1G = image(:,:,2);
            image1B = image(:,:,3);
            
            image_only_B=image1B-image1R/2-image1G/2;
            bw = image_only_B > 55;
            bw_origin=bw;
            imshow(bw)
            stats = regionprops(bw);   
            centerIdx=1;
            
            if(~isempty(stats)) 
            for i = 1:numel(stats)
                if stats(i).Area>stats(centerIdx).Area
                    centerIdx=i;
                end
            end
            rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
                stat_int=uint16(stats(centerIdx).BoundingBox);
                bw(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
            end
            [row_origin, col_origin] = find(bw_origin);
        
            [row, col] = find(bw);
            disp('length(row) = ');
            disp(length(row));
            if   (length(row) > 590000 && length(col) > 590000)
                   %파랑이 꽉찾을 때 중심점 찾는 코드로 가기
                   fullimage=bw;
                   fullgo=1;
                   break;
            else
                moveforward(droneobj,'WaitUntilDone',true,'Distance',0.7);
            end



        end
        %% 파랑이 존재하지 않는다면 올라가자  안보일 때 올라가도 파랑이 안보이는 경우는 생기지 않음(아직까진)
    elseif (length(row_origin) < 50 || length(col_origin) < 50)
        disp('up stage=3 2');
        moveup(droneobj,'WaitUntilDone',true,'Distance',0.4);
        %% 파랑이 꽉찬다면
    elseif   (length(row) > 590000 && length(col) > 590000)% || reverseOn==1
        reverseOn=1;
        bw=~bw_origin;

        bw = imerode(bw,se);
                bw = imdilate(bw,se);

        [row, col] = find(bw);

        rf=mean(row);
        cf=mean(col);
        viscircles([cf rf],3);

        error_r=rf-targetcenter_full(2);
        error_c=cf-targetcenter_full(1);
        %%
        if abs(error_r)>margin2_full_ud  %위아래 판단, 에러가 특정 margin 밖에 있고, Col을 맞출 때
            if error_r>0
                disp('down full');
                movedown(droneobj,'WaitUntilDone',true);
            else
                disp('up full');
                moveup(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop up down full');
            UDIn_full=UDIn_full+1;
        end
        %%
        if abs(error_c)>margin2_full  %양옆 판단, 에러가 특정 margin 밖에 있고 row가 맞춰지지 않았을 때
            if error_c>0
                disp('right full');
                moveright(droneobj,'WaitUntilDone',true);
            else
                disp('left full');
                moveleft(droneobj,'WaitUntilDone',true);
            end
        else
            disp('stop right left full');
            RLIn_full=RLIn_full+1;
        end

        %% 파랑생이 꽉 찼을 때 안정적으로 중심을 찾기 위해
        % 양옆 혹은 위아래 하나만 중심을 찾았을 때
        if RLIn_full~=UDIn_full
            center_reset=1;
        end

        if center_reset==1
            UDIn_full=0;
            RLIn_full=0;
            center_reset=0;
        end

        if RLIn_full > 2 && UDIn_full > 2
            fullgo=1;
            disp('fullgo=1');
        end
        %% 파랑이 꽉 차지 않았을 때 파랑이 보이고 상하좌우 움직일 방향 결정
    elseif notfullgo==0 && fullgo==0%if reverseOn==0
        %% 만약 이전 파랑영역보다 현재 파랑영역이 줄어들었으면 앞으로 이동 경연때도 필요한지는 모름
%         if blue_pre > length(col_origin)+decrese_margin
%             moveforward(droneobj,'WaitUntilDone',true);
%             disp('blue is decrese');
%         end

%         blue_pre=length(col_origin);

        reverseOn=0;
        [row, col] = find(bw);
        rf=mean(row);
        cf=mean(col);
        viscircles([cf rf],3);

        error_r=rf-targetcenter_notfull(2);
        error_c=cf-targetcenter_notfull(1);

        if abs(error_r)>margin2_notfull %위아래 판단, 에러가 특정 margin 밖에 있을 때
            if error_r>0
                disp('down');
%                 movedown(droneobj,'WaitUntilDone',true);
                moveDownOn=1;
            else
                disp('up');
%                 moveup(droneobj,'WaitUntilDone',true);
                moveUpOn=1;
            end
        else
            disp('stop up down');
            UDIn_notfull=UDIn_notfull+1;
        end

        if abs(error_c)>margin2_notfull %양옆 판단, 에러가 특정 margin 밖에 있을 때
            if error_c>0
                disp('right');
%                 moveright(droneobj,'WaitUntilDone',true);
                moveRightOn=1;
            else
                disp('left');
%                 moveleft(droneobj,'WaitUntilDone',true);
                moveLeftOn=1;
            end
        else
            disp('stop right left');
            RLIn_notfull=RLIn_notfull+1;
            
        end

        if RLIn_notfull==0 || UDIn_notfull==0 || RLIn_notfull~=UDIn_notfull
            if moveUpOn==1 
                if moveRightOn==1
                    move(droneobj, [0 0.2 -0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj, [0 0.2 -0.2],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 -0.2],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj,[0 -0.2 -0.2],"Speed",0.1);');
                else
                    move(droneobj, [0 0 -0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj,[0 0 -0.2],"Speed",0.1);');
                end

            elseif moveDownOn==1
                if moveRightOn==1
                    move(droneobj, [0 0.2 0.2],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj, [0 0.2 0.2],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 0.2],"WaitUntilDone",true,"Speed",0.1);  
                     disp('move(droneobj, [0 -0.2 0.2],"Speed",0.1);');
                 else
                    move(droneobj, [0 0 0.2],"WaitUntilDone",true,"Speed",0.1);
                    disp('move(droneobj,[0 0 0.2],"Speed",0.1);');
                end 
            elseif moveDownOn==0 && moveUpOn==0
                if moveRightOn==1
                    move(droneobj, [0 0.2 0],"WaitUntilDone",true,"Speed",0.1);
                     disp('move(droneobj, [0 0.2 0],"Speed",0.1);');
                elseif moveLeftOn==1
                    move(droneobj, [0 -0.2 0],"WaitUntilDone",true,'Speed',0.1);
                     disp('move(droneobj, [0 -0.2 0],"Speed",0.1);');
                end
            end
            moveDownOn=0;
            moveUpOn=0;
            moveRightOn=0;
            moveLeftOn=0;  
        end
%         moveforward(droneobj,'WaitUntilDone',true,'Distance',0.3);
        %% 파랑생이 꽉 안찼을 때 안정적으로 중심을 찾기 위해
        % 양옆 혹은 위아래 하나만 중심을 찾았을 때
        if RLIn_notfull~=UDIn_notfull
            center_reset=1;
        end

        if center_reset==1
            UDIn_notfull=0;
            RLIn_notfull=0;
            center_reset=0;
        end

        if RLIn_notfull > 2 && UDIn_notfull > 2
            notfullgo=1;
            disp('notfullgo');
            notfullbw3_2=bw;
        end

    end

    imshow(bw);

end
