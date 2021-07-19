function [timer, function_switch, side_lean, ring_lost_count] = ring_tracking(t, c, timer, function_switch, side_lean, ring_lost_count)
offset = 50;
timer_limit = 3;

img = snapshot(c);
size_img = size(img);

if size_img(3) == 3
    hsv_ring = rgb2hsv(84,134,51);
    hsv_img = rgb2hsv(img);
    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    
    ring_binary = zeros(720,768);
    
    for i = 1:720
        for j = 97:1:864
            if abs(h(i,j) - hsv_ring(1)) < 0.03 && abs(s(i,j) - hsv_ring(2)) < 0.25
                ring_binary(i,j-96) = 1;
            else
                ring_binary(i,j-96) = 0;
            end
        end
    end
    
    ring_binary = medfilt2(ring_binary);
    [row, col] = find(ring_binary);
    
    if(length(row) < 100 || length(col) < 100)
        if ring_lost_count == 0
            ring_lost_count = 1;
            movedown(t,'Distance',0.3)
        elseif ring_lost_count == 1
            ring_lost_count = 2;
            moveup(t,'Distance',0.6)
        elseif ring_lost_count == 2
            ring_lost_count = 3;
            moveright(t,'Distance',0.8)
        elseif ring_lost_count == 3
            ring_lost_count = 4;
            moveleft(t,'Distance',1.6)
        elseif ring_lost_count == 4
            ring_lost_count = 5;
            movedown(t,'Distance',0.6)
        elseif ring_lost_count == 5
            ring_lost_count = 6;
            moveright(t,'Distance',1.6)
        else
            ring_lost_count = 0;
            moveleft(t,'Distance',0.5)
            moveup(t,'Distance',0.3)
        end
    else
        ring_lost_count = 0;
        yc = round(mean(row));
        xc = round(mean(col));
        rowOffset = round(720/4) - yc;
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
                
            elseif sum(ring_binary(:,453:504),'all')/52 >= 720*0.5
                if side_lean < 3
                    if sum(ring_binary(:,1),'all') > sum(ring_binary(:,768),'all')
                        timer = 0;
                        side_lean = side_lean + 1;
                        moveleft(t,'Distance',0.3)
                        
                    else
                        timer = 0;
                        side_lean = side_lean + 1;
                        moveright(t,'Distance',0.3)
                    end
                    
                else
                    if sum(ring_binary(1,:),'all') > sum(ring_binary(720,:),'all')
                        side_lean = 0;
                        moveup(t,'Distance',0.2)
                    else
                        side_lean = 0;
                        movedown(t,'Distance',0.2)
                    end
                end
            else
                timer = timer + 1;
            end
        else
            function_switch = 0;
            timer = 0;
            moveforward(t,'Speed',1,'Distance',0.5)
        end
    end
end
end