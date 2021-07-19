function [timer, function_switch, dot_lost_count, process] = dot_tracking(t,c, timer, function_switch, dot_lost_count, process)
offset = 100;
timer_limit = 3;

img = snapshot(c);
img_hsv = rgb2hsv(img);
land_hsv = rgb2hsv(0,65,135);
turn_hsv = rgb2hsv(150,50,50);
blue_binary = zeros(720,960);
red_binary = zeros(720,960);
for i = 1:720
    for j = 1:960
        if abs(img_hsv(i,j,1) - land_hsv(1,1,1)) <= 0.05 && abs(img_hsv(i,j,2) - land_hsv(1,1,2)) <= 0.3
            blue_binary(i,j) = 1;
        else
            blue_binary(i,j) = 0;
        end
        if abs(img_hsv(i,j,1) - turn_hsv(1,1,1)) <= 0.05 && abs(img_hsv(i,j,2) - turn_hsv(1,1,2)) <= 0.3
            red_binary(i,j) = 1;
        else
            red_binary(i,j) = 0;
        end
    end
end
blue_binary = medfilt2(blue_binary);
red_binary = medfilt2(red_binary);

blue_area = sum(blue_binary,'all');
red_area = sum(red_binary,'all');

if process == 1
    if red_area < 10 && blue_area < 10
        if dot_lost_count == 0
            moveup(t,'Distance', 0.3)
            dot_lost_count = 1;
        elseif dot_lost_count == 1
            moveleft(t,'Distance',0.3)
            dot_lost_count = 2;
        elseif dot_lost_count == 2
            movedown(t,'Distance', 0.3)
            dot_lost_count = 3;
        elseif dot_lost_count == 3
            movedown(t,'Distance',0.3)
            dot_lost_count = 4;
        elseif dot_lost_count == 4
            moverigth(t,'Distance',0.3)
            dot_lost_count = 5;
        elseif dot_lost_count == 5
            moveright(t,'Distance',0.3)
            dot_lost_count = 6;
        elseif dot_lost_count == 6
            moveup(t,'Distance',0.3)
            dot_lost_count = 7;
        elseif dot_lost_count == 7
            moveup(t,'Distance',0.3)
            dot_lost_count = 8;
        elseif dot_lost_count == 8
            moveleft(t,'Distance',0.3)
            dot_lost_count = 1;
        end
    else
        if red_area >= blue_area
            [row, col] = find(red_binary);
            yc = round(mean(row));
            xc = round(mean(col));
            rowOffset = round(720/2.8) - yc;
            colOffset = (768/2) - xc;
            
            if timer < timer_limit
                if(colOffset < -offset)
                    timer = 0;
                    moveright(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end
                    
                elseif(colOffset  > offset)
                    timer = 0;
                    moveleft(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end
                    
                elseif(rowOffset > offset)
                    timer = 0;
                    moveup(t, 'Distance', 0.2)
                    
                elseif(rowOffset < -offset)
                    timer = 0;
                    movedown(t, 'Distance', 0.2)
                    
                else
                    timer = timer + 1;
                end
            else
                process = 2;
            end
            
            
        else
            
            [row, col] = find(blue_binary);
            yc = round(mean(row));
            xc = round(mean(col));
            rowOffset = round(720/2.8) - yc;
            colOffset = (768/2) - xc;
            
            if timer < timer_limit
                if(colOffset < -offset)
                    timer = 0;
                    moveright(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end
                    
                elseif(colOffset  > offset)
                    timer = 0;
                    moveleft(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end
                    
                elseif(rowOffset > offset)
                    timer = 0;
                    moveup(t, 'Distance', 0.2)
                    
                elseif(rowOffset < -offset)
                    timer = 0;
                    movedown(t, 'Distance', 0.2)
                else
                    timer = timer + 1;
                end
            else
                process = 2;
                timer = 0;
            end
        end
    end
elseif process == 2
    if blue_area > red_area
        if blue_area < 25
            moveforward(t,'Distance',2.4)
        elseif blue_area < 35
            moveforward(t,'Distance',2.2)
        elseif blue_area < 50
            moveforward(t,'Distance',2)
        elseif blue_area < 60
            moveforward(t,'Distance',1.8)
        elseif blue_area < 70
            moveforward(t,'Distance',1.6)
        elseif blue_area < 85
            moveforward(t,'Distance',1.4)
        elseif blue_area < 125
            moveforward(t,'Distance',1.2)
        elseif blue_area < 240
            moveforward(t,'Distance',1)
        elseif blue_area < 290
            moveforward(t,'Distance',0.8)
        else
            moveforward(t,'Distance',0.6)
        end
        
        land(t)
    else
        if red_area < 25
            moveforward(t,'Distance',2.4)
        elseif red_area < 35
            moveforward(t,'Distance',2.2)
        elseif red_area < 50
            moveforward(t,'Distance',2)
        elseif red_area < 60
            moveforward(t,'Distance',1.8)
        elseif red_area < 70
            moveforward(t,'Distance',1.6)
        elseif red_area < 85
            moveforward(t,'Distance',1.4)
        elseif red_area < 125
            moveforward(t,'Distance',1.2)
        elseif red_area < 240
            moveforward(t,'Distance',1)
        elseif red_area < 290
            moveforward(t,'Distance',0.8)
        else
            moveforward(t,'Distance',0.6)
        end
        
        function_switch = 1;
        process = 1;
        timer = 0;
        turn(t,deg2rad(-90));
        pause(1)
        moveforward(t,'Speed',1,'Distance',1.5)
    end
end
end