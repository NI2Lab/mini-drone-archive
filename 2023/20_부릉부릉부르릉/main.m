clear all;
close;
droneobj = ryze()
cameraObj = camera(droneobj);

stage=0;
targetcenter_notfull=[480 250];%[480 300];
targetcenter_full=[480 260];%[480 240];
count=0;
reverse_th=650000;
figure();hold on;
takeoff(droneobj);
print_on=0;

%% pause(0.5);

% 원하는 높이만큼 띄우는 코드
dist=readHeight(droneobj); %0.2가 가장 극단적 %1.7
disp(dist);
uptarget=1.1-dist;

if uptarget>=0.2
    moveup(droneobj,'Distance',uptarget,'WaitUntilDone',true);
elseif uptarget <= -0.2
    movedown(droneobj,'Distance',abs(uptarget),'WaitUntilDone',true); 
end


%%

% 비행을 위해 바뀌는 변수
blue_full=0;
margin_notfull=[40,40]; % 가로, 세로
margin_full=[40,40];
hovering=100;
move_ref=[0,0];
convert_pixel2ply=[40,40];
rf=480;
cf=360;
reverseOn=0;
se = strel('disk',50);
center_in=0;
stage_in=0;
target_on=0;
stage_up_count=0;
large_circle_pre=100;
while(stage==0)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull);
        stage_in=1;
        center_in=0;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        disp("stage0 init");
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);

    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
        if move_ref(1)==1
            stage_up_count=stage_up_count+1;
        elseif move_ref(1)==-1
            stage_up_count=stage_up_count-1;
        end
    end
%         
    if center_in
        stage=goThroughCircle(droneobj,stage,2.3);
        stage_in=0;
    end
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
    
end
while(stage==1)
    if stage_in==0
        disp("previous up count="+stage_up_count);
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_up_count=0;
        stage_in=1;
        center_in=0;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        disp("stage1 init");
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);
        
    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
    end
%         
    if center_in
        stage=goThroughCircle(droneobj,stage,2.5);
        stage_in=0;
    end
    
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
    
    
end

while(stage==2)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_in=1;
        center_in=0;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        disp("stage2 init");
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw;
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats))
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);

    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
    end
%         
    if center_in
        stage=goThroughCircle(droneobj,stage,2.1);
        stage_in=0;
    end
    
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
    
    
end

