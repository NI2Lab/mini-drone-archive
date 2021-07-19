function a = adjust(r,c,f)
    [c,~] = snapshot(c); 
    b = findLine(f);
    if ( 400 < b(1)) && ( b(1) < 800 ) 
        moveright(r,'Distance', 0.2 ,'WaitUntilDone',true);
    end
    if ( 0 < b(1)) && ( b(1) < 200 ) 
        moveleft(r,'Distance',0.2,'WaitUntilDone',true);
    end
    if ( b(2) > 700 )
        movedown(r,'Distance',0.2,'WaitUntilDone',true);
    end

end