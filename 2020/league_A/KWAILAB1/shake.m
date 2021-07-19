function [frame_mid,frame_right,frame_left] = shake(r,c)
    turn(r,deg2rad(0));
    [frame_mid,~] = snapshot(c);
    turn(r,deg2rad(40));
    [frame_right,~] = snapshot(c);
    turn(r,deg2rad(-80));
    [frame_left,~] = snapshot(c);
    turn(r,deg2rad(40));
end