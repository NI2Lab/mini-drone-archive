% Tello drone object
drone = ryze();

% Camera object
cam = camera(drone);

% init treshold
th_down = 0.5;
th_up = 0.55;


while 1
    % Capture an image from the drone's camera
    frame = snapshot(cam);
    subplot(2,1,1), subimage(frame);
    pause(1);
    
    
    % Get the hue data of the image
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    
    
    % imshow current binary image
    if (th_up - th_down) < 0
        binary_res = (th_down<h)+(h<th_up);
    else
        binary_res = (th_down<h)&(h<th_up);
    end
    subplot(2,1,2), subimage(binary_res);                                           
    disp("th_down: " + th_down + "   th_up: " + th_up);
    
    
    % keyboard input & adjust the threshold value
    x = input("(quit: q, up: e, down: d) \ninput: ", 's'); disp(newline);
    if x == 'q'
        disp("* final th_down: " + th_down + "   fianl th_up: " + th_up);
        break
    elseif x == 'e'
        th_down = th_down + 0.025;
        th_up = th_up + 0.025;
    elseif x == 'd'
        th_down = th_down - 0.025;
        th_up = th_up - 0.025;
    end
    
    if th_down > 1
        th_down = th_down - 1;
    elseif th_down < 0
        th_down = th_down + 1;
    end  
    
    if th_up > 1
        th_up = th_up - 1;
    elseif th_up < 0
        th_up = th_up + 1;
    end
end
