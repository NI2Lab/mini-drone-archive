function dis= eval_Dist(path)
    % input : path (img)
    % output : distance from drone to gole
    % if distance < 1 (not too far), return 0
    % else return distanceeeeee

    im=path;
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);

    nRows=size(im,1);
    nCols=size(im,2);
    gI=g-r/2-b/2;
    bwImg=gI>35;

    %bwImg = imclearborder(bwImg,4);
    sedisk = strel('rectangle',[40,40]);
    bwImg = imopen(bwImg,sedisk);

    [row, col] = find(bwImg);

    %col -> x / row -> y

    [m, index] = (min(col - row));
    [n, index2] = (max(col + row));

    leftP = [col(index) , row(index)];
    rightP = [col(index2) , row(index2)];


    %imshow(LR);
    a = [leftP, rightP];

    p=[a(1) a(2)];
    q=[a(3) a(4)];

    pq=pdist2(p,q);

    if pq > 960
      %  print("in 1m");
        dis=0;
    else
        dis=960000/pq;
    end
    dis = dis/1000
end