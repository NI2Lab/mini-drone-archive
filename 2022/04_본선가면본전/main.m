droneObj = ryze()
cameraOBj = camera(droneObj); 
preview(cameraOBj);
takeoff(droneObj);
%moveup(droneObj, 1.5); %이건 내가 따로 한건데 가운데에 위치하고 이거 쓰면 사진찍힐때 이쁘게 나옴

%%%%%%%%%%%%%%% 여기까지 움직인지 확인하는것 %%%%%%%%%%%%%%%%

while 1  
   
 frame = snapshot(cameraOBj); % 사진찍기
 imwrite(frame, 'dd.png');

img_rgb = imread('dd.png');

img_hsv = rgb2hsv(img_rgb);

h = img_hsv(:,:,1); % Hue 채널

s = img_hsv(:,:,2); % Saturation 채널

v = img_hsv(:,:,3); % Value 채널

p = double(zeros(size(h))); % h 행렬의 크기를 가지는 성분값이 0인 행렬 p 생성

for i = 1: size(p, 1) % p 행렬의 행만큼 for문 실행

    for j = 1:size(p, 2) % p 행렬의 열만큼 for문 실행

        if (h(i, j) > 0.22 ) && (v(i, j) < 0.97) && (s(i,j) > 0.51) % h, s, v의 해당범위에 들어보면 p 행렬을 1로 변경
             p(i, j) = 1;
        else % 범위에 들어오지 않은 경우 p 행렬에 0로 변경
            p(i,j)=0;
        end
    end
end
a=[size(p,2)./2, size(p,1)./2-150]; %

BW=imbinarize(p);
BW=bwareafilt(BW,1,'largest'); % 넓이가 가장 큰 객체만 남겨주는 함수
BW=bwmorph(BW,'close'); 
s = regionprops(BW,'centroid'); % BW 이진화그림의 객체의 중심을 찾아주는 함수
center = cat(1,s.Centroid); 

subimage(BW)

hold on
plot(center(:,1),center(:,2),'r*') % 객체의 중점을 plot해주는 함수
plot(a(:,1),a(:,2),'b*') % 드론의 위치를 plot해주는 함수
hold off

w_y=center(1,1); % 객체의 중점의 x축 저장
w_z=center(1,2); % 객체의 중점의 y축 저장

d_y=a(1,1); % 드론의 중점의 x축 저장
d_z=a(1,2); % 드론의 중점의 y축 저장

dis_y=norm(d_y-w_y) % 드론의 중점과 객체의 중점사이의 거리 측정
dis_z=norm(d_z-w_z) % 드론의 중점과 객체의 중점사이의 거리 측정

n_y = (w_y-d_y)/dis_y; % 단위벡터 계산
n_z = (w_z-d_z)/dis_z; % 단위벡터 계산

if(dis_y<40 && dis_z<80) 
    break; % while탈출
else
    move(droneObj,[0 n_y*0.2 n_z*0.2],'Speed',0.5); 
end 

end

%% 직진
while 1  

frame2 = snapshot(cameraOBj); % 사진찍기
imwrite(frame2,'aft.png');

img_rgb = imread('aft.png');
 
img_hsv = rgb2hsv(img_rgb);

h = img_hsv(:,:,1); % Hue 채널

s = img_hsv(:,:,2); % Saturation 채널

v = img_hsv(:,:,3); % Value 채널

p = double(zeros(size(h))); % 행렬 h의 크기를 가지는 p 행렬 생성

for i = 1: size(p, 1)

    for j = 1:size(p, 2)

        if ((h(i, j) > 0.22) && (h(i, j) < 0.86) ) && (v(i, j) < 0.97) && (s(i,j) > 0.51) 

             p(i, j) = 1;
        else
            p(i,j)=0;
        end
    end
end

a=[size(p,2)./2, size(p,1)./2];

BW=imbinarize(p);
BW=bwareafilt(BW,1,'largest'); % 가장큰 객체만 남겨주는 함수
BW = bwareaopen(BW, 12000); % 픽셀크기가 10000이하면 제거. 즉, 파란색 천막이 없을때
total = bwarea(BW); % 객체 넓이를 구해주는 함수

if total ==0 % 객체가 없으면 if문 실행
move(droneObj,[0.6 0 0],'Speed',0.2);
break;
else
s = regionprops(BW,'centroid');
center = cat(1,s.Centroid)

subimage(BW)

hold on
plot(center(:,1),center(:,2),'r*')
plot(a(:,1),a(:,2),'b*')
hold off

w_y=center(1,1);
w_z=center(1,2);

d_y=a(1,1);
d_z=a(1,2);

move(droneObj,[0.5 0 0],'Speed',0.2);
end

end % while문의 end

%% rgb 인식 (red인식)
while 1  
   
frame3 = snapshot(cameraOBj); % 사진찍기
imwrite(frame3,'aft2.png');

a = imread('aft2.png');

hsv = imbinarize(a);

% x, y좌표 값 바꿔서 넣어줘야 함


