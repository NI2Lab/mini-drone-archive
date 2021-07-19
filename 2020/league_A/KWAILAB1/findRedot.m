function r= findRedot(path)
    r=0;
    im=path;
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);

    rl=r-g/2-b/2;
    bwImg=rl>40;
    [row, col] = find(bwImg);

    r = length(row);
end