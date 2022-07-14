function nAngle = DetectRatio(obj)
    
    cMin_blue_th = 0.527;
    cMax_blue_th = 0.638;
    
    cMinThreshold = 0.8;
    cMaxThreshold = 1.2;
    cWeightAngle = 10;

    aFiltered_blue = (obj.aHSV_frame(:,:,1) > cMin_blue_th) & (obj.aHSV_frame(:,:,1) < cMax_blue_th);
    
    [nSizeY, nSizeX] = size(aFiltered_blue);
    
    nHalf_point_x = fix(nSizeX/2);
    nHalf_point_y = fix(nSizey/2);

    nLengthX = 0;
    nLengthY = 0;

    for i = nHalf_point_x : nSizeX 
        if aFilter(nHalf_point_y,i) ~= 0   
            nLengthX = nLengthX + 1;
        else 
            break;
        end
    end
    
    for i = nHalf_point_y : nSizeY 
        if aFilter(i,nHalf_point_x) ~= 0   
            nLengthY = nLengthY + 1;
        else
            break;
        end
    end
    
    nLength_ratio =  nLengthX / nLengthY;
    if (nLength_ratio < cMaxThreshold) && (nLength_ratio > cMinThreshold)
        nAngle = 0;
    else 
        nAngle = nLength_ratio * cWeightAngle;
    end

end

