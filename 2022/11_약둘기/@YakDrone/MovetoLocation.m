function is_Complete = MovetoLocation(obj,x,y)
    
  
    move(obj.mDrone,[0 x -y],'Speed',obj.cSpeed_set);
    is_Complete = true;

end

