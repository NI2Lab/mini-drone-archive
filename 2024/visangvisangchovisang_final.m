%% Mini Drone Competition 2024 - 비상비상초비상
% Youngjun Jeon, Jinwoo Ha, Jiwon Seo
% KIEE 2024/07/11

%% (0) Drone Initialization
clear
drone = ryze()
cam = camera(drone);
takeoff(drone);
tic
move(drone,[-0.2,0,-0.6],'speed',0.5);
gray_error = 0;
level = 1;
format long
x_rc = 480;
e_count = 0;
add = 0.75;
pic_num = 1;
pic = {};
L_add = 0.05;
error = 0;
error_blue = 0;
threshold = 1000;

while 1
    %% (1) Level Setting
    if level == 1
        L = 0.57 + L_add;
        y_rc = 180;
        r = [12.112785246855540;-0.112318420979197;5.193367486402072e-04;-1.271369725301128e-06;1.570377189160116e-09;-7.695558755592146e-13];
        disp('Level 1 start')
    elseif level == 2
        L = 0.46 ;
        y_rc = 190;
        H = readHeight(drone);
        disp('Level 2 start')
        
    elseif level == 3
        L = 0.46;
        y_rc = 190;
        H = readHeight(drone);
        disp('Level 3 start')
        
    else
        L = 0.52;
        y_rc = 180;
        r = [14.418878808623500;-0.167167270744241;9.696092698112550e-04;-2.988626315852980e-06;4.665089042371920e-09;-2.895562197103830e-12];
        disp('Level 4 start')
    end

    %% (2) Control the yaw to be perpendicular to the obstacle in level 4

    if level == 4
        while 1
            % Snapshot with Fail-safe code
            while 1
                snap = snapshot(cam);
                gray = Image_Fail_Safe_RGB(snap,500,120,140);
                props2 = regionprops(gray, 'MajorAxisLength');
                major = [props2.MajorAxisLength];

                if isempty(major) == 1
                    break
                elseif max(major) < 1000
                    break
                else
                    e_count = e_count + 1;
                    if e_count > 100
                        e_count = 0;
                        gray_error = gray_error + 1;
                        disp("Wifi error occured")
                        break
                    end
                end
            end
            
            % Image Processing for Obstacles
            blue = find_color(snap,1500,0.55,0.7,0.5);
            BWa = ~blue;
            BWa = bwareaopen(BWa,1500);
            Diameter = [];

            % Find Diameter
            try
                [~,point_yaw] = diameter_chase(BWa,120,700);
                x_yaw = point_yaw(1);
                y_yaw = point_yaw(2);
            catch
                disp("Fail to find diameter - yaw control")
                break 
            end
            
            % Detect Side Line
            invBWa = bwareafilt(~BWa,1);
            BWa = ~invBWa;
            try
            [pixel_diff,n,tt1,tt2,tt3,tt4] = Yaw_Control(BWa,x_yaw,y_yaw);
            catch
                break 
            end
            

            % Plot
            pic{pic_num} = snap;
            subplot(5,5,pic_num)
            imshow(BWa)
            hold on
            title('Yaw')
            plot(tt1(1)+x_yaw,tt1(2)+y_yaw,'r.',tt2(1)+x_yaw,tt2(2)+y_yaw,'r.',tt3(1)+x_yaw,tt3(2)+y_yaw,'r.',tt4(1)+x_yaw,tt4(2)+y_yaw,'r.','MarkerSize',10)
            fprintf("yaw_control : pixel_diff =  %d deg \n", pixel_diff)
            hold off
            
            % Yaw Control
            if (pixel_diff >= 10) && (pixel_diff <= 70)
                if n == 1
                    turn(drone,deg2rad(5));
                else
                    turn(drone,deg2rad(-5));
                end
            elseif pixel_diff > 70
                break
            else
                pic_num = pic_num + 1;
                break
            end
            pic_num = pic_num + 1;
        end
        moveforward(drone,'distance',0.8,'speed',1);
        pause(0.5);
    end

    %% (3) Control to Centroid and Move Forward

    while 1
        % Snapshot with Fail-safe code
        while 1
            snap = snapshot(cam);
            gray = Image_Fail_Safe_RGB(snap,500,120,140);
            props2 = regionprops(gray, 'MajorAxisLength');
            major = [props2.MajorAxisLength];

            if isempty(major) == 1
                break
            elseif max(major) < 1000
                break
            else
                e_count = e_count + 1;
                if e_count > 100
                    e_count = 0;
                    gray_error = gray_error + 1;
                    disp("Wifi error occured")
                    break
                end
            end
        end

        % Image Processing for Obstacles
        blue = find_color(snap,1500,0.55,0.7,0.5);
        if numel(find(blue)) < 80000
            error_blue = error_blue + 1;
            if error_blue < 5
                continue;
            end
        end
        BWa = ~blue;
        BWa = bwareaopen(BWa,1500);
        Diameter = [];
        
        % Plot
        pic{pic_num} = snap;
        subplot(5,5,pic_num)
        imshow(BWa)
        title('centroid')
        hold on

        % Find Centroid : 1) Centorid chase 2) Box chase
        try
            [Diameter,Centroid] = diameter_chase(BWa,120,700);
        catch
            disp("Fail to find diameter - centroid control")
        end
        if isempty(Diameter) == 1
            try
                [Boundary,Point] = line_chase(blue,800);
            catch
                disp("Fail to find line - centroid control")
                if error > 5
                    turn(drone,deg2rad(10));
                    error = error + 1;
                end
                continue 
            end
            disp('Line chase')
            Centroid(1) = Point(1);
            Centroid(2) = Point(2);
            Diameter = 0;
        else
            disp('Diameter chase')
            error = 0;
        end
        x_mc = Centroid(1);
        y_mc = Centroid(2);
        
        % Plot
        plot(x_mc,y_mc,'b.',x_rc,y_rc,'r.','MarkerSize',10)
        hold off
        pic_num = pic_num +1;

        % Calculate the distance to Centroid
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

        % Move to Centroid based on Calculated values
        disp('Move to centroid')
        if (move_d_x > 0.1) && ( move_d_y > 0.1)
            if (x == 1) && (y == 1)
                move(drone,[0,move_d_x,move_d_y]);
            elseif (x == 1) && (y == -1)
                move(drone,[0,move_d_x,-move_d_y]);
            elseif (x == -1) && (y == -1)
                move(drone,[0,-move_d_x,-move_d_y]);
            elseif (x == -1) && (y == 1)
                move(drone,[0,-move_d_x,move_d_y]);
            end
        elseif (move_d_x > 0.1) && (move_d_y <= 0.1)
            if x == 1
                moveright(drone,'distance',move_d_x,'speed',0.6)
            elseif x == -1
                moveleft(drone,'distance',move_d_x,'speed',0.6)
            end
        elseif (move_d_y > 0.1) && (move_d_x <= 0.1)
            if y == 1
                movedown(drone,'distance',move_d_y,'speed',0.6)
            elseif y == -1
                moveup(drone,'distance',move_d_y,'speed',0.6)
            end
        else
            disp('Centroid!!')
            x = 0;
            y = 0;
            break
        end
    end

    %% (4) Check Color Point & Move to Next Level

    if (level == 1)

        % Snapshot with Fail-safe code
        while 1
            snap = snapshot(cam);
            gray = Image_Fail_Safe_RGB(snap,500,120,140);
            props2 = regionprops(gray, 'MajorAxisLength');
            major = [props2.MajorAxisLength];

            if isempty(major) == 1
                break
            elseif max(major) < 1000
                break
            else
                e_count = e_count + 1;
                if e_count > 100
                    e_count = 0;
                    gray_error = gray_error + 1;
                    disp("Wifi error occured")
                    break
                end
            end
        end

        % Check the color point - red
        red = find_color(snap,70,0.001,0.05,0.4);
        try
            [~,point_red] = diameter_chase(red,10,300);
            x_mc_red = point_red(1);
            y_mc_red = point_red(2);
            e_red = (abs(x_mc_red - 480) + abs(y_mc_red - 360));
            if e_red > threshold
                disp("find the color 1 - red")
            end
        catch
            disp("find the color 2 - red")
        end

        % Move forward - level 1
        offset = 0.1;
        distance_1 = r(1) + r(2).*Diameter+r(3).*Diameter.^2 + r(4).*Diameter.^3 + r(5).*Diameter.^4 + r(6).*Diameter.^5 + offset;
        move_d_f = distance_1 + 1.8 - 0.1;
        if move_d_f > 3.6
            move_d_f = 3.6;
        elseif move_d_f < 3.40
            move_d_f = 3.40;
        end
        fprintf("Level 1, Move Forward - %d m \n", move_d_f)
        moveforward(drone,'distance',move_d_f,'speed',1);
        turn(drone,deg2rad(130));
        move(drone,[3.0,0,-0.3],'Speed',1);
        pause(0.5);
        level = level + 1;

    elseif (level == 2)

        % Snapshot with Fail-safe code
        while 1
            snap = snapshot(cam);
            gray = Image_Fail_Safe_RGB(snap,500,120,140);
            props2 = regionprops(gray, 'MajorAxisLength');
            major = [props2.MajorAxisLength];

            if isempty(major) == 1
                break
            elseif max(major) < 1000
                break
            else
                e_count = e_count + 1;
                if e_count > 100
                    e_count = 0;
                    gray_error = gray_error + 1;
                    disp("Wifi error occured")
                    break
                end
            end
        end

        % Check the color point - green
        green = find_color(snap,100,0.38,0.47,0.4);
        try
            [~,point_green] = diameter_chase(green,10,700);
            x_mc_green = point_green(1);
            y_mc_green = point_green(2);
            e_green = (abs(x_mc_green - 480) + abs(y_mc_green - 360));
            if e_green > threshold
                disp("find the color 1 - green")
            end
        catch
            disp("find the color 2 - green")
        end
        
        % Move forward - level 2
        fprintf("Level 2, Move Forward - %d m \n", 1.8)
        moveforward(drone,'distance',1.8,'speed',1);
        turn(drone,deg2rad(-130));
        pause(0.5);
        move(drone,[0.7,0,-0.3],'Speed',0.5);
        level = level + 1;

    elseif (level == 3)

        % Snapshot with Fail-safe code
        while 1
            snap = snapshot(cam);
            gray = Image_Fail_Safe_RGB(snap,500,120,140);
            props2 = regionprops(gray, 'MajorAxisLength');
            major = [props2.MajorAxisLength];

            if isempty(major) == 1
                break
            elseif max(major) < 1000
                break
            else
                e_count = e_count + 1;
                if e_count > 100
                    e_count = 0;
                    gray_error = gray_error + 1;
                    disp("Wifi error occured")
                    break
                end
            end
        end

        % Check the color point - purple
        purple = find_color(snap,100,0.65,0.79,0.05);
        try
            [~,point_purple] = diameter_chase(purple,10,200);
            x_mc_purple = point_purple(1);
            y_mc_purple = point_purple(2);
            e_purple = (abs(x_mc_purple - 480) + abs(y_mc_purple - 360));
            if e_purple > threshold
                disp("find the color 2 - purple")
            end
        catch
            disp("find the color 2 - purple")
        end
        
        % Move forward - level 3
        fprintf("Level 3, Move Forward - %d m \n", 1.9)
        moveforward(drone,'distance',1.9,'speed',1);
        pause(0.5)
        turn(drone,deg2rad(215));
        move(drone,[0.3,0,-0.3],'Speed',0.5);
        level = level + 1;

    else
        
        % Snapshot with Fail-safe code
        while 1
            snap = snapshot(cam);
            gray = Image_Fail_Safe_RGB(snap,500,120,140);
            props2 = regionprops(gray, 'MajorAxisLength');
            major = [props2.MajorAxisLength];

            if isempty(major) == 1
                break
            elseif max(major) < 1000
                break
            else
                e_count = e_count + 1;
                if e_count > 100
                    e_count = 0;
                    gray_error = gray_error + 1;
                    disp("Wifi error occured")
                    break
                end
            end
        end

        % Check the color point - red
        red = find_color(snap,70,0.001,0.05,0.4);
        try
            [~,point_red] = diameter_chase(red,10,300);
            x_mc_red = point_red(1);
            y_mc_red = point_red(2);
            e_red = (abs(x_mc_red - 480) + abs(y_mc_red - 360));
            if e_red > threshold
            disp("find the color 1 - red")
            end
        catch
            disp("find the color 2 - red")
        end

        % Move forward - level 4
        distance = r(1) + r(2).*Diameter+r(3).*Diameter.^2 + r(4).*Diameter.^3 + r(5).*Diameter.^4 + r(6).*Diameter.^5;
        move_d_forward = round(distance,1);
        fprintf("Move Forward - %d m \n",move_d_forward + add)
        moveforward(drone, 'distance', move_d_forward + add,'speed',1);
        land(drone);
        toc
        break
    end
