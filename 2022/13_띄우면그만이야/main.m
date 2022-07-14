DroneObj=ryze()
cam=camera(DroneObj);
takeoff(DroneObj);


for phase=1:1:3

    while 1
        
        
        frame=snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        
        
        blue = (0.5<h)&(h<0.7)&(0.2<s)&(s<0.8);
        
        
        blue(1,:) = 1;
        blue(720,:) = 1;
  
        
        threshold = imfill(blue,'holes');
        
        threshold = logical(threshold - blue);
        threshold = bwareafilt(threshold,1);
        circle = 30000;
        

        if sum(threshold,'all')>circle
            break;
        else
            
                if sum(imcrop(blue,[0, 0, 480, 720]),'all')-sum(imcrop(blue,[480, 0, 960, 720]),'all')>20000
                    moveleft(DroneObj,'distance',0.2,'speed',1);
                elseif sum(imcrop(blue,[480, 0, 960, 720]),'all')-sum(imcrop(blue,[0, 0, 480, 720]),'all')>20000
                    moveright(DroneObj,'distance',0.4,'speed',1);
                end

                if sum(imcrop(blue,[0, 0, 960, 360]),'all')-sum(imcrop(blue,[0, 360, 960, 720]),'all')>20000
                    moveup(DroneObj,'distance',0.2,'speed',1);
                elseif sum(imcrop(blue,[0, 360, 960, 720]),'all')-sum(imcrop(blue,[0, 0, 960, 360]),'all')>20000
                    movedown(DroneObj,'distance',0.2,'speed',1);
                end
            
        end
    end
   


    if phase==1
        
        moveforward(DroneObj,'Distance',1.5,'speed',1);
       
        while 1
           
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            
            green = (0.3<h)&(h<0.43)&(0.4<s)&(s<0.9);
            green = bwareafilt(green,1);
            if sum(red,'all')>2000
                turn(DroneObj,deg2rad(90))
                break;

            else
                moveforward(DroneObj,'Speed',1,'Distance',0.2);
                
            end

        end
        moveforward(DroneObj,'Distance',0.5,'speed',1);

    elseif phase==2
        moveforward(DroneObj,'Distance',1,'speed',1);
        
        while 1
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            
            purple= (0.74<h)&(h<0.84)&(0.325<s)&(s<0.8);
            purple = bwareafilt(purple,1);
                       

                        
            if sum(purple,'all')>2000
            
                turn(DroneObj,deg2rad(120))
                
                break;
                    
           
            else
                moveforward(DroneObj,'distance',0.2)
            end
        end
        move(DroneObj,[1, -1, 0],'Speed',1)
        moveforward(DroneObj,'Distance',1,'Speed',1)
        
        
 
    elseif phase==3
        moveforward(DroneObj,'distance',0.5,'speed',1);
        
        while 1
            
            frame=snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
           
            red = (0<h)&(h<0.08)&(s<1);
            red = bwareafilt(red,1);
            
            if sum(red,'all')>2000
                land(DroneObj);
                break;
            else
                moveforward(DroneObj,'distance',0.2)
                
            end
        end
    end
end

