takeoff(droneObj)
pause(3);
moveforward(droneObj,'Distance',1);
pause(3);
moveright(droneObj,'Distance', 1);
pause(3);
turn(droneObj,deg2rad(-120));
pause(3);
moveforward(droneObj,'Distance',1.2);
pause(3);
land(droneObj);