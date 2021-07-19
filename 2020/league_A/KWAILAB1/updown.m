
function a = updown(height_target,r)
    [height_now,~]= readHeight(r);
    h = height_target - height_now;
    
    if h <= -0.2
        movedown(r,'Distance',-h,'WaitUntilDone',true);
    elseif h >= 0.2
        moveup(r,'Distance',h,'WaitUntilDone',true);
    end
    a = height_target;
end