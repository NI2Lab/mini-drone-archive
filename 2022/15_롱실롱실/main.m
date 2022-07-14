%% (0) Initial Setting
drone = ryze()
cam = camera(drone); %카메라 연
level = 1;
k = 1;
D = 0.78;
%% (0.1) Hovering
takeoff(drone); %이륙
moveup(drone,'Distance',0.5,'Speed',1);

%% (1) First_Step
while 1
    while 1
        img = make_snap(cam);
        [Centroids,Diameter] = Hole_Center(img);
        if Centroids(1) < 0 
            Centroids = Box_center(img);
            k = k + 1;
        end
        x = Centroids(1);
        y = Centroids(2);
        imshow(img);
        hold on
        plot(x,y,'r*');
        hold off


        %드론 좌우 제어 구문
        u = abs(x - 480);
        p = abs(y - 215);
        dx = D*(u)/Diameter;
        dy = D*(p)/Diameter;


        if k > 4
            moveup(drone,'Distance',0.5);
            k = 1;
        else
            if Diameter < 100
                if 20 < u || 20 < p
                    if 20 < u && 480 < x
                        moveright(drone,'distance',0.3);
                    elseif 20 < u && x < 480
                        moveleft(drone,'distance',0.3);
                    end
                    if 20 < p && 215 < y
                        movedown(drone,'distance',0.3);
                    elseif 20 < p && y < 215
                        moveup(drone,'distance',0.3);
                    end
                else
                    moveup(drone,'distance',0.2);
                end
            else
                if 0.2 < dx || 0.2 < dy
                    if 0.2 < dx && 480 < x
                        moveright(drone,'distance',round(dx,1));
                    elseif 0.2 < dx && x < 480 
                        moveleft(drone,'distance',round(dx,1));
                    end
                    if 0.2 < dy && 215 < y
                        movedown(drone,'distance',round(dy,1));
                    elseif 0.2 < dy && y < 215 
                        moveup(drone,'distance',round(dy,1));
                    end
                else
                    break;
                end
            end
        end
    end

        %드론 전진 제어 구문
        img = make_snap(cam);
        pixel = checking_circle_half(~img);
        if level == 1
            distance = first_go(pixel);
            movedown(drone,'distance',0.3,'Speed',1);
            moveforward(drone,'distance',distance,'Speed',1);

            turn(drone,deg2rad(90));

            moveforward(drone,'Distance',1.2,'Speed',1);
            level = level + 1;
            D = 0.57;
        elseif level == 2
            
            distance = second_go(pixel);

            moveforward(drone,'distance',distance,'Speed',1.0);
            H = readHeight(drone);
            if H < 0.75
                moveup(drone,'distance',0.5);
            end
            moveright(drone,'Distance',1.4,'Speed',1.0);
            turn(drone,deg2rad(135));
            moveforward(drone,'Distance',0.4,'Speed',1.0);
            level = level + 1;
            D = 0.5;
        else

            distance = third_go(pixel);

            moveforward(drone,'distance',distance,'Speed',1);
            land(drone);
        end

end


function bw2 = make_snap(cam)
    snap = snapshot(cam);
    img = snap;
    hsv = rgb2hsv(img);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    masked_blue = (0.55<h)&(h<0.7)&(0.4<s);

    bw2 = ~masked_blue;
    bw2 = bwareaopen(bw2,1000);

end

function [Centroid,Diameter] = Hole_Center(bw2)

    props = regionprops(bw2,'BoundingBox', 'Centroid', 'Area','Circularity','MajorAxisLength','MinorAxisLength');
    length = size(props(:,1));
    length = length(:,1);


    for i = 1:length
        c(i) = props(i,:).Circularity;
    end

    [~,num] = max(c);
    Cir = props(num,:).Circularity;
    MaxD = props(num,:).MajorAxisLength;
    MinD = props(num,:).MinorAxisLength;

    pixel = checking_circle_half(~bw2);
    fprintf("Pixel : %d\n",pixel);
    if pixel < 20
        Centroid = [-1,-1];
        Diameter = 0;
    else
        x = props(num,:).Centroid(1);
        y = props(num,:).Centroid(2);
        
    Centroid = [x, y];
    Diameter = (MaxD + MinD) / 2;
    end
end

function [Centroid]= Box_center(bw2)
    props = regionprops(~bw2,'Image','BoundingBox','centroid','Area');
    length = size(props(:,1));
    length = length(:,1);


    for i = 1:length
        Area(i) = props(i,:).Area;
    end

    [~,num] = max(Area);


    x1 = props(num,:).BoundingBox(1);
    y1 = props(num,:).BoundingBox(2);
    dx =  props(num,:).BoundingBox(3);
    dy =  props(num,:).BoundingBox(4);
    x = x1+(dx/2);
    y = y1+(dy/2);

    Centroid=[x y];
end

function Go_1 = first_go(Circle)
    x_1 = Circle;
    p1 = 0.5997;
    p2 = 2.154e+05;
    q1 = 3.494e+04;
    
    Distance = (p1*x_1 + p2) / (x_1 + q1); 
    Go_1 = round(Distance,1) + 0.7;
end

function Go_2 = second_go(Circle)
    x_2 = Circle;
    p1 = 0.6098; 
    p2 = 1.182e+05;
    q1 = 1.941e+04;
    Distance = (p1*x_2 + p2) / (x_2 + q1); 
    Go_2 = round(Distance,1) + 0.6; 
end

function Go_3 = third_go(Circle)
    x_3 = Circle;
    a = 2.838;
    b = -7.117e-05;
    c = 2.576;
    d = -7.089e-06;
    Distance = a*exp(b*x_3) + c*exp(d*x_3);
    Go_3 = round(Distance,1) + 0.6;
end

function pixel = checking_circle_half(masked_blue)
    hole = imfill(masked_blue,'holes');
    holes = sum(hole,'all');
    blue = sum(masked_blue,"all");
    pixel = holes - blue;
end
