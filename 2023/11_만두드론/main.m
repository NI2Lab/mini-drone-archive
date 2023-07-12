clc
clear all
close all


drone = ryze("Tello");
cam = camera(drone);
preview(cam);

takeoff(drone);
pause(1);
disp("take off");

forward_seq = 0;
findcircle = 0;

%원 찾음 여기까진 됨
while 1
    frame = snapshot(cam);
    subplot(2,1,1),subimage(frame);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    k = (0.5<h)&(h<0.6); %pannel
    k_fill = imfill(k, "holes");
    circle = k_fill - k;
    
    if sum(circle,"all")>14000
        disp("find circle!!");
        imshow(circle);
        [x,y] = find(circle(:,:)==1);
        size_y = size(y)
        
        col = y(round(size_y(2)/2)+90);
        row = min(find(circle(:,col)));
        
        boundary = bwtraceboundary(circle, [row, col],"N");
        
        hold on;
        plot(boundary(:,2), boundary(:,1),'g','LineWidth',3);
        
        midpoint_pannel = median(boundary);
        hold on;
        plot(midpoint_pannel(2), midpoint_pannel(1),'b*');
        break;
    elseif sum(k,"all")>14000
        disp("exist pannel: moveup");
        moveup(drone,"Distance",0.2);
    else
        disp("nothing");
    end
end


%중심 맞춰 움직이기
while 1
    frame = snapshot(cam);
    subplot(2,1,1),subimage(frame);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    k = (0.5<h)&(h<0.6); %pannel
    k_fill = imfill(k, "holes");
    circle = k_fill - k;
    imshow(circle);
    [x,y] = find(circle(:,:)==1);
    size_y = size(y)
        
    col = y(round(size_y(2)/2)+90);
    row = min(find(circle(:,col)));
    
    boundary = bwtraceboundary(circle, [row, col],"N");
    
    hold on;
    plot(boundary(:,2), boundary(:,1),'g','LineWidth',3);
    
    midpoint_pannel = median(boundary);
    hold on;
    plot(midpoint_pannel(2), midpoint_pannel(1),'b*');
    size_img = size(frame);
    if (midpoint_pannel(2)<=size_img(2)/3)&&(midpoint_pannel(1)<=size_img(1)/3)
        disp("region 1");
        moveleft(drone,"Distance",0.2);
        pause(1);
        disp("moveleft");

    elseif (size_img(2)/3<midpoint_pannel(2))&&(midpoint_pannel(2)<=2*size_img(2)/3)&&(midpoint_pannel(1)<=size_img(1)/3)
        disp("region 2");
        moveforward(drone,"Distance",1);
        pause(1);
        % forward_seq = forward_seq + 1;
        % if forward_seq == 5
        %     disp("move forward 1m");
        %     break;
        % end
        disp("moveforward");
        %forward_seq = forward_seq+1;
        break;

    elseif (2*size_img(2)/3<midpoint_pannel(2))&&(midpoint_pannel(2)<=size_img(2))&&(midpoint_pannel(1)<=size_img(1)/3)
        disp("region 3");
        moveright(drone,"Distance",0.2);
        pause(1);
        disp("moveright");

    elseif (midpoint_pannel(2)<=size_img(2)/3)&&(size_img(1)/3<midpoint_pannel(1))&&(midpoint_pannel(1)<=2*size_img(1)/3)
        disp("region 4");
        movedown(drone,"Distance",0.2);
        pause(1);
        moveleft(drone,"Distance",0.2);
        pause(1);
        disp("movedown and moveleft");

    elseif (size_img(2)/3<midpoint_pannel(2))&&(midpoint_pannel(2)<=2*size_img(2)/3)&&(size_img(1)/3<midpoint_pannel(1))&&(midpoint_pannel(1)<=2*size_img(1)/3)
        disp("region 5");
        movedown(drone, "Distance",1);
        pause(1);
        disp("movedown");
    elseif (2*size_img(2)/3<midpoint_pannel(2))&&(midpoint_pannel(2)<=size_img(2))&&(size_img(1)/3<midpoint_pannel(1))&&(midpoint_pannel(1)<=2*size_img(1)/3)
        disp("region 6");
        movedown(drone, "Distance",0.2);
        pause(1);
        moveright(drone,"Distance",0.2);
        pause(1);
        disp("movedown and moveright");
        
    elseif (midpoint_pannel(2)<=size_img(2)/3)&&(2*size_img(1)/3<midpoint_pannel(1))&&(midpoint_pannel(1)<=size_img(1))
        disp("region 7");
        movedown(drone,"Distance",0.4);
        pause(1);
        moveleft(drone,"Distance",0.2);
        pause(1);
        disp("movedownx2 and moveleft");

    elseif (size_img(2)/3<midpoint_pannel(2))&&(midpoint_pannel(2)<=2*size_img(2)/3)&&(2*size_img(1)/3<midpoint_pannel(1))&&(midpoint_pannel(1)<=size_img(1))
        disp("region 8");
        movedown(drone,"Distance",0.4);
        pause(1);
        disp("movedownx2");

    elseif (2*size_img(2)/3<midpoint_pannel(2))&&(midpoint_pannel(2)<=size_img(2))&&(2*size_img(1)/3<midpoint_pannel(1))&&(midpoint_pannel(1)<=size_img(1))
        disp("region 9");
        movedown(drone,"Distance",0.4);
        pause(1);
        moveright(drone,"Distance",0.2);
        pause(1);
        disp("movedownx2 and moveright");
    end

end

land(drone);