for i=1:size(hsv,1)
    for j = 1:size(hsv,2)
    if hsv(i,j,1)==0&&hsv(i,j,2)==1&&hsv(i,j,3)==0 % 초록색이면 if문 실행 RED일때 = [0, 1, 0], GREEN일때 = [0,1,0]
        temp = i;
        temp2 = j; % 각 단계마다 if문 조건식 수정하면 됨
    else
        hsv(i,j,1)=0; % 초록색이 아닌 경우 hsv의 값을 0으로 변경
        hsv(i,j,2)=0;
        hsv(i,j,3)=0;
    end

    end
end

h = hsv(:,:,1); % Hue 채널

s = hsv(:,:,2); % Saturation 채널

v = hsv(:,:,3); % Value 채널

BW=edge(h);

[~,threshold] =edge(BW,'prewitt');
BW = boundarymask(BW);
BW=bwpropfilt(BW,'EulerNumber',[0 0]); % 구멍 있는 객체만 남겨주는 함수
BW=bwareafilt(BW,1,'largest'); % 가장 큰 객체만 남겨주는 함수

s = regionprops(BW,'centroid');
center = cat(1,s.Centroid);

subimage(hsv)

    if hsv(temp,temp2,1)==0&&hsv(temp,temp2,2)==1&&hsv(temp,temp2,3)==0  % 빨간색일때
    turn(droneObj,deg2rad(90));% 시계방향으로 90도 회전
    move(droneObj,[1 0 0],'Speed',0.5);
    break; % while탈출
    end
end
%% 2번째 중심찾기
while 1

 frame4 = snapshot(cameraOBj); % 사진찍기
 imwrite(frame4, 'dd2.png');

img_rgb = imread('dd2.png');

img_hsv = rgb2hsv(img_rgb);

h = img_hsv(:,:,1); % Hue 채널

s = img_hsv(:,:,2); % Saturation 채널

v = img_hsv(:,:,3); % Value 채널

p = double(zeros(size(h))); 

for i = 1: size(p, 1)

    for j = 1:size(p, 2)

        if (h(i, j) > 0.22 ) && (v(i, j) < 0.97) && (s(i,j) > 0.51) 
             p(i, j) = 1;
        else
            p(i,j)=0;
        end
    end
end
a=[size(p,2)./2, size(p,1)./2-150];

BW=imbinarize(p);
BW=bwareafilt(BW,1,'largest');
BW=bwmorph(BW,'close');
s = regionprops(BW,'centroid');
center = cat(1,s.Centroid);

subimage(BW)

hold on
plot(center(:,1),center(:,2),'r*')
plot(a(:,1),a(:,2),'b*')
hold off


w_y=center(1,1);
w_z=center(1,2);

d_y=a(1,1);
d_z=a(1,2);

dis_y=norm(d_y-w_y);
dis_z=norm(d_z-w_z);

n_y = (w_y-d_y)/dis_y;
n_z = (w_z-d_z)/dis_z;

if(dis_y<40 && dis_z<100) % 거리 300이라고 그냥 가정해둠 300 수정하면댐
    break; % while탈출
else
    move(droneObj,[0 n_y*0.2 n_z*0.2],'Speed',0.5); % 제일 중요한 드론 이동 기울기 이동이라서 4가지 경우의 수 안따져도댐
end 

end

%% 직진
while 1  

frame5 = snapshot(cameraOBj); % 사진찍기
imwrite(frame5,'aft3.png');

img_rgb = imread('aft3.png');
 
img_hsv = rgb2hsv(img_rgb);

h = img_hsv(:,:,1); % Hue 채널

s = img_hsv(:,:,2); % Saturation 채널

v = img_hsv(:,:,3); % Value 채널

p = double(zeros(size(h))); 

for i = 1: size(p, 1)

    for j = 1:size(p, 2)

        if ((h(i, j) > 0.22) && (h(i, j) < 0.86) ) && (v(i, j) < 0.97) && (s(i,j) > 0.51) 

             p(i, j) = 1;
        else
            p(i,j)=0;
        end
    end
end

a=[size(p,2)./2, size(p,1)./2];

BW=imbinarize(p);
BW=bwareafilt(BW,1,'largest'); % 가장큰 객체만 남겨주는 함수
BW = bwareaopen(BW, 12000); % 픽셀크기가 10000이하면 제거. 즉, 파란색 천막이 없을때
total = bwarea(BW); % 객체 넓이를 구해주는 함수

if total ==0
move(droneObj,[0.6 0 0],'Speed',0.2);
break;
else
s = regionprops(BW,'centroid');
center = cat(1,s.Centroid)

subimage(BW);

hold on
plot(center(:,1),center(:,2),'r*')
plot(a(:,1),a(:,2),'b*')
hold off

w_y=center(1,1);
w_z=center(1,2);

d_y=a(1,1);
d_z=a(1,2);

move(droneObj,[0.5 0 0],'Speed',0.2);
end

end % while문의 end

%% rgb 인식
while 1  
   
frame6 = snapshot(cameraOBj); % 사진찍기
imwrite(frame6,'aft4.png');

