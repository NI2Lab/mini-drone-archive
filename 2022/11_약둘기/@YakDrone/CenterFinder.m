function is_Center = CenterFinder(obj)
    is_Center = 0;
    obj.nMoveWeight=0;
    
    is_Circle = obj.OnlyDetectCircle();

    if is_Circle == 1 
        if obj.nStep ~= 0
  
            nBestCenter_X = obj.aCentroid(1);
            nBestCenter_Y = obj.aCentroid(2);

            if(obj.nCircle_r < obj.cCircle_rad_th)
                obj.NewFindingCircle();
            else
                nTarget_X = nBestCenter_X - (obj.nSize_x/2);
                nTarget_X = round(nTarget_X,2);
            
                nTarget_Y = -nBestCenter_Y + (obj.nSize_y/2);
          

                if obj.nRatio > obj.cOptimized_ratio_th
                    nTarget_Y = round(nTarget_Y,2)-obj.cTargetY_weight;
                else
                    nTarget_Y = round(nTarget_Y,2)-obj.cTargetY_weight+ 70;
                end
            
                if(nTarget_X<=obj.cRange_th && nTarget_X>=-obj.cRange_th && nTarget_Y <=obj.cRange_th && nTarget_Y >= -obj.cRange_th)
                    is_Center = 1;
                else
                    coeff = (obj.cCircle_size(1,obj.nCount)/(obj.nCircle_r/2.3));
              
                    nTarget_X = round(coeff * nTarget_X,2);
                    nTarget_Y = round(coeff * nTarget_Y,2);
                    
                    %handle move distance / upto 20cm
                    if((abs(nTarget_X) <= 0.20))
                        if(abs(nTarget_X)>=0.12)
                            nTarget_X = ((nTarget_X)/abs(nTarget_X)) * 0.2;
                        else
                            nTarget_X=0;
                            obj.nMoveWeight = nTarget_X;
                        end
                    end
                    if((abs(nTarget_Y) <= 0.20))
                        if(abs(nTarget_Y)>=0.12)
                            nTarget_Y = ((nTarget_Y)/abs(nTarget_Y)) * 0.2;
                        else
                            nTarget_Y=0;
                            obj.nMoveWeight = nTarget_Y;
                        end
                    end
                    
                    %Prevent overshooting 
                    if(nTarget_X >= obj.cMax_move_dist)
                        nTarget_X=obj.cMax_move_dist;
                    end
                    if(nTarget_X <= -obj.cMax_move_dist)
                        nTarget_X= -obj.cMax_move_dist;
                    end
                    if(nTarget_Y >= obj.cMax_move_dist)
                        nTarget_Y=obj.cMax_move_dist;
                    end
                    if(nTarget_Y <= -obj.cMax_move_dist)
                        nTarget_Y=-obj.cMax_move_dist;
                    end
                   
                    %Just shoot if no circle when after we had
                    %positioned.
                    % (Drone must have been in center of circle)
                    if((nTarget_X ~= 0) || (nTarget_Y ~= 0))
                        obj.MovetoLocation(nTarget_X,nTarget_Y);
                        obj.is_last_we_had_positioned=1;
                    else
                        %We dont have to move == we are in center.
                        is_Center = 1;
                    end
                end
                
                %If we are in center, calculate distance and shoot.
                if is_Center 
                    Circle_r = obj.nCircle_r*(0.39/obj.cCircle_size(1,obj.nCount));
                
                    nDistance = (515)*(Circle_r^(-0.954));
                    dist = round(nDistance,2)+0.3;
                    
        
                    moveforward(obj.mDrone,"Distance",dist,"Speed",obj.cSpeed_set);
                 
                end
            end
        end
    else 
        is_Center = 0;
    end

end