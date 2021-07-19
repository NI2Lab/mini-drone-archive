function a= findLine(path)
    a=[0,0,0,0];
    im=path;
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);

    nRows=size(im,1);
    nCols=size(im,2);
    gI=g-r/2-b/2;
    bwImg=gI>40;

    bwImg = imclearborder(~bwImg,4);
    sedisk = strel('rectangle',[2,2]);
    bwImg = imopen(bwImg,sedisk);

    [row, col] = find(bwImg);
    if (length(row) < 50 || length(col)<50)
            return
    end
    %col -> x / row -> y 
 
    [m, index] = (min(col - row));
    [n, index2] = (max(col + row));
    
    
    leftP = [col(index) , row(index)];
    rightP = [col(index2) , row(index2)];

    LR = zeros(720,960,3);
    LR(:,:,1)=bwImg;
    LR(:,:,2)=bwImg;
    LR(:,:,3)=bwImg;
    LR=LR.*255;
    LR(leftP(2), leftP(1), :) = [255, 0, 0];
    LR(rightP(2), rightP(1), :) = [255, 0, 0];

    a = [leftP, rightP];
end