function frame_mid = search(r,c)
    turn(r,deg2rad(0));
    [frame_mid,~] = snapshot(c);  
end