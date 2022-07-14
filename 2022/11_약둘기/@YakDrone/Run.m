function nError_code = Run(obj)
%RUN 이 함수의 요약 설명 위치
%   자세한 설명 위치
    
    takeoff(obj.mDrone);
    move(obj.mDrone,[-0.2 0 -0.2],'Speed',obj.cSpeed_set);

    obj.nStep=0;
    obj.nCount=1;
    obj.nFailCount=0;

    nError_code=0;
    disp("Ready to Move!");
    while (obj.nCount <= obj.cTotal_Circle)
      
        fprintf("current step: %d\n",obj.nStep);
        
        %Debug
        if(nError_code)
            fprintf("Error!: %d\n",obj.nStep);
            nError_code=0;
        end
        
        %Loop
        if(~obj.ImageProcessing())
            nError_code = 1;
            continue;
        end
        
        %Step 1: Find Blue Circle
        if obj.nStep == 0
            code = obj.OnlyDetectCircle();
            if code == 0 
                %First level, Start with very close distance, just shoot.
                if obj.nCount == 1 
                    moveforward(obj.mDrone,"Distance",obj.cShoot_distance,"Speed",obj.cSpeed_set);
                    obj.nStep=2;
                else
                    obj.nFailCount= obj.nFailCount+1;
                    nError_code=2;
                end
                if(obj.nFailCount>3)
                    if(~obj.NewFindingCircle())
                        nError_code=3;
                    end
                    
                end
            elseif code == -1
                nError_code=4;
            else
                obj.nStep=1;
                obj.nFailCount=0;
                obj.nFinder=0;
            end
        end

        %Step 2:Find Center and Shoot 
        if obj.nStep == 1
            fprintf("current step: %d\n",obj.nStep);
            code = obj.CenterFinder();
            if (code==1)
                obj.nStep = 2;
            elseif(code == 0)
                obj.nFailCount= obj.nFailCount+1;
                if(obj.nFailCount>3)
                    %Just shoot if no circle when after we had positioned.
                        % (Drone must have been in center of circle)
                    if(obj.is_last_we_had_positioned)
                        moveback(obj.mDrone,"Distance",0.6,"Speed",obj.cSpeed_set);
                        obj.nFailCount=0;
                        obj.is_last_we_had_positioned=0;
                    else
                        obj.nStep=0;
                        obj.nFailCount=0;
                    end
                end
            else
                nError_code=5;
            end
        end

        %Step 3:Turn and Go
        if obj.nStep == 2
            fprintf("current step: %d\n",obj.nStep);
            obj.is_last_we_had_positioned=0;
            obj.nCount = obj.nCount + 1;
            
            %Work done, we are in destination.
            if obj.nCount == 4 
                obj.Finish();
    
            else
                if obj.TurnAngle()
                    obj.nStep=0;
                else
                    nError_code=6;
                end
            end
            
            %In level 3, Start with turn to 135 degree and move forward to prevent collision. 
        end
        pause(obj.cWait_time);
    end
    nError_code = 0;
    
end

