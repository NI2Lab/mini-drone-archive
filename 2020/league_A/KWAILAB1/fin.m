function a = fin(r,c)
    a = 0;
    [f,~] = snapshot(c); 
    b = findBlue(f);
    if  b > 0
        land(r)
        return
    end
    for i =  [0.88, 1.10, 1.50 ]
        d = updown(i,r);
        [f,~] = snapshot(c); 
        b = findBlue(f);
        if  b > 0
           land(r)
           return
        end
    end
end