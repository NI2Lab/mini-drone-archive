%% drone objection
drone=ryze()
cam = camera(drone);

%% take off
takeoff(drone);
moveup(drone,'Distance',0.5,'Speed',1);

% level
for level = 1:3
    
while 1
%% imageprocess

[detectblue_new,canny_img] = imageprocess(cam);

%% edge_detection

[BW3,BW4,B] = edge_detection(canny_img);

%% classification

% centroids_no
if (length(BW4)==1&&min(BW4)==691200)
s_no=regionprops(detectblue_new,'Centroid');
centroids_no=cat(1,s_no.Centroid);

% centroids_half
elseif (length(BW4)>=2&&min(BW4)==691200)
s_half=regionprops(BW3(:,:,B),'Centroid');
centroids_half=cat(1,s_half.Centroid);

% centroids_full
else
p=find((BW4==min(BW4)));
canny_img=BW3(:,:,p);
s_full=regionprops(canny_img,'Centroid');
centroids_full=cat(1,s_full.Centroid);
end

%% No-Control
try
isempty(centroids_no)==0;

distance_x_pixel = centroids_no(:,1)-480;
distance_y_pixel = centroids_no(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);    
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);    
end

centroids_no=[10000,10000];

catch
%% Half-Control
try
isempty(centroids_half)==0;

distance_x_pixel = centroids_half(:,1)-480;
distance_y_pixel = centroids_half(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);    
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
        
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);    
end

centroids_half=[10000,10000];

catch
%% Full-Control

isempty(centroids_full)==0;
centroids=centroids_full;

if level==1
    area_circle1 = pi*(78/2)^2;
    area_circle = area_circle1;
elseif level==2
    area_circle2 = pi*(57/2)^2;
    area_circle = area_circle2;
elseif level==3
    area_circle3 = pi*(50/2)^2;
    area_circle = area_circle3;
end
pixel_circle=min(BW4);
proportion = (area_circle/pixel_circle);

% pixel_distance, real_distance proportion
pixel_all = 720*960;
area_all = proportion*pixel_all;

% distance_dimension [cm]
pixel_length = sqrt(area_all/pixel_all);

% coordinate

[xmat,ymat] = coordinate(canny_img,centroids);

% vertex

[distance_real_x,distance_real_y] = vertex(xmat,ymat,pixel_length);

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',0.7);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',0.7);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',0.7);
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',0.7);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',0.7);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',0.7);    
end

%% imageprocess 2

[detectblue_new,canny_img] = imageprocess(cam);

% edge detection

[BW3,BW4,B] = edge_detection(canny_img);

% classification

% centroids_no
if (length(BW4)==1&&min(BW4)==691200)
s_no=regionprops(detectblue_new,'Centroid');
centroids_no=cat(1,s_no.Centroid);

% centroids_half
elseif (length(BW4)>=2&&min(BW4)==691200)
s_half=regionprops(BW3(:,:,B),'Centroid');
centroids_half=cat(1,s_half.Centroid);

% centroids_full
else
p=find((BW4==min(BW4)));
canny_img=BW3(:,:,p);
s_full=regionprops(canny_img,'Centroid');
centroids_full=cat(1,s_full.Centroid);
end

% No-Control
try
isempty(centroids_no)==0;

distance_x_pixel = centroids_no(:,1)-480;
distance_y_pixel = centroids_no(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);    
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);    
end

centroids_no=[10000,10000];

catch
% Half-Control
try
isempty(centroids_half)==0;

distance_x_pixel = centroids_half(:,1)-480;
distance_y_pixel = centroids_half(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);    
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);    
end

centroids_half=[10000,10000];

catch
% Full-Control

isempty(centroids_full)==0;
centroids=centroids_full;

if level==1
    area_circle1 = pi*(78/2)^2;
    area_circle = area_circle1;
elseif level==2
    area_circle2 = pi*(57/2)^2;
    area_circle = area_circle2;
elseif level==3
    area_circle3 = pi*(50/2)^2;
    area_circle = area_circle3;
end
pixel_circle=min(BW4);
proportion = (area_circle/pixel_circle);

% pixel_distance, real_distance proportion
pixel_all = 720*960;
area_all = proportion*pixel_all;

% distance_dimension [cm]
pixel_length = sqrt(area_all/pixel_all);


