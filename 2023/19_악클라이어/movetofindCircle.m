function good = movetofindCircle(where, area_before)
switch where
    case 1
        moveright(dr,'Distance', 0.2,'WaitUntilDone', true);
    case 2
        moveleft(dr,'Distance', 0.2,'WaitUntilDone', true);
    case 3
        moveup(dr,'Distance', 0.2,'WaitUntilDone', true);
    case 4
        movedown(dr,'Distance', 0.2,'WaitUntilDone', true);
end
pause(2);

img = snapshot(cam);
bimg = separateBlue(img);
area_after = sum(bimg, 'all');

if area_after > area_before
    good =1;
else
    switch where
        case 1
            moveleft(dr,'Distance', 0.2,'WaitUntilDone', true);
        case 2
            moveright(dr,'Distance', 0.2,'WaitUntilDone', true);
        case 3
            movedown(dr,'Distance', 0.2,'WaitUntilDone', true);
        case 4
            moveup(dr,'Distance', 0.2,'WaitUntilDone', true);
    end
    good =0;

end