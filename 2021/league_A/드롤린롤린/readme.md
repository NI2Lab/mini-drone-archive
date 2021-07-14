drone = ryze();
camera1 = camera(drone);
takeoff(drone);

i = 0;

%위치조정
while 1
    i=i+1;

frame = snapshot(camera1);

hsv = rgb2hsv(frame);
h = hsv(:,:,1);
detect_green = (h > 0.6) & (h < 0.625);

if sum(detect_green, 'all') >= 25000

     if sum(imcrop(detect_green,[0 0 480 720]),'all')-sum(imcrop(detect_green,[480 0 960 720]),'all')>6500
                moveleft(drone,'distance',0.2,'speed',1);
            elseif sum(imcrop(detect_green,[480 0 960 720]),'all')-sum(imcrop(detect_green,[0 0 480 720]),'all')>6500
                moveright(drone,'distance',0.2,'speed',1);
     end
      if sum(imcrop(detect_green,[0 0 960 360]),'all')-sum(imcrop(detect_green,[0 360 960 720]),'all')>6500
                movedown(drone,'distance',0.2,'speed',1);
            elseif sum(imcrop(detect_green,[0 360 960 720]),'all')-sum(imcrop(detect_green,[0 0 960 360]),'all')>6500
                moveup(drone,'distance',0.2,'speed',1);
      end
           break
else
    if i==1
    moveleft(drone,'distance',0.2,'speed',1);
    moveup(drone,'distance',0.2,'speed',1);  
    elseif i==2
         moveright(drone,'distance',0.4,'speed',1);
    elseif i==3
         movedown(drone,'distance',0.4,'speed',1);
    elseif i==4
        moveleft(drone,'distance',0.4,'speed',1);        
    end   
end
%1~3m 이동
moveforward(drone."Distance",2.5);
%빨간색이 보이면 90' 좌측 turn
moveforward(drone,'Distance',0.2);
while 1
pause(1);

frame = snapshot(camera1);
pause(1);

hsv = rgb2hsv(frame);
h = hsv(:,:,1);
detect_turn = (h > 0.0125) & (h < 0.0375);

if sum(detect_turn,'all') >= 17000
turn(drone,deg2rad(-90));
break
end
end
%turn 한 뒤에 1~3m 이동
moveforward(drone,'Distance',2.5);
%위치조정
while 1
    i=i+1;

frame = snapshot(camera1);

hsv = rgb2hsv(frame);
h = hsv(:,:,1);
detect_green = (h > 0.6) & (h < 0.625);

if sum(detect_green, 'all') >= 25000

     if sum(imcrop(detect_green,[0 0 480 720]),'all')-sum(imcrop(detect_green,[480 0 960 720]),'all')>6500
                moveleft(drone,'distance',0.2,'speed',1);
            elseif sum(imcrop(detect_green,[480 0 960 720]),'all')-sum(imcrop(detect_green,[0 0 480 720]),'all')>6500
                moveright(drone,'distance',0.2,'speed',1);
     end
      if sum(imcrop(detect_green,[0 0 960 360]),'all')-sum(imcrop(detect_green,[0 360 960 720]),'all')>6500
                movedown(drone,'distance',0.2,'speed',1);
            elseif sum(imcrop(detect_green,[0 360 960 720]),'all')-sum(imcrop(detect_green,[0 0 960 360]),'all')>6500
                moveup(drone,'distance',0.2,'speed',1);
      end
           break
else
    if i==1
    moveleft(drone,'distance',0.2,'speed',1);
    moveup(drone,'distance',0.2,'speed',1);  
    elseif i==2
         moveright(drone,'distance',0.4,'speed',1);
    elseif i==3
         movedown(drone,'distance',0.4,'speed',1);
    elseif i==4
        moveleft(drone,'distance',0.4,'speed',1);        
    end   
end
%빨간색이 보이면 90' 좌측 turn
moveforward(drone,'Distance',0.2);
while 1
pause(1);

frame = snapshot(camera1);
pause(1);

hsv = rgb2hsv(frame);
h = hsv(:,:,1);
detect_turn = (h > 0.0125) & (h < 0.0375);

if sum(detect_turn,'all') >= 17000
turn(drone,deg2rad(-90));
break
end
end
%turn 한 뒤에 1~3m 이동
moveforward(drone,'Distance',2.5);
%위치조정
while 1
    i=i+1;

frame = snapshot(camera1);

hsv = rgb2hsv(frame);
h = hsv(:,:,1);
detect_green = (h > 0.6) & (h < 0.625);

if sum(detect_green, 'all') >= 25000

     if sum(imcrop(detect_green,[0 0 480 720]),'all')-sum(imcrop(detect_green,[480 0 960 720]),'all')>6500
                moveleft(drone,'distance',0.2,'speed',1);
            elseif sum(imcrop(detect_green,[480 0 960 720]),'all')-sum(imcrop(detect_green,[0 0 480 720]),'all')>6500
                moveright(drone,'distance',0.2,'speed',1);
     end
      if sum(imcrop(detect_green,[0 0 960 360]),'all')-sum(imcrop(detect_green,[0 360 960 720]),'all')>6500
                movedown(drone,'distance',0.2,'speed',1);
            elseif sum(imcrop(detect_green,[0 360 960 720]),'all')-sum(imcrop(detect_green,[0 0 960 360]),'all')>6500
                moveup(drone,'distance',0.2,'speed',1);
      end
           break
else
    if i==1
    moveleft(drone,'distance',0.2,'speed',1);
    moveup(drone,'distance',0.2,'speed',1);  
    elseif i==2
         moveright(drone,'distance',0.4,'speed',1);
    elseif i==3
         movedown(drone,'distance',0.4,'speed',1);
    elseif i==4
        moveleft(drone,'distance',0.4,'speed',1);        
    end   
end
%파랑색이 보이면 착지
while 1
pause(1);

frame = snapshot(camera1);
pause(1);

hsv = rgb2hsv(frame);
h = hsv(:,:,1);
detect_land = (h > 0.7375) & (h < 0.7675);

if sum(detect_land,'all') >= 17000
land(drone);
break
end
end