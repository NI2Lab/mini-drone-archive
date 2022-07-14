droneObj = ryze()
takeoff(droneObj);
cam = camera(droneObj);


while true
    chk = 1;
    img = snapshot(cam);
    pause(0.3);
    [pup_dot_hei, ydot, xdot] = red_tar(img)
    
    if isempty(pup_dot_hei)
        moveup(droneObj,0.2,"Speed",1,"WaitUntilDone",true);
        pause(1);
        chk = 0;
    end
    if ydot<200 & (~isempty(pup_dot_hei)& chk ==1)
        moveup(droneObj,0.2,'Speed',1,"WaitUntilDone",true);
        pause(1);
        chk = 0;
    end
    if ydot > 580 & (~isempty(pup_dot_hei)& chk ==1)
        movedown(droneObj,0.2,"Speed",1,"WaitUntilDone",true);
        pasue(1);
        chk = 0;
    end
    if xdot < 320 & (~isempty(pup_dot_hei)& chk ==1)
        moveleft(droneObj,0.2,"Speed",1,"WaitUntilDone",true);
        pause(1);
        chk = 0;
    end
    if xdot > 640 & (~isempty(pup_dot_hei)& chk ==1)
        moveright(droneObj,0.2,"Speed",1,"WaitUntilDone",true);
        pause(1);
        chk = 0;
    end
    if chk == 1
            
        if pup_dot_hei < 50
            moveforward(droneObj,0.3,"Speed",1,"WaitUntilDone",true);
        else
            break
        end
    end
end
turn(droneObj,deg2rad(90));
moveforward(droneObj,0.9,"Speed",1,"WaitUntilDone",true);
turn(droneObj,deg2rad(45));
while true
    subplot(1,2,2);
    img = snapshot(cam);
    pause(0.3);
    imshow(img);
    [hei, ydot, xdot] = red_tar(img)
    if isempty(hei) | hei ==0
        turn(droneObj,deg2rad(10));
        moveright(droneObj,0.2,"Speed",1,"WaitUntilDone",true);
    else
        break
    end
end


land(droneObj);
function [hei, ydot, xdot] = red_tar(im)
    [row, col, X] = size(im);
    img2 = im;
    for i = 1:row 
        for j=1:col
            if im(i,j,1) - im(i,j,2) < 50 | im(i,j,1) - im(i,j,3) <50
                img2(i,j,1) = 0;
                img2(i,j,2) = 0;
                img2(i,j,3) = 0;
            else
                img2(i,j,1) = 254;
                img2(i,j,2) = 0;
                img2(i,j,3) = 0;
            end
        end
    end
    subplot(1,2,1);
    imshow(img2)
    r = rgb2gray(img2);
    can = corner(r);
    hei = round(max(can)-min(can));
    ydot = can(:,2);
    xdot = can(:,1);
    if isempty(hei)
        hei = zeros(1);
        ydot = zeros(1);
        xdot = zeros(1);
    end
    

end