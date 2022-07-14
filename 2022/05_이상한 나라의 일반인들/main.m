droneObj=ryze("Tello")
cam=camera(droneObj);
takeoff(droneObj);
pause(1);
%중점 찾기...





while 1
        %빨간색 크기 비교 앞으로 90도 돌기
        moveforward(droneObj,'speed',1);
        pause(1);
        frame=snapshot(cam);
        pause(1);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        red=(0.6<h)&(h<0.8);
        if sum(red,'all') <400
            if sum(red,'all') >=400
                    moveforward(drone,'distance',0.2);
            end
            turn(drone,deg2rad(90))
            break;
        end
end
%중점 찾기...



while 1
        %초록색 크기 비교 앞으로 125도 정도 돌기
        moveforward(droneObj,'speed',1);
        pause(1);
        frame=snapshot(cam);
        pause(1);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        green=(0.27<h)&(h<0.32);
        if sum(green,'all') <400
            if sum(green,'all') >=400
                    moveforward(drone,'distance',0.2);
            end
            turn(drone,deg2rad(125))
            break;
        end
end
%중점 찾기 

   






while 1
        %보라색 크기 비교 착륙
        moveforward(droneObj,'speed',1);
        pause(1);
        frame=snapshot(cam);
        pause(1);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        p=(0.7<h)&(h<0.8);
        if sum(p,'all') <400
            if sum(p,'all') >=400
                    moveforward(drone,'distance',0.2);
            end
            land(droneObj);
            break;
        end
end




