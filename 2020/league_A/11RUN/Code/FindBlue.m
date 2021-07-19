function [BlueCenterX, BlueCenterY, bluemaxvalue] = FindBlue(I)

   
    bluechannel1Min = 0.53;
    bluechannel1Max = 0.65;

    bluechannel2Min = 0.3;
    bluechannel2Max = 1;

    bluechannel3Min = 0.2;
    bluechannel3Max = 1;
    
    
    H_blue = ( (I(:,:,1) >= bluechannel1Min) & (I(:,:,1) <= bluechannel1Max) ) & ...
    (I(:,:,2) >= bluechannel2Min ) & (I(:,:,2) <= bluechannel2Max) & ...
    (I(:,:,3) >= bluechannel3Min ) & (I(:,:,3) <= bluechannel3Max);
    
    H_blue = medfilt2(H_blue);     
    blue = bwlabel(H_blue, 8);

    bluestats = regionprops(blue, 'BoundingBox', 'Centroid','Area');

         

    blueArray1=struct2table(bluestats);
    blueArray2=table2array(blueArray1);
    bluesizel=size(blueArray2);
    bluesize2=bluesizel(1);
    blueArray3=blueArray2(1:bluesize2);
    [bluemaxvalue,bluemaxPosition]=max(blueArray3);
    
    if (isempty(bluemaxvalue))
        BlueCenterX=[];
        BlueCenterY=[];
        bluemaxvalue=[];
    else
    BlueCenterX=blueArray2(bluemaxPosition,2);
    BlueCenterY=blueArray2(bluemaxPosition,3);
    end

    
