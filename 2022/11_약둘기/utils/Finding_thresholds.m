clear drone;
disp("Clear!");
%%

drone = ryze();
cam = camera(drone);

step = 0.005;

th_down = 0.595;
th_up = 0.670;

while 1
    frame = snapshot(cam);
    subplot(2,1,1),subimage(frame);
    pause(1);

    hsv = rgb2hsv(frame);
    
    h = hsv(:,:,1);
    s= hsv(:,:,2);
    v = hsv(:,:,3);
    

    filter = s > 0.3;
    vfilter = v > 0.15;
%     red_filter = frame(:,:,1)<30;
%     blue_filter = frame(:,:,3)>180;
    h = imgaussfilt(h,2);
    if(th_up - th_down)<0
        binary_res = (th_down<h)+(h<th_up);
         
        se = strel('disk',7);
        binary_res = imdilate(binary_res,se);
        binary_res = round(binary_res);
        binary_res = binary_res .* filter;
%         binary_res = binary_res .* red_filter;
        binary_res = binary_res .* vfilter;
    else
        binary_res = (th_down<h)&(h<th_up);
        
        se = strel('disk',7);
        binary_res = imdilate(binary_res,se);
        binary_res = round(binary_res);
        binary_res = binary_res .* filter;
%         binary_res = binary_res .* red_filter;
        binary_res = binary_res .* vfilter;
    end

    

    

    subplot(2,1,2),subimage(binary_res);
    nDetected_pixels = nnz(binary_res);

    nDetected_pixels
    disp("th_down: "+th_down+" th_up:" +th_up);

    x=input("(quit: q, th_up-up: a, th_down-up: s, th_up-down: d, th_down-down: f) input: ",'s');
    disp(newline);
    
    if x=='q'
        disp("final th_up: "+th_up+" th_down: "+th_down);
        break;
    elseif x == 'a'
        th_up = th_up + step;
    elseif x == 's'
        th_down = th_down + step;
    elseif x == 'd'
        th_up = th_up - step;
    elseif x == 'f'
        th_down = th_down - step;
    end

    if th_down<0 
        disp("Cannot down th_down")
        th_down = 0;
    elseif th_down>0.999
        disp("Cannot up th_down")
        th_down = 0.999;
    elseif th_up<0
        disp("Cannot down th_up")
        th_up = 0;
    elseif th_up>0.999
        disp("Cannot up th_up")
        th_up = 0.999;
    end

end