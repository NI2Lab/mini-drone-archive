function z = findBlue(path)

    im = path;
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);
        
    bl=b-g/2-r/2;
    bwImg=bl>40;
    [row, col] = find(bwImg);
    
    if( length(row) > 5 || lengh(col) > 5)
       z = 1
    else
        z = 0
    end
end
