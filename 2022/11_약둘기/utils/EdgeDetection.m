function y = EdgeDetection(Image)

aRawframe = rgb2hsv(Image);
aFrame = rgb2gray(Image);

//1번 코드

if CountPixels(aRawframe)
    nCenterX = 0;
    nCenterY = 0.5;
    is_forward = 0;
    nTurn = 0;
    return
end

[n_move_point_x,move_point_y] = BluePixelFocusMove(image); 




//3번 코드

nAngle = DetectRatio(aRawframe);
if nAngle ~= 0
    nCenterX = 0;
    nCenterY = 0;
    is_forward = 0;
    nTurn = nAngle;
    return
end


//4번 코드

img_rgb=imread('test5.png');

img_hsv=rgb2hsv(img_rgb);

hsv_h=img_hsv(:,:,1);

aH=hsv_h;
aFiltered_red= (aH > 0.916) | (aH < 0.05); // 빨간색 좌표찾기

[nSize_y, nSize_x] = size(aFiltered_red);

nHalf_point_x = fix(nSize_x / 2);
nHalf_point_y = fix(nSize_y/2);

nSum_of_red_x = 0;
nSum_of_red_y = 0;

nNum_of_red_points = 0;

for i = 1: nSize_y
    for j = 1:nSize_x
        if aFiltered_red(i,j)==1  
            
            nSum_of_red_x = nSum_of_red_x + j - nHalf_point_x;
            nSum_of_red_y = nSum_of_red_y + i - nHalf_point_y; 
            nNum_of_red_points = nNum_of_red_points + 1;

        end
    end
end


nCenter_x = nSum_of_red_x / nNum_of_red_points; 
nCenter_y = nSum_of_red_y / nNum_of_red_points; //긁어오기

[i,j] = find((hsv_h>0.916 || hsv_h<0.05); //빨간색 좌표 찾기 두번째 경우 여기서는 안씀

[row,col]=size(hsv_h); //hsv_h의 행열 크기 찾기
middle=hsv_h(row/2-3:row/2+3 ,col/2-3:col/2+3); //hsv_h  행렬의 중앙범위 찾기


center_red= nnz(middle >0.916 | middle < 0.05);

if center_red > 1
    fprintf("111");
else
    fprintf("222");
end    else
  MovetoLocation(myDrone,nCenter_x,nCenter_y);

end



// filter = uint8((aRawframe(:,:,1) > 0.5) & (aRawframe(:,:,1) < 0.8));

// filtered = aFrame .* filter ;
// filtered = filtered + ((1-filtered) .* 255);

// mask = ones(3,3)/9;

// filtered = imfilter(filtered,mask);


// my_edge = edge(filtered,"canny");

// [center, rad, metric] = imfindcircles(filtered,[20 1000],"Sensitivity",0.959);

// imshow(filtered);

// viscircles(center,rad);

// end

