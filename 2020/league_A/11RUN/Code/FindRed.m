function [RedCenterX, RedCenterY, redmaxvalue] = FindRed(I)

    red1Min = 0;
    red1Max = 0.036;
    red2Min = 0.96;
    red2Max = 1;
    redchannel2Min = 0.3;
    redchannel2Max = 95;
    redchannel3Min = 0.2;
    redchannel3Max = 1;


    H_red = ((I(:,:,1) >= red1Min) & (I(:,:,1) <= red1Max) |...
        (I(:,:,1) >= red2Min) & (I(:,:,1) <= red2Max)) & ...
        (I(:,:,2) >= redchannel2Min ) & (I(:,:,2) <= redchannel2Max) & ...
        (I(:,:,3) >= redchannel3Min ) & (I(:,:,3) <= redchannel3Max);
    
    H_red = medfilt2(H_red); 
    red = bwlabel(H_red, 8);

    redstats = regionprops(red, 'BoundingBox', 'Centroid','Area');

         

    redArray1=struct2table(redstats);
    redArray2=table2array(redArray1);
    redsizel=size(redArray2);
    redsize2=redsizel(1);
    redArray3=redArray2(1:redsize2);
    [redmaxvalue,redmaxPosition]=max(redArray3);
    
    if (isempty(redmaxvalue))
        RedCenterX=[];
        RedCenterY=[];
        redmaxvalue=[];
    else
    RedCenterX=redArray2(redmaxPosition,2);
    RedCenterY=redArray2(redmaxPosition,3);
    end

    



