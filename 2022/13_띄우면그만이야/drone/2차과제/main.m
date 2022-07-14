droneObj = ryze();

takeoff(droneObj);

moveleft(droneObj,"Distance",0.5);

turn(droneObj,deg2rad(45));

moveforward(droneObj,"Distance",0.5);

turn(droneObj,deg2rad(135));

moveforward(droneObj,"Distance",0.5);

land(droneObj);