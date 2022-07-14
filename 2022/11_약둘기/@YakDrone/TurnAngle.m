function is_Complete= TurnAngle(obj)
   
     if obj.nCount==3 
        turn(obj.mDrone,deg2rad(135));
        obj.MovetoLocation(-0.6,0);
        if(obj.nMoveWeight<0)
            nDist_weight = -obj.nMoveWeight*1.4;
        else
            nDist_weight =0;
        end
        moveforward(obj.mDrone,"Distance",1+nDist_weight,"Speed",obj.cSpeed_set);
     else
     
        turn(obj.mDrone,deg2rad(90));
        nDist_weight = obj.nMoveWeight*1.8;
        moveforward(obj.mDrone,"Distance",0.93+nDist_weight,"Speed",obj.cSpeed_set);
     end
     is_Complete=true;
    
end