end

%% Functions
function [Diameter,Centroid] = diameter_chase(BWa,remove,max)

props = regionprops(BWa,'Centroid', 'MajorAxisLength', 'MinorAxisLength');
points = [props.Centroid];
major = [props.MajorAxisLength];
minor = [props.MinorAxisLength];
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

function color = find_color(snap,remove,min,max,s_value)

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

function [a,b,fin1,fin2,fin3,fin4] = Yaw_Control(BWa,x_mc,y_mc)

%b=1 --> CW
%b=0 --> CCW

tt = bwperim(~BWa);

[y2,x2] = find(tt);

xx2 = x2 - x_mc;
yy2 = y2 - y_mc;

A = [xx2,yy2];

area1 = A(A(:,1) > 0 & A(:,2) > 0, :);
area2 = A(A(:,1) < 0 & A(:,2) > 0, :);
area3 = A(A(:,1) < 0 & A(:,2) < 0, :);
area4 = A(A(:,1) > 0 & A(:,2) < 0, :);
testarea1 = ((area1(:,1)).^2) + ((area1(:,2)).^2);
[~,maxnum1] = max(testarea1);
fin1 = area1(maxnum1,:);

testarea2 = ((area2(:,1)).^2) + ((area2(:,2)).^2);
[~,maxnum2] = max(testarea2);
fin2 = area2(maxnum2,:);

testarea3 = ((area3(:,1)).^2) + ((area3(:,2)).^2);
[~,maxnum3] = max(testarea3);
fin3 = area3(maxnum3,:);

testarea4 = ((area4(:,1)).^2) + ((area4(:,2)).^2);
[~,maxnum4] = max(testarea4);
fin4 = area4(maxnum4,:);

left = fin2(2) - fin3(2);
right = fin1(2) - fin4(2);

a = abs(right - left);


if right > left
    b = 1;
else
    b = 0;
end

end

function color = Image_Fail_Safe_RGB(snap,remove,down,up)

rgb = snap;
r = rgb(:,:,1);
g = rgb(:,:,2);
b = rgb(:,:,3);
color = zeros(720,960);
try
    for i = 1: 720
        for j = 1:960
            if (r(i, j) > down) && (r(i, j) < up) && (b(i, j) > down) && (b(i, j) < up) && (g(i, j) > down) && (g(i, j) < up)
                color(i, j) = 1;
            end
        end
    end
    color = bwareaopen(color,remove);
    color_inv = bwareaopen(~color,remove);
    color = ~color_inv;

catch
end
end
