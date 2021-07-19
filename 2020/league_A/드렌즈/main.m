    drone = ryze();
    cam = camera(drone);
    
    % (1) takeoff
    takeoff(drone);
    pause(2);

    %위로 이동
    moveup(drone, 'distance', 0.3);
    pause(2);

    moveforward(drone, 'distance', 2.6);
    pause(2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%% 1첫번째 링
        
    while 1
        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_red = (h>1)+(h<0.05);

        if sum(detect_red, 'all') >= 17000
            % red color detected
            break
        end
    end

   turn(drone, deg2rad(-90));
   pause(2);

   moveforward(drone, 'distance', 2);
   pause(2);
   
   moveup(drone, 'distance', 0.85);
   pause(2);
   
  %%%%%%%%%%%%%%%%%%%%%%%%%% 링 22222222
    while 1
        movedown(drone, 'distance', 0.2);
        pause(2);

        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_green = (0.275<h)&(h<0.4);

        if sum(detect_green, 'all') >= 14000
            % green color detected
            break
        end
    end
    
    [height,~] = readHeight(drone);
    
    movedown(drone, 'distance', 0.45);
    pause(2);
    
    moveforward(drone, 'distance', 0.7);
    pause(2);
    
    while 1
        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_red = (h>1)+(h<0.05);

        if sum(detect_red, 'all') >= 17000
            % red color detected
            break
        end
    end
    
   turn(drone, deg2rad(-90));
   pause(2);
   
    moveforward(drone, 'distance', 2);
    pause(2);
    
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3번째 링

 moveleft(drone, 'distance', 1.65);
 pause(2);     

 if height > 1.3
    movedown(drone, 'distance', 0.7);
    pause(2);
    
 elseif height < 1.3
    moveup(drone, 'distance', 0.7);
    pause(2);
    
 end
 
 
     while 1
        moveright(drone, 'Distance', 0.2);
        pause(2);

        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_green = (0.275<h)&(h<0.4);

        if sum(detect_green, 'all') >= 14000
            % green color detected
            break
        end
    end
     
     moveright(drone, 'distance', 0.5);
     pause(2);
  
     moveforward(drone, 'distance', 0.75);
     pause(2);
     
    while 1
  
        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_blue = (0.575<h)&(h<0.625);

        if sum(detect_blue, 'all') >= 15000
            % blue color detected
            break
        end
    end
  
   land(drone);
  