while(stage==3)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_in=1;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        center_in=0;
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw;
    % bw_fill(:,:)=0;
    bw_show=bw;

    stats = regionprops(bw);   
    centerIdx=1;

    if(~isempty(stats)) 
        target_on=1;
        bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    else
        target_on=0;
    end
    [row_fill, col_fill] = find(bw_fill);

    [row, col] = find(bw);

    % centers
    % radii
    % if hovering<0
    %     hovering=hovering-1;
    %     continue;
    % elseif hovering==0
    %     hovering=hovering-1;
    %     disp("hovering end")
    % end
        
    
    if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
        blue_full=1;
    else
        blue_full=0;
        % bw_show=bw_fill;
    end

    if blue_full==0 && target_on==1
        [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    elseif blue_full==1
        
        reverseOn=1;
        bw=~bw;
        
        bw = imerode(bw,se); %밖으로 미는것
        % bw = imdilate(bw,se); %안으로 미는것
        
        [row, col] = find(bw);
        [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
        

        bw_show=bw;
    end
    if mean(abs(move_ref))
        move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
    end
%         
    if center_in
        % stage=goLand(droneobj,stage,image);
        stage=goThroughCircle(droneobj,stage,0.7);
        stage_in=0;
    end
    
    if print_on==1
        imshow(bw_show);
        viscircles([cf,rf],3,'Color','red');
        if blue_full==0
            rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
                targetcenter_notfull(2)-margin_notfull(2), ...
                margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
            if (~isempty(stats)) 
                rectangle('Position', stats(centerIdx).BoundingBox, ...
                    'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');
            end
        else
            rectangle("Position",[targetcenter_full(1)-margin_full(1), ...
                targetcenter_full(2)-margin_full(2), ...
                margin_full(1)*2 ,margin_full(2)*2 ],'EdgeColor','g',"LineWidth",4);
        end
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end
end

while(stage==4)
    if stage_in==0
        [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count);
        stage_in=1;
        disp(targetcenter_full);
        disp(targetcenter_notfull);
        center_in=0;
    end
    count=count+1;
    image=snapshot(cameraObj);
    if(isempty(image))
        disp("next step");
        continue;
    end
    nRows = size(image, 1);
    nCols = size(image, 2);

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);

    image_only_B=image1B-image1R/2-image1G/2;
    bw = image_only_B >63;
    bw_fill=logical(zeros(720,960));%bw;
    % bw_fill(:,:)=0;
    bw_show=bw;

    % stats = regionprops(bw);   
    % centerIdx=1;
    % 
    % if(~isempty(stats)) 
    %     target_on=1;
    %     bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx);
    % else
    %     target_on=0;
    % end
    % [row_fill, col_fill] = find(bw_fill);
    % 
    % [row, col] = find(bw);
    
    if (~isempty(bw))
        [centers,radii]=imfindcircles(bw,[100,400],"ObjectPolarity","dark","Sensitivity",0.98);
    end
    centerIdx=1;
    find_circle=0;
    if (~isempty(radii))
        find_circle=1;
        for i = 1:numel(radii)
            if radii(i)>radii(centerIdx)
                centerIdx=i;
            end 
        end
        if numel(radii)==1
            cf=centers(1);
            rf=centers(2);
        else
            cf=centers(centerIdx,1);
            rf=centers(centerIdx,2);
        end
        if abs(large_circle_pre-radii(centerIdx))>50
            find_circle=0;
        end
        large_circle_pre=radii(centerIdx);
        
        disp("large radii="+radii(centerIdx));
    end
    go=0;
    if find_circle==1
        [move_ref,center_in]=goWhere_circle(rf,cf,targetcenter_notfull,convert_pixel2ply,margin_notfull);
        if mean(abs(move_ref))
            move(droneobj, [0 move_ref(2)*0.2 -move_ref(1)*0.2],"WaitUntilDone",true,"Speed",0.1);
        end
        
        
        if radii(centerIdx)> 190 && radii(centerIdx) < 220
            stage=stage+1;
            stage_in=0;
        elseif radii(centerIdx) >= 220
            go=-1;
        else
            go=1;
        end
    end

    if center_in
        if go==1
            moveforward(droneobj,'WaitUntilDone',true,'distance',0.21);
        else
            moveback(droneobj,'WaitUntilDone',true,'distance',0.21);
        end
        % move(droneobj, [go*0.2 0 0],"WaitUntilDone",true,"Speed",1);
    end


    % 
    % if (length(row_fill) > reverse_th && length(col_fill) > reverse_th)
    %     blue_full=1;
    % else
    %     blue_full=0;
    %     % bw_show=bw_fill;
    % end
    % 
    % if blue_full==0 && target_on==1
    %     [move_ref,rf,cf,center_in]=goWhere(row_fill,col_fill,targetcenter_notfull,convert_pixel2ply,margin_notfull);
    % elseif blue_full==1
    % 
    %     reverseOn=1;
    %     bw=~bw;
    % 
    %     bw = imerode(bw,se); %밖으로 미는것
    %     % bw = imdilate(bw,se); %안으로 미는것
    % 
    %     [row, col] = find(bw);
    %     [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter_full,convert_pixel2ply,margin_full);
    % 
    % 
    %     bw_show=bw;
    % end
    
%         
    
    
    if print_on==1
        imshow(bw_show);
        if (~isempty(centers)) && find_circle==1
            if numel(radii)==1
                viscircles(centers,radii);
            else
                viscircles(centers(centerIdx,:),radii(centerIdx,:));
            end
        end     
        viscircles([cf,rf],3,'Color','red');
        
        rectangle("Position",[targetcenter_notfull(1)-margin_notfull(1), ...
            targetcenter_notfull(2)-margin_notfull(2), ...
            margin_notfull(1)*2 ,margin_notfull(2)*2 ],'EdgeColor','b',"LineWidth",4);
      
        image_n="./ply_image/step"+count+".png";
        saveas(gcf,image_n);
    end

end

while(stage==5)

    disp("stage=5");
    land(droneobj);
    % abort(droneobj);
end

