function a = turnleft(r,c)
    a = 0;
    [f,~] = snapshot(c); 
    b = findRed(f);
    if  b > 0
        turn(r,deg2rad(0));
        turn(r,deg2rad(-90));
        return
    end
    for i =  [0.88, 1.10, 1.50 ]
        d = updown(i,r);
        [f,~] = snapshot(c); 
        b = findRed(f);
        if  b > 0
            turn(r,deg2rad(0));
            turn(r,deg2rad(-90));
            return
        end
    end
end