function [CameraPitch] = AngleControl(droneObj,yawI)

    [angles]= readOrientation(droneObj); %yaw,pitch,roll 검출
    if (isempty(angles))
      turn(droneObj,0);  
    else
    yawD=angles(1) %현재의 yaw각 검출
    testabsyaw=abs(yawD-yawI); %불연속검출구간 검출을 위한 test value
    
    if testabsyaw>3*pi/2  %-180와 180도 사이 구간에서의 각도 변화
        if yawD>yawI
            TrueYaw=abs(yawD+yawI);
            if yawD>0
                turn(droneObj,-TrueYaw);
                H=1
            else         
                 turn(droneObj,TrueYaw);
                 H=2           
            end
        else
            TrueYaw=abs(yawD-yawI); 
                if yawD>0
                    turn(droneObj,-TrueYaw);
                    H=3
                else
                    turn(droneObj,TrueYaw);
                    H=4

                end
        end
     end
    end
%{
    [angles]= readOrientation(droneObj); %yaw,pitch,roll 검출
    yawD=angles(1) %현재의 yaw각 검출
    testyaw=abs(yawD-yawI); %불연속검출구간 검출을 위한 test value
    
    if testyaw>pi/2  %-180와 180도 사이 구간에서의 각도 변화
        %TrueYaw=abs(yawD-yawI+2*pi);
        if yawD>0
            %turn(droneObj,-TrueYaw);
            
        else
            if yawD<=0
                %turn(droneObj,TrueYaw);
               
            end
        end
    else
        if testyaw<=pi/2
           %TrueYaw=abs(yawD-yawI); 
            if yawD>0
              %turn(droneObj,-TrueYaw);
             
            else
                if yawD<=0
                %turn(droneObj,TrueYaw);               
               end
            end
        end
    end
%}
    
    Pitch=angles(2);
    Pitch=rad2deg(Pitch);
    if (-5<=Pitch)&&(Pitch<=5)
        CameraPitch=true;
    else
        CameraPitch=false;
    end
end

    

