% H값 찾는 코드
clear();
droneObj = ryze();
cameraObj = camera(droneObj);

th_down = 0.5;
th_up = 0.55;
while 1
    frame = snapshot(cameraObj);
    hsv = rgb2hsv(frame);
    h = hsv(:, :, 1);
    
    if (th_up - th_down) < 0
        binary_res = (th_down < h) + (h < th_up);
    else
        binary_res = (th_down < h) & (h < th_up);
    end
    
    subplot(2, 1, 1), imshow(frame);
    subplot(2, 1, 2), imshow(binary_res);
    disp("th_down = " + th_down + " | th_up = " + th_up);
    
    x = input("quit: q | up: u | down: d \ninput: ", 's'); disp(newline);
    if x == 'q'
        break
    elseif x == 'u'
        th_down = th_down + 0.025;
        th_up = th_up + 0.025;
    elseif x == 'd'
        th_down = th_down - 0.025;
        th_up = th_up - 0.025;
    end
    
    if th_up > 1
        th_up = th_up - 1;
    elseif th_up < 0
        th_up = th_up + 1;
    end
end