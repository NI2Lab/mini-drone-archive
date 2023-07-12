function good =  AimStraight(center, coor)
good = 0;

if issimilar(coor(1), center(1)) ~= 1
    if coor(1) < center(1)
        moveright(dr,'Distance', 0.2,'WaitUntilDone', true);
        pause(2);
    else
        moveleft(dr,'Distance', 0.2,'WaitUntilDone', true);
        pause(2);
    end

elseif issimilar(coor(2), center(2)) ~= 1
    if coor(2) < center(2)
        movedown(dr,'Distance', 0.2,'WaitUntilDone', true);
        pause(2);
    else
        moveup(dr,'Distance', 0.2,'WaitUntilDone', true);
        pause(2);
    end

else
    good = 1;
end



end