% coordinate

[xmat,ymat] = coordinate(canny_img,centroids);

% vertex

[distance_real_x,distance_real_y] = vertex(xmat,ymat,pixel_length);

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',0.7);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',0.7);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',0.7);    
end

    % y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',0.7);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',0.7);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',0.7);    
end

[distance,y_error] = distance_and_compensate(BW4,level);

break
end
end
end
end
end
%% go foward
if level==1
    distance_stop=1.9;
elseif level==2
    distance_stop=1.5;
else
    distance_stop=1.45;
end

if distance > distance_stop
    moveforward(drone,'Distance',(distance-distance_stop+0.2),'Speed',0.4);

% imageprocess
while 1
    
[detectblue_new,canny_img] = imageprocess(cam);


% edge_detection

[BW3,BW4,B] = edge_detection(canny_img);

% classification

% centroids_no
if (length(BW4)==1&&min(BW4)==691200)
s_no=regionprops(detectblue_new,'Centroid');
centroids_no=cat(1,s_no.Centroid);

% centroids_half
elseif (length(BW4)>=2&&min(BW4)==691200)
s_half=regionprops(BW3(:,:,B),'Centroid');
centroids_half=cat(1,s_half.Centroid);

% centroids_full
else
p=find((BW4==min(BW4)));
canny_img=BW3(:,:,p);
s_full=regionprops(canny_img,'Centroid');
centroids_full=cat(1,s_full.Centroid);
end

% No-Control
try
isempty(centroids_no)==0;

distance_x_pixel = centroids_no(:,1)-480;
distance_y_pixel = centroids_no(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);    
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);    
end

centroids_no=[10000,10000];

catch
% Half-Control
try
isempty(centroids_half)==0;

distance_x_pixel = centroids_half(:,1)-480;
distance_y_pixel = centroids_half(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);    
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
        
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);    
end

centroids_half=[10000,10000];

catch
% Full-Control

isempty(centroids_full)==0;
centroids=centroids_full;

if level==1
    area_circle1 = pi*(78/2)^2;
    area_circle = area_circle1;
elseif level==2
    area_circle2 = pi*(57/2)^2;
    area_circle = area_circle2;
elseif level==3
    area_circle3 = pi*(50/2)^2;
    area_circle = area_circle3;
end
pixel_circle=min(BW4);
proportion = (area_circle/pixel_circle);

% pixel_distance, real_distance proportion
pixel_all = 720*960;
area_all = proportion*pixel_all;

% distance_dimension [cm]
pixel_length = sqrt(area_all/pixel_all);

% coordinate

[xmat,ymat] = coordinate(canny_img,centroids);

% vertex

[distance_real_x,distance_real_y] = vertex(xmat,ymat,pixel_length);

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',0.7);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',0.7);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',0.7);    
end

    % y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',0.7);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',0.7);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',0.7);    
end

% imageprocess 2

[detectblue_new,canny_img] = imageprocess(cam);

% edge detection

[BW3,BW4,B] = edge_detection(canny_img);

% classification

% centroids_no
if (length(BW4)==1&&min(BW4)==691200)
s_no=regionprops(detectblue_new,'Centroid');
centroids_no=cat(1,s_no.Centroid);

% centroids_half
elseif (length(BW4)>=2&&min(BW4)==691200)
s_half=regionprops(BW3(:,:,B),'Centroid');
centroids_half=cat(1,s_half.Centroid);

% centroids_full
else
p=find((BW4==min(BW4)));
canny_img=BW3(:,:,p);
s_full=regionprops(canny_img,'Centroid');
centroids_full=cat(1,s_full.Centroid);
end

% No-Control
try
isempty(centroids_no)==0;

distance_x_pixel = centroids_no(:,1)-480;
distance_y_pixel = centroids_no(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);   
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);
end

centroids_no=[10000,10000];

catch
% Half-Control
try
isempty(centroids_half)==0;

distance_x_pixel = centroids_half(:,1)-480;
distance_y_pixel = centroids_half(:,2)-360;

distance_real_x = -(distance_x_pixel)*(0.1125)/100;
distance_real_y = (distance_y_pixel)*(0.1125)/100;

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',1);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',1);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',1);    
end

% y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',1);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',1);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',1);    
end

