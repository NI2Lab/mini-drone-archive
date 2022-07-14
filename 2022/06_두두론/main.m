% 0단계
dist_forward = 0.3;
dist_backward = 0.4;
dist_pass = 1.2;
Ddist_udlr = 0.2;
Rdist_udlr = 0.25;
Rdist_add_forward = 0.8;
height = 1.0;

droneObj = ryze()
cam = camera(droneObj);
takeoff(droneObj);


% 1단계
moveup(droneObj,'Distance', 0.3,'WaitUntilDone', true);
moveforward(droneObj, 'Distance', 1.2, 'WaitUntilDone', true);

findGreenDot = false;
moveforward(droneObj, 'Distance', dist_forward, 'WaitUntilDone', true);
while(~findGreenDot)
    frame = snapshot(cam);
    frame = rgb2hsv(frame);
    h = frame(:,:,1); detect_h = (h >= 0.2) & (h <= 0.42);
    s = frame(:,:,2); detect_s = (s >= 0.1) & (s <= 0.76);
    detect_Gdot = detect_h & detect_s;
    canny_img = edge(detect_Gdot, 'Canny', 0.9, 8);
    fill_img = imfill(canny_img, 'holes');
    green_sum = sum(sum(fill_img));

    detecting = false;
    if green_sum < 50
        moveback(droneObj,'Distance', dist_backward,'WaitUntilDone', true);
        continue;
    elseif green_sum >= 4000
        turn(droneObj, deg2rad(90));
        moveforward(droneObj, 'Distance', dist_pass, 'WaitUntilDone', true);
        findGreenDot = true;
    elseif green_sum >= 2000
        g_center = sum(sum(fill_img(fix(end/3):fix(end/3 * 2), fix(end/3):fix(end/3 * 2))));
        if g_center < 2000
            detecting = true;
        end
    elseif green_sum >= 300
        detecting = true;
    end

    if (detecting)
        g_lst = [sum(sum(fill_img(1:fix(end/4*3), 1:end)))
                 sum(sum(fill_img(fix(end/4):end, 1:end)))
                 sum(sum(fill_img(1:end, 1:fix(end/3*2))))
                 sum(sum(fill_img(1:end, fix(end/3):end)))];
        if abs(g_lst(1) - g_lst(2)) > 100
            if g_lst(1) >= g_lst(2) 
                moveup(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
                height = height + Ddist_udlr;
            else
                movedown(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
                height = height - Ddist_udlr;
            end
        end
        if abs(g_lst(3) - g_lst(4)) > 100
            if g_lst(3) >= g_lst(4)
                moveleft(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            else
                moveright(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            end
        end
    end
    
    if (~findGreenDot)
        moveforward(droneObj, 'Distance', dist_forward, 'WaitUntilDone', true);
    end
end


% 2단계
findRightPos = false;
while(~findRightPos)
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    detect_Brect = detect_r & detect_g & detect_b;  

    if (sum(sum(detect_Brect)) <= 100)
        turn(droneObj, deg2rad(-45));
        frame = snapshot(cam);
        r = frame(:,:,1);   detect_r = (r < 50);   
        g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
        b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
        detect_Brect = detect_r & detect_g & detect_b;
        sum1 = sum(sum(detect_Brect));

        turn(droneObj, deg2rad(90));
        frame = snapshot(cam);
        r = frame(:,:,1);   detect_r = (r < 50);   
        g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
        b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
        detect_Brect = detect_r & detect_g & detect_b;
        sum2 = sum(sum(detect_Brect));
        
        turn(droneObj, deg2rad(-45));
        if sum1 >= sum2
            moveleft(droneObj, 'Distance', 0.5, 'WaitUntilDone', true);
        else
            moveright(droneObj, 'Distance', 0.5, 'WaitUntilDone', true);
        end
        continue;
    end

    B_lst = [sum(sum(detect_Brect(1:fix(end/2), 1:end))) 
             sum(sum(detect_Brect(fix(end/2):end, 1:end)))
             sum(sum(detect_Brect(1:end, 1:fix(end/2))))  
             sum(sum(detect_Brect(1:end, fix(end/2):end)))];
    ratio1 = min(B_lst(1), B_lst(2)) / max(B_lst(1), B_lst(2));
    ratio2 = min(B_lst(3), B_lst(4)) / max(B_lst(3), B_lst(4));

    if((ratio1 >= 0.7) && (ratio2 >= 0.7))
        movedown(droneObj, 'Distance', 0.4, 'WaitUntilDone', true);
        height = height - 0.4;
        moveforward(droneObj, 'Distance', Rdist_add_forward, 'WaitUntilDone', true);
        findRightPos = true;
    else
        b_center = sum(sum(detect_Brect(fix(end/3):fix(end/3 * 2), fix(end/3):fix(end/3 * 2))));
        if b_center >= 70000
            moveback(droneObj,'Distance', dist_backward,'WaitUntilDone', true);
        else
            if ratio1 < 0.3
                if B_lst(1) >= B_lst(2)
                    moveup(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                    height = height + Rdist_udlr * 2;
                else
                    movedown(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                    height = height - Rdist_udlr * 2;
                end
            elseif ratio1 < 0.7
                if B_lst(1) >= B_lst(2)
                    moveup(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                    height = height + Rdist_udlr;
                else
                    movedown(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                    height = height - Rdist_udlr;
                end
            end
            if ratio2 < 0.3
                if B_lst(3) >= B_lst(4)
                    moveleft(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                else
                    moveright(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                end
            elseif ratio2 < 0.7
                if B_lst(3) >= B_lst(4)
                    moveleft(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                else
                    moveright(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                end
            end
        end
    end
end

findPurpleDot = false;
moveforward(droneObj, 'Distance', dist_forward, 'WaitUntilDone', true);
while(~findPurpleDot)
    frame = snapshot(cam);
    frame = rgb2hsv(frame);
    h = frame(:,:,1); detect_h = (h >= 0.69) & (h <= 0.8);
    s = frame(:,:,2); detect_s = (s >= 0.1) & (s <= 0.7);
    detect_Pdot = detect_h & detect_s;
    canny_img = edge(detect_Pdot, 'Canny', 0.9, 9);
    fill_img = imfill(canny_img, 'holes');
    purple_sum = sum(sum(fill_img));
    
    detecting = false;
    if purple_sum == 0
        moveback(droneObj,'Distance', dist_backward,'WaitUntilDone', true);
        continue;
    elseif purple_sum >= 4000
        turn(droneObj, deg2rad(90));
        moveforward(droneObj, 'Distance', dist_pass, 'WaitUntilDone', true);
        findPurpleDot = true;
    elseif purple_sum >= 600
        detecting = true;
    end

    if (detecting)
        p_lst = [sum(sum(fill_img(1:fix(end/4*3), 1:end)))
                 sum(sum(fill_img(fix(end/4):end, 1:end)))
                 sum(sum(fill_img(1:end, 1:fix(end/3*2))))
                 sum(sum(fill_img(1:end, fix(end/3):end)))];
        if abs(p_lst(1) - p_lst(2)) > 100
            if p_lst(1) >= p_lst(2)
                moveup(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
                height = height + Ddist_udlr;
            else
                movedown(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
                height = height - Ddist_udlr;
            end
        end
        if abs(p_lst(3) - p_lst(4)) > 100
            if p_lst(3) >= p_lst(4)
                moveleft(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            else
                moveright(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            end
        end
    end
    
    if (~findPurpleDot)
        moveforward(droneObj, 'Distance', dist_forward, 'WaitUntilDone', true);
    end
end


% 3단계
if height <= 0.75
    moveup(droneObj,'Distance', 0.7,'WaitUntilDone', true);
end
turn(droneObj, deg2rad(30));

max_sum = 0;
for index=1:4
    if index > 1
        turn(droneObj, deg2rad(10));
    end

    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    detect_Brect = detect_r & detect_g & detect_b;
    sum_blue = sum(sum(detect_Brect));

    if sum_blue > max_sum
        max_sum = sum_blue;
        max_index = index;
    end
end
turn_radi = (-1) * 10 * (4 - max_index);
turn(droneObj, deg2rad(turn_radi));
moveforward(droneObj, 'Distance', 0.4, 'WaitUntilDone', true);

findRightPos = false;
while(~findRightPos)
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    detect_Brect = detect_r & detect_g & detect_b;

    if (sum(sum(detect_Brect)) <= 100)
        turn(droneObj, deg2rad(-45));
        frame = snapshot(cam);
        r = frame(:,:,1);   detect_r = (r < 50);   
        g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
        b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
        detect_Brect = detect_r & detect_g & detect_b;
        sum1 = sum(sum(detect_Brect));

        turn(droneObj, deg2rad(90));
        frame = snapshot(cam);
        r = frame(:,:,1);   detect_r = (r < 50);   
        g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
        b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
        detect_Brect = detect_r & detect_g & detect_b;
        sum2 = sum(sum(detect_Brect));
        
        turn(droneObj, deg2rad(-45));
        if sum1 >= sum2
            moveleft(droneObj, 'Distance', 0.5, 'WaitUntilDone', true);
        else
            moveright(droneObj, 'Distance', 0.5, 'WaitUntilDone', true)
        end
        continue;
    end

    B_lst = [sum(sum(detect_Brect(1:fix(end/2), 1:end))) 
             sum(sum(detect_Brect(fix(end/2):end, 1:end)))
             sum(sum(detect_Brect(1:end, 1:fix(end/2))))  
             sum(sum(detect_Brect(1:end, fix(end/2):end)))];
    ratio1 = min(B_lst(1), B_lst(2)) / max(B_lst(1), B_lst(2));
    ratio2 = min(B_lst(3), B_lst(4)) / max(B_lst(3), B_lst(4));
    
    if((ratio1 >= 0.7) && (ratio2 >= 0.7))
        movedown(droneObj, 'Distance', 0.4, 'WaitUntilDone', true);
        moveforward(droneObj, 'Distance', Rdist_add_forward, 'WaitUntilDone', true);
        findRightPos = true;
    else
        b_center = sum(sum(detect_Brect(fix(end/3):fix(end/3 * 2), fix(end/3):fix(end/3 * 2))));
        if b_center >= 70000
            moveback(droneObj,'Distance', dist_backward,'WaitUntilDone', true);
        else
            if ratio1 < 0.3
                if B_lst(1) >= B_lst(2)
                    moveup(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                else
                    movedown(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                end
            elseif ratio1 < 0.7
                if B_lst(1) >= B_lst(2) 
                    moveup(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                else
                    movedown(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                end
            end
            if ratio2 < 0.3
                if B_lst(3) >= B_lst(4)
                    moveleft(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                else
                    moveright(droneObj,'Distance', Rdist_udlr * 2,'WaitUntilDone', true);
                end
            elseif ratio2 < 0.7
                if B_lst(3) >= B_lst(4)
                    moveleft(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                else
                    moveright(droneObj,'Distance', Rdist_udlr,'WaitUntilDone', true);
                end
            end
        end
    end
end

findRedDot = false;
moveforward(droneObj, 'Distance', dist_forward, 'WaitUntilDone', true);
while(~findRedDot)
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 80) & (r < 200);
    g = frame(:,:,2);   detect_g = (g < 55);
    b = frame(:,:,3);   detect_b = (b < 80);
    detect_Rdot = detect_r & detect_g & detect_b;
    red_sum = sum(sum(detect_Rdot));

    detecting = false;
    if red_sum < 50
        moveback(droneObj,'Distance', dist_backward,'WaitUntilDone', true);
        continue;
    elseif red_sum >= 4000
        land(droneObj);
        findRedDot = true;
    elseif red_sum >= 300
        detecting = true;
    end

    if (detecting)
        r_lst = [sum(sum(detect_Rdot(1:fix(end/4*3), 1:end)))
                 sum(sum(detect_Rdot(fix(end/4):end, 1:end)))
                 sum(sum(detect_Rdot(1:end, 1:fix(end/3*2))))
                 sum(sum(detect_Rdot(1:end, fix(end/3):end)))];
        if abs(r_lst(1) - r_lst(2)) > 100
            if r_lst(1) >= r_lst(2) 
                moveup(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            else
                movedown(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            end
        end
        if abs(r_lst(3) - r_lst(4)) > 100
            if r_lst(3) >= r_lst(4)
                moveleft(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            else
                moveright(droneObj,'Distance', Ddist_udlr,'WaitUntilDone', true);
            end
        end
    end
    
    if (~findRedDot)
        moveforward(droneObj, 'Distance', dist_forward, 'WaitUntilDone', true);
    end
end
