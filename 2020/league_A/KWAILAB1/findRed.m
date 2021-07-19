function z = findRed(path)

    im = path;
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);
        
    rl=r-g/2-b/2;
    bwImg=rl>40;
    [row, col] = find(bwImg);
    
    if( length(row) > 5 || lengh(col) > 5)
       z = 1
    else
        z = 0
    end
end

