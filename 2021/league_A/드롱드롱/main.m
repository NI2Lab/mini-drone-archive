%% (0)Drone Setting
clear
drone = ryze()
cam = camera(drone);
takeoff(drone);
moveup(drone,'distance',0.3,'speed',1.0);
level = 1;
format long
x_rc = 480;
%% (1) Initial Setting
while 1
    B = 1;
    if level == 1
        L = 0.78;
        y_rc = 210;
        r = [11.708523799059606;-0.072422126629259;2.062822408761772e-04;-2.524281451187693e-07;4.621395418467465e-11;9.564242384859517e-14];
        add = 0.4;
        meter = 1.7;
    elseif level == 2
        L = 0.57;
        y_rc = 190;
        r = [12.112785246855540;-0.112318420979197;5.193367486402072e-04;-1.271369725301128e-06;1.570377189160116e-09;-7.695558755592146e-13];
        add = 0.4;
        meter = 1.3;
        H = readHeight(drone);
        if H < 1.4
            moveup(drone,'distance', 1.6 - H,'speed',1.0);
        end
    else
        L = 0.5;
        y_rc = 180;
        r = [10.489841751625795;-0.092956004970590;4.070482765361965e-04;-9.378743039005723e-07;1.082348034135494e-09;-4.917339891536912e-13];
        add = 0.4;
        meter = 1.4;
         H = readHeight(drone);
        if H < 2.0
            movedown(drone,'distance', 2.4 - H,'speed',1.0);
        end
    end
%% (2) Control to Centroid and Move Forward   
    while 1
        blue = find_color(cam,800,0.55,0.7,0.4);
        BWa = ~blue;
        BWa = bwareaopen(BWa,500);
        subplot(2,1,2), imshow(BWa)
        Diameter = [];
        try
            [Diameter,Centroid] = diameter_chase(BWa,120,550);
        catch
        end
        if isempty(Diameter) == 1
            try
                [Boundary,Point] = line_chase(blue,800);
            catch
                B = 0;
                break
            end
                Centroid(1) = Point(1);
                Centroid(2) = Point(2);
                Diameter = 0;
        end
        x_mc = Centroid(1);
        y_mc = Centroid(2);
        if Diameter == 0
            d_x = x_mc - x_rc;
            d_y = y_mc - y_rc;
            if abs(d_x) > 240
                move_d_x = 0.4;
            else 
                move_d_x = 0.2;
            end
            if abs(d_y) > 180
                move_d_y = 0.3;
            else
                move_d_y = 0.2;
            end
        else
            if Diameter < 200
                m_Diameter = 200;
            else
                m_Diameter = Diameter;
            end
            d_x = L * (x_mc - x_rc)/m_Diameter;
            d_y = L * (y_mc - y_rc)/m_Diameter;
            if (abs(d_x) > 0.1)&&(abs(d_x) < 0.2)
            move_d_x = 0.2;
            else
                move_d_x = round(abs(d_x),1);
            end
            if (abs(d_y) > 0.1)&&(abs(d_y) < 0.2)
                move_d_y = 0.2;
            else
                move_d_y = round(abs(d_y),1);
            end
        end
        x = sign(d_x);
        y = sign(d_y);
        if move_d_x > 0.1
            if x == 1
                moveright(drone,'distance',move_d_x,'speed',0.6)
            elseif x == -1
                moveleft(drone,'distance',move_d_x,'speed',0.6)
            end
        else
            x = 0;
        end
        if move_d_y > 0.1
            if y == 1
                movedown(drone,'distance',move_d_y,'speed',0.6)
            elseif y == -1
                moveup(drone,'distance',move_d_y,'speed',0.6)
            end
        else
            y = 0;
        end
        if (x == 0) && (y == 0)
            distance = r(1)+r(2).*Diameter+r(3).*Diameter.^2+r(4).*Diameter.^3+r(5).*Diameter.^4+r(6).*Diameter.^5;
             move_d_forward = round(distance,1);
            if move_d_forward > meter
                    move_d_forward = move_d_forward - meter;
                if (move_d_forward < 0.3)
                    move_d_forward = move_d_forward + meter + add;
                    moveforward(drone,'distance',move_d_forward,'speed',1.0);
                    break
                else
                    moveforward(drone,'distance',move_d_forward,'speed',1.0);
                end
            else
                move_d_forward = move_d_forward + add;
                moveforward(drone,'distance',move_d_forward,'speed',1.0);
                break
            end
         end
    end