function bw_fill=bw_fill_rectangle(bw_fill,stats,centerIdx)
    for i = 1:numel(stats)
        if stats(i).Area>stats(centerIdx).Area
            centerIdx=i;
        end
    end
    % rectangle('Position', stats(centerIdx).BoundingBox, ...
    %     'Linewidth', 3, 'EdgeColor', 'b', 'LineStyle', '--');

    stat_int=uint16(stats(centerIdx).BoundingBox);
    bw_fill(stat_int(2):stat_int(2)+stat_int(4),stat_int(1):stat_int(1)+stat_int(3))=1;
end

function stage=goLand(droneobj,stage,image)
    

    moveforward(droneobj,'WaitUntilDone',true,'distance',0.5,'Speed',1);
    disp("moveforward");
    stage=stage+1;
end

function [move_ref,center_in]=goWhere_circle(rf,cf,targetcenter,convert_pixel2ply,margin)
    
    error_r=rf-targetcenter(2);
    error_c=cf-targetcenter(1);
    move_ref(1)=0;
    move_ref(2)=0;
    center_r=0;
    center_c=0;
    center_in=0;
    if abs(error_r)>margin(2) %위아래 판단, 에러가 특정 margin 밖에 있을 때
        if error_r>0
            disp('down');
            move_ref(1)=-1;
            center_r=0;
        else
            disp('up');
            move_ref(1)=1;
            center_r=0;
        end
    else
        disp('stop up down');
        center_r=1;
        % UDIn_notfull=UDIn_notfull+1;
    end
    
    if abs(error_c)>margin(1) %양옆 판단, 에러가 특정 margin 밖에 있을 때
        if error_c>0
            disp('right');
            move_ref(2)=1;
            center_c=0;
        else
            disp('left');
            move_ref(2)=-1;
            center_c=0;
        end
    else
        disp('stop right left');
        center_c=1;
        % RLIn_notfull=RLIn_notfull+1;
    end

    if center_c && center_r
        center_in=1;
    end
end

function [move_ref,rf,cf,center_in]=goWhere(row,col,targetcenter,convert_pixel2ply,margin)
    rf=mean(row);
    cf=mean(col);
    %viscircles([cf rf],3);

    error_r=rf-targetcenter(2);
    error_c=cf-targetcenter(1);
    move_ref(1)=0;
    move_ref(2)=0;
    center_r=0;
    center_c=0;
    center_in=0;
    if abs(error_r)>margin(2) %위아래 판단, 에러가 특정 margin 밖에 있을 때
        if error_r>0
            disp('down');
            move_ref(1)=-1;
            center_r=0;
        else
            disp('up');
            move_ref(1)=1;
            center_r=0;
        end
    else
        disp('stop up down');
        center_r=1;
        % UDIn_notfull=UDIn_notfull+1;
    end
    
    if abs(error_c)>margin(1) %양옆 판단, 에러가 특정 margin 밖에 있을 때
        if error_c>0
            disp('right');
            move_ref(2)=1;
            center_c=0;
        else
            disp('left');
            move_ref(2)=-1;
            center_c=0;
        end
    else
        disp('stop right left');
        center_c=1;
        % RLIn_notfull=RLIn_notfull+1;
    end

    if center_c && center_r
        center_in=1;
    end
end

function stage=goThroughCircle(droneobj,stage,dis)
    moveforward(droneobj,'WaitUntilDone',true,'distance',dis,'Speed',1);
    disp("moveforward");
    stage=stage+1;
end

function [targetcenter_full,targetcenter_notfull]=stage_init(stage,droneobj,targetcenter_full,targetcenter_notfull,stage_up_count)
    switch stage
        case 0
            moveback(droneobj,'WaitUntilDone',true,'distance',0.5);
        case 1
            turn(droneobj,deg2rad(90));
            moveback(droneobj,'WaitUntilDone',true,'distance',0.6);
            if(stage_up_count>2)
                move(droneobj, [0 0 0.4],"WaitUntilDone",true,"Speed",0.1);
            end
            targetcenter_notfull(1)=480;
            targetcenter_notfull(2)=260;
        case 2
            turn(droneobj,deg2rad(90));
            moveback(droneobj,'WaitUntilDone',true,'distance',0.6);
        case 3
            turn(droneobj,deg2rad(45));
            moveforward(droneobj,'WaitUntilDone',true,'distance',1);
        case 4
            targetcenter_notfull(1)=480;
            targetcenter_notfull(2)=260;
        otherwise
            disp("other");
    end
        
end
