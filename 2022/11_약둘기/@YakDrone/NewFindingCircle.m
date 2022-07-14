function is_Complete = NewFindingCircle(obj)

  nSum_of_blue_x=0;
  nSum_of_blue_y=0;

  nHalf_point_x = obj.nSize_x/2;
  nHalf_point_y = obj.nSize_y/2;
% 오른쪽 붙어잇는거
% 왼쪽 붙어잇는거
% 중앙 쪽으로 이동시키다가 대충 중앙에 파랑색 밀집하면 고도를 변경하라 위 or 아래
% 720 960 이니까 450 ~510 이정도에서 파랑색 밀집한거 보이면 고도를 변경. 
     for i = 1: obj.nSize_y
        for j = 1:obj.nSize_x
            if obj.aFiltered_blue(i,j)==1  
                nSum_of_blue_x = nSum_of_blue_x + j - nHalf_point_x; %x축 픽셀위치 중심구하
                nSum_of_blue_y = nSum_of_blue_y - i + nHalf_point_y;  %y축 픽셀위치 중심구하기
            
            end
        end
     end
    nSum_of_blue_x = nSum_of_blue_x / obj.nDetected_pixels;
    nSum_of_blue_y = nSum_of_blue_y / obj.nDetected_pixels;
  

    if obj.nDetected_pixels < obj.cMin_blue_number
        [nCurrent_height,void] = readHeight(obj.mDrone);
        
        switch obj.nFinder
        case 0
            nTarget_X = -1;
            nTarget_Y = 1.5 - nCurrent_height;
        case 1
            nTarget_X = 2;
            nTarget_Y = 0;
            
        case 2
            nTarget_X = 0;
            nTarget_Y = 0.5 - nCurrent_height;
        case 3
            nTarget_X = 0;
            nTarget_Y = 0;
        otherwise
            filp(obj.mDrone,'forward');
            obj.Finish();
        end
        
        if((abs(nTarget_Y) <= 0.20))
             nTarget_Y = 0;
        end
        obj.MovetoLocation(nTarget_X,nTarget_Y);
        obj.nFinder = obj.nFinder+1;
    else
       
        if nSum_of_blue_x>=70 && nSum_of_blue_x<=480
            if nSum_of_blue_y >=50 
                obj.MovetoLocation(obj.cFinder_X_distance,obj.cFinder_Y_distance);
            elseif nSum_of_blue_y <= -50
                obj.MovetoLocation(obj.cFinder_X_distance,-obj.cFinder_Y_distance);
            else 
                obj.MovetoLocation(obj.cFinder_X_distance,0);
            end
        elseif nSum_of_blue_x>=-480 && nSum_of_blue_x<=-70
            if nSum_of_blue_y >=50 
                obj.MovetoLocation(-obj.cFinder_X_distance,obj.cFinder_Y_distance);
            elseif nSum_of_blue_y <= -50
                obj.MovetoLocation(-obj.cFinder_X_distance,-obj.cFinder_Y_distance);
            else 
                obj.MovetoLocation(-obj.cFinder_X_distance,0);
            end
        else
            if nSum_of_blue_y >=50 
                obj.MovetoLocation(0,obj.cFinder_Y_distance);
            elseif nSum_of_blue_y <= -50
                obj.MovetoLocation(0,-obj.cFinder_Y_distance);
            else 
               moveback(obj.mDrone,"Distance",0.5,"Speed",obj.cSpeed_set);
                
              
            end
        end
    end
    is_Complete = 1;
        
 
end