%% (3) Check Color Point
    k = 0;
    while 1
        if B == 0
            moveup(drone,'distance',0.3,'speed',1.0);
            break
        end
        if (level == 1)||(level ==2)
            red = find_color(cam,50,0.001,0.05,0.8);
                th_red = numel(find(red));
                if k == 2
                    th_red = 3000;
                end
            if (th_red < 2000)
                moveforward(drone,'distance',0.2,'speed',0.6)
                 k = k + 1;
            elseif th_red > 2000
                turn(drone,deg2rad(-90));
                moveforward(drone,'distance',1.2,'speed',1.0);
                level = level + 1;
                break
            end
        else
            purple = find_color(cam,10,0.725,0.825,0.3);
            th_pp = numel(find(purple));
            if k == 2
                th_pp = 3000;
            end
            if th_pp < 1500
                moveforward(drone,'distance',0.2,'speed',0.6)
                k = k + 1;
            else
                level = 4;
                land(drone);
                break
            end
        end
    end
    if level == 4
        break
    end
end   
%% Functions
function [Diameter,Centroid] = diameter_chase(BWa,remove,max)
    stats = regionprops(BWa,'Centroid', 'MajorAxisLength', 'MinorAxisLength');
    points = [stats.Centroid];
    major = [stats.MajorAxisLength];
    minor = [stats.MinorAxisLength];
    [diameters] = (major+minor)/2;
    i = 0;
    while 1
        try
        i = i + 1;
            if major(i)/minor(i) > 4
                major(i) = [];
                minor(i) = [];
                points(2*i-1) = [];
                points(2*i-1) =[];
                diameters(i) = [];
                i = i - 1;
            end
        catch
            break
        end
    end
    i = 0;
    while 1
        i = i + 1;
        try
            if diameters(i) < remove
                points(2*i-1) = [];
                points(2*i-1) =[];
                diameters(i) = [];
                i = i - 1;
            end
        catch
            break
        end
    end
    D = diameters';
    P = points;

    for k = 1:length(P)/2
        Center(k,1) = P(1,2*k-1);
        Center(k,2) = P(1,2*k);
    end
    [Diameter,num] = min(D);
    Centroid = Center(num,:);
    if Diameter > max
        Diameter = [];
        Centroid = [];
    end
end

function [Boundary,Point] = line_chase(BWa,remove)
    Boundary = bwboundaries(BWa);
    C = cellfun(@length,Boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if C(i) < remove
                Boundary(i) = [];
                C(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    for j = 1:length(Boundary)
        Bn = Boundary(j);
        B_mat = cell2mat(Bn);
        M(j) = length(B_mat);
    end
    [~, num] = min(M);
    M2 = cell2mat(Boundary(num));
    center_x = mean(M2(:,2));
    center_y = mean(M2(:,1));
    Point = [center_x,center_y];
end

function color = find_color(cam,remove,min,max,s_value)
    snap = snapshot(cam);
    hsv = rgb2hsv(snap);
    h = hsv(:,:,1); 
    s = hsv(:,:,2); 
    color = zeros(720,960);
    try
        for i = 1: 720
            for j = 1:960
                if (h(i, j)> min) && (h(i, j) < max) && (s(i,j) > s_value)
                    color(i, j) = 1;
                end
            end
        end
        color = bwareaopen(color,remove);
    catch
    end
end
