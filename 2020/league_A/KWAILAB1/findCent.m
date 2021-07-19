function a = findCent(im)
    im = im;
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);

    nRows=size(im,1);
    nCols=size(im,2);
    gI=g-r/2-b/2;
    bwImg=gI>35;

    %
    sedisk = strel('rectangle',[40,40]);
    bwImg = imopen(bwImg,sedisk);

    %
    %imshow(bwImg);
    clearbwImg = imclearborder(~bwImg,4);
    [row, col] = find(clearbwImg);
    %imshow(clearbwImg);
    if(length(row) < 50 || length(col) < 50 )
        % not found
        a=[0 0]
        return
    end
    XgreenCentre = round(mean(col));
    YgreenCentre = round(mean(row));
    a=[XgreenCentre, YgreenCentre];
    %return
end