function  is_Complete= TurnWithEcc(obj)
    try 
        %120도 이후에 원(OnlyDetectCircle.m)을 찾고 장축 단축의 비율에 따라 turn
        obj.nMAxisLength;  % 장축 추가
        obj.nmAXislength;
        angle = atan(obj.nmAXislength/obj.nMAxisLength);
        angle = fix(angle);
        
        if(angle > 3)
            turn(obj.mDrone,deg2rad(90-angle));
        end
        is_Complete = true;
    catch e
        disp(e);
        is_Complete=false;
    end
end

