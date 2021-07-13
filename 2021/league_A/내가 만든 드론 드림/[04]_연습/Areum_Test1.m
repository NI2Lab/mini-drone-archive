droneObj = ryze()
cameraObj = camera(droneObj)
takeoff(droneObj)
moveup(droneObj, 'Distance', 0.8)
moveforward(droneObj, 'Distance', 2)

while 1
     frame = snapshot(cam);
     subplot(2,1,1), imshow(frame);
     pause(2);
     hsv = rgb2hsv(frame);
     h = hsv(:,:,1);
     detect_red = (h>1)+(h<0.05);
     if sum(detect_red, 'all') >= 17000
          moveforward(droneObj, 'Distance', 1);
          turn(droneObj, deg2rad(270));
          break
     end
end
moveforward(droneObj, 'Distance', 2)
while 1
     frame = snapshot(cam);
     subplot(2,1,1), imshow(frame);
     pause(2);
     hsv = rgb2hsv(frame);
     h = hsv(:,:,1);
     detect_blue = (0.575<h)&(h<0.625);
     if sum(detect_blue, 'all') >= 15000
          moveforward(droneObj, 'Distance', 1);
          land(droneObj);
          break
     end
end
takeoff(droneObj)
moveup(droneObj, 'Distance', 0.8)
turn(droneObj, deg2rad(270))
while 1
     frame = snapshot(cam);
     subplot(2,1,1), imshow(frame);
     pause(2);
     hsv = rgb2hsv(frame);
     h = hsv(:,:,1);
     detect_red = (h>1)+(h<0.05);
     if sum(detect_red, 'all') >= 17000
          moveforward(droneObj, 'Distance', 1);
          land(droneObj);
          break       
     end
end