a = imread('aft4.png');

hsv = imbinarize(a);

% x, y좌표 값 바꿔서 넣어줘야 함


for i=1:size(hsv,1)
    for j = 1:size(hsv,2)
    if hsv(i,j,1)==1&&hsv(i,j,2)==0&&hsv(i,j,3)==1 % 보라색일때 if문 실행 
        temp =  i;
        temp2 = j;
    else
        hsv(i,j,1)=0;
        hsv(i,j,2)=0;
        hsv(i,j,3)=0;
    end

    end
end

h = hsv(:,:,1); % Hue 채널

s = hsv(:,:,2); % Saturation 채널

v = hsv(:,:,3); % Value 채널

BW=edge(h);

[~,threshold] =edge(BW,'prewitt');
BW = boundarymask(BW);
BW=bwpropfilt(BW,'EulerNumber',[0 0]); % 구멍 있는 객체만 남겨주는 함수
BW=bwareafilt(BW,1,'largest'); % 가장 큰 객체만 남겨주는 함수

s = regionprops(BW,'centroid');
center = cat(1,s.Centroid);

subimage(hsv)

    if hsv(temp,temp2,1)==1&&hsv(temp,temp2,2)==0&&hsv(temp,temp2,3)==1  % 보라색일때
    turn(droneObj,deg2rad(90));% 시계방향으로 90도 회전
    move(droneObj,[1 0 0],'Speed',0.5);
    turn(droneObj,deg2rad(135)); % 시계방향으로 135도 회전
    break; % while탈출
    end
end %while문의 end
%% 3번째 중심찾기
while 1

 frame7 = snapshot(cameraOBj); % 사진찍기
 imwrite(frame7, 'dd3.png');
img_rgb = imread('dd3.png');

img_hsv = rgb2hsv(img_rgb);

h = img_hsv(:,:,1); % Hue 채널

s = img_hsv(:,:,2); % Saturation 채널

v = img_hsv(:,:,3); % Value 채널

p = double(zeros(size(h))); 

for i = 1: size(p, 1)

    for j = 1:size(p, 2)

        if (h(i, j) > 0.22 ) && (v(i, j) < 0.97) && (s(i,j) > 0.51) 
             p(i, j) = 1;
        else
            p(i,j)=0;
        end
    end
end
a=[size(p,2)./2, size(p,1)./2-150];

BW=imbinarize(p);
BW=bwareafilt(BW,1,'largest');
BW=bwmorph(BW,'close');
s = regionprops(BW,'centroid');
center = cat(1,s.Centroid);

subimage(BW)

hold on
plot(center(:,1),center(:,2),'r*')
plot(a(:,1),a(:,2),'b*')
hold off


w_y=center(1,1);
w_z=center(1,2);

d_y=a(1,1);
d_z=a(1,2);

dis_y=norm(d_y-w_y);
dis_z=norm(d_z-w_z);

n_y = (w_y-d_y)/dis_y;
n_z = (w_z-d_z)/dis_z;

if(dis_y<40 && dis_z<100) % 거리 300이라고 그냥 가정해둠 300 수정하면댐
    break; % while탈출
else
    move(droneObj,[0 n_y*0.2 n_z*0.2],'Speed',0.5); % 제일 중요한 드론 이동 기울기 이동이라서 4가지 경우의 수 안따져도댐
end 
end
%% 직진
%% rgb 인식 (보라색 인식) 1 0 1
while 1  
   
frame9 = snapshot(cameraOBj); % 사진찍기
imwrite(frame9,'aft6.png');

a = imread('aft6.png');

hsv = imbinarize(a);

% x, y좌표 값 바꿔서 넣어줘야 함


for i=1:size(hsv,1)
    for j = 1:size(hsv,2)
    if hsv(i,j,1)==1&&hsv(i,j,2)==0&&hsv(i,j,3)==0 % 빨간색이면 if문 실행 RED일때 = [1, 0, 0], GREEN일때 = [0,1,0]
           temp = i;
           temp2 = j;% 각 단계마다 if문 조건식 수정하면 됨
    else
        hsv(i,j,1)=0;
        hsv(i,j,2)=0;
        hsv(i,j,3)=0;
    end

    end
end

h = hsv(:,:,1); % Hue 채널

s = hsv(:,:,2); % Saturation 채널

v = hsv(:,:,3); % Value 채널

BW=edge(h);

[~,threshold] =edge(BW,'prewitt');
BW = boundarymask(BW);
BW=bwpropfilt(BW,'EulerNumber',[0 0]); % 구멍 있는 객체만 남겨주는 함수
BW=bwareafilt(BW,1,'largest'); % 가장 큰 객체만 남겨주는 함수

s = regionprops(BW,'centroid');
center = cat(1,s.Centroid);

subimage(hsv)

    if hsv(temp,temp2,1)==1&&hsv(temp,temp2,2)==0&&hsv(temp,temp2,3)==0  % 빨간색일때
    land(droneObj);  %드론 착륙
    break; % while탈출
    end
end %while문의 end