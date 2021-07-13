droneObj = ryze();
takeoff(droneObj)
moveforward(droneObj,'Distance',2)
pause(1)
moveright(droneObj, 'Distance', 2)
pause(1)
turn(droneObj, deg2rad(-135))
moveforward(droneObj, 'Distance', 3)
land(droneObj)