centroids_half=[10000,10000];

catch
% Full-Control

isempty(centroids_full)==0;
centroids=centroids_full;

if level==1
    area_circle1 = pi*(78/2)^2;
    area_circle = area_circle1;
elseif level==2
    area_circle2 = pi*(57/2)^2;
    area_circle = area_circle2;
elseif level==3
    area_circle3 = pi*(50/2)^2;
    area_circle = area_circle3;
end
pixel_circle=min(BW4);
proportion = (area_circle/pixel_circle);

% pixel_distance, real_distance proportion
pixel_all = 720*960;
area_all = proportion*pixel_all;

% distance_dimension [cm]
pixel_length = sqrt(area_all/pixel_all);

% coordinate

[xmat,ymat] = coordinate(canny_img,centroids);

% vertex

[distance_real_x,distance_real_y] = vertex(xmat,ymat,pixel_length);

% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',0.7);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',0.7);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',0.7);    
end

    % y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',0.7);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',0.7);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',0.7);      
end

break
end
end
end
end
end
% distance_and_compensate

[distance,y_error] = distance_and_compensate(BW4,level);

% y-positioning control
if y_error < 0.1
    
elseif (0.1 <= y_error)&&(y_error<= 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif y_error > 0.2
    movedown(drone,'Distance',y_error,'Speed',1);
    
end
else
%% y-positioning control
if y_error < 0.1
    
elseif (0.1 <= y_error)&&(y_error<= 0.2)
    movedown(drone,'Distance',0.2,'Speed',1);
    
elseif y_error > 0.2
    movedown(drone,'Distance',y_error,'Speed',1);    
end
end

desired_distance = distance+0.4;
moveforward(drone,'Distance',desired_distance,'Speed',1);


%% next process

if level==1
    turn(drone,pi/2);
    
    moveforward(drone,'Distance',1.2,'Speed',1);
    

    [drone_height,time]=readHeight(drone);
    if drone_height<1
        moveup(drone,'Distance',(1.2-drone_height),'Speed',1);
    elseif drone_height>1.75
        movedown(drone,'Distance',(drone_height-1.5),'Speed',1);
    else
        
    end
elseif level==2
    
        [drone_height,time]=readHeight(drone);
    if drone_height<1
        moveup(drone,(1.2-drone_height),'Speed',1);
    elseif drone_height>1.75
        movedown(drone,(drone_height-1.5),'Speed',1);
    else
        
    end

    moveright(drone,'Distance',1.44,'Speed',0.7);
    
    turn(drone,3*pi/4);
    
    moveforward(drone,'Distance',0.3,'Speed',1);
    
elseif level==3
    land(drone);
end



end

%% function-imageprocess
function [detectblue_new,canny_img] = imageprocess(cam)

frame = snapshot(cam);

hsv_img=rgb2hsv(frame);

h=hsv_img(:,:,1);
s=hsv_img(:,:,2);

detect_blue = ((h> 0.55) & (h < 0.7)) & (s> 0.4);
detectblue_new=bwareafilt(detect_blue,1);
detectblue_new_final=bwareafilt(detect_blue,1);
for lr1=2:719
    for lr2=2:959
        if ((detectblue_new(lr1,lr2)==1)&&(detectblue_new(lr1+1,lr2)==1)&&(detectblue_new(lr1-1,lr2)==1)&&(detectblue_new(lr1,lr2+1)==1)&&(detectblue_new(lr1,lr2-1)==1))
            detectblue_new_final(lr1,lr2)=0;
        end
    end
end
canny_img = detectblue_new_final;

canny_img(:,1:2)=0;
canny_img(:,959:960)=0;
canny_img(1:2,:)=0;
canny_img(719:720,:)=0;

canny_img=bwareaopen(canny_img,50);

end

%% function-edge_detection
function [BW3,BW4,B] = edge_detection(canny_img)

count_BW2(1) = sum(bwareafilt(canny_img,1),'all');
BW3(:,:,1) = bwareafilt(canny_img,1);
for i = 2:5
    BW2 = bwareafilt(canny_img,i);
    count_BW2(i) = sum(BW2,'all');
    if count_BW2(i-1) == count_BW2(i)
        i = i - 1;
        break;
    else
        BW3(:,:,i) = BW2;
        for j = 1:i-1
            BW3(:,:,i) = BW3(:,:,i) - BW3(:,:,j);
        end
    end
end

for k = 1:i
    [xpoint,ypoint]=find(BW3(:,:,k)==1);
    if or((abs(max(xpoint)-min(xpoint)) < 30),(abs(max(ypoint)-min(ypoint)) < 30))
        BW3(:,:,k)=ones;
    else
        BW3(:,:,k)=BW3(:,:,k);
    end
    A(k)=sum(BW3(:,:,k),'all');
    B=find(A==min(A));
end

for z=1:i
BW4(z)=sum(imfill(BW3(:,:,z),'holes'),'all');
if  BW4(z)>10000
    BW4(z)=BW4(z);   
else
    BW4(z)=691200;
end
end
end

%% function-coordinate
function [xmat,ymat] = coordinate(canny_img,centroids)

% x coordinate 
[row,col]=size(canny_img);
xmat=[];
for k=1:row
    for h=1:col
    if h<centroids(:,1)
       xmat(k,h)=h-fix(centroids(:,1));
    elseif h>centroids(:,1)
        xmat(k,h)=h-fix(centroids(:,1));
    else
        xmat(k,h)=0;
    end
    end
end

% y coordinate
ymat=[];
for m=1:row
    for n=1:col
    if m<centroids(:,2)
       ymat(m,n)=m-fix(centroids(:,2));
    elseif m>centroids(:,2)
        ymat(m,n)=m-fix(centroids(:,2));
    else
        ymat(m,n)=0;
    end
    end
end

xmat=xmat.*canny_img;
ymat=-ymat.*canny_img;
end

%% function-vertex
function [distance_real_x,distance_real_y] = vertex(xmat,ymat,pixel_length)

first_result=xmat+ymat;
[first_y,first_x]=find(first_result==max(max(first_result)));
final_first_x=mean(first_x);
final_first_y=mean(first_y);

second_result=-xmat+ymat;
[second_y,second_x]=find(second_result==max(max(second_result)));
final_second_x=mean(second_x);
final_second_y=mean(second_y);

third_result=-xmat-ymat;
[third_y,third_x]=find(third_result==max(max(third_result)));
final_third_x=mean(third_x);
final_third_y=mean(third_y);

fourth_result=xmat-ymat;
[fourth_y,fourth_x]=find(fourth_result==max(max(fourth_result)));
final_fourth_x=mean(fourth_x);
final_fourth_y=mean(fourth_y);

center_ft=[(final_first_x+final_third_x)/2,(final_first_y+final_third_y)/2];
center_sf=[(final_second_x+final_fourth_x)/2,(final_second_y+final_fourth_y)/2];

center=(center_sf+center_ft)/2;

distance_x_pixel = center(:,1)-480;
distance_y_pixel = center(:,2)-360;

distance_real_x = -(distance_x_pixel)*(pixel_length)/100;
distance_real_y = (distance_y_pixel)*(pixel_length)/100;

end

%% function-distance_and_compensate
function [distance,y_error] = distance_and_compensate(BW4,level)

pixel_for_distance = min(BW4);

% distance_dimension [m]
if level==1
    distance = max(roots([2.41476873328480e-06 -2.95206178231860e-07 (2.48545546188223e-07)-(1/pixel_for_distance)]))-0.15;
    distance_for_y = max(roots([2.41476873328480e-06 -2.95206178231860e-07 (2.48545546188223e-07)-(1/pixel_for_distance)]))-0.1;
elseif level==2
    distance = max(roots([4.81282626426305e-06 -5.88369407133181e-07 (4.95371053994430e-07)-(1/pixel_for_distance)]))-0.12;
    distance_for_y = max(roots([4.81282626426305e-06 -5.88369407133181e-07 (4.95371053994430e-07)-(1/pixel_for_distance)]))+0.05;
elseif level==3
    distance = max(roots([5.87658118932178e-06 -7.18413755344577e-07 (6.04860441203445e-07)-(1/pixel_for_distance)]))-0.1;
    distance_for_y = max(roots([4.81282626426305e-06 -5.88369407133181e-07 (4.95371053994430e-07)-(1/pixel_for_distance)]));
end

% camera_compensate
theta = atan(31.5/155);
y_error = tan(theta)*distance_for_y;
end
