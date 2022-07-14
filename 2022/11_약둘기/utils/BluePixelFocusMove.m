function [nCenter_x, nCenter_y] = BluePixelFocusMove(aHSV_frame)

cMin_blue_th = 0.650;
cMax_blue_th = 0.680;

aFiltered_blue = (aHSV_frame(:,:,1) > cMin_blue_th) & (aHSV_frame(:,:,1) < cMax_blue_th); %파랑색 픽셀

[nSize_y, nSize_x] = size(aFiltered_blue);  %X Y 3 크기

nHalf_point_x = fix(nSize_x / 2);
nHalf_point_y = fix(nSize_y/2);

nSum_of_blue_x = 0;
nSum_of_blue_y = 0;

nNum_of_blue_points = 0;

for i = 1: nSize_y
    for j = 1:nSize_x
        if aFiltered_blue(i,j)==1  
            
            nSum_of_blue_x = nSum_of_blue_x + j - nHalf_point_x; %x축 픽셀위치 중심구하기
            nSum_of_blue_y = nSum_of_blue_y - i + nHalf_point_y;  %y축 픽셀위치 중심구하기
            nNum_of_blue_points = nNum_of_blue_points + 1;

        end
    end
end



nCenter_x = nSum_of_blue_x / nNum_of_blue_points; %x축 픽셀위치 중심구하기
nCenter_y = nSum_of_blue_y / nNum_of_blue_points; %y축 픽셀위치 중심구하기

end
