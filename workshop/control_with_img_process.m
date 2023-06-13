try
    drone = ryze();
    cam = camera(drone);

    % (1) takeoff
    takeoff(drone);
    pause(3);

    % (2) moveright & search red color
    while 1
        moveright(drone, 'Distance', 0.2);
        pause(3);

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

    % (3) moveup & search green color
    while 1
        moveup(drone, 'Distance', 0.2);
        pause(3);

        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_green = (0.275<h)&(h<0.325);

        if sum(detect_green, 'all') >= 14000
            % green color detected
            break
        end
    end

    % (4) moveright & search blue color
    while 1
        moveright(drone, 'Distance', 0.2);
        pause(3);

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

    % (5) land
    land(drone);
    
    
catch error
    disp(error);
    clear;
    
