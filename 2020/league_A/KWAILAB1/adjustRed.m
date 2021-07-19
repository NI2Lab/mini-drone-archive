function a = adjustRed(r,c)
    [f,~] = snapshot(c);
    a = findRedot(f)
    if 0 < a && a < 10
          moveforward(r,'Distance',0.2,'Speed',0.4,'WaitUntilDone',true);
    end
end