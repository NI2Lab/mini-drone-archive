안녕하세요. 
A리그 드렌즈 팀입니다.

저희 팀의 대회 진행 전략은 우선 1차 링의 경우 직선주행으로 통과할 수 있기 때문에 드론을 이륙 시킨 후 호버링을 제어하기 위해 pause 함수를 이용합니다.
그 다음 링을 통과할 수 있도록 고도를 높혀 다시 호버링을 제어하고 2m의 직선 코스 후 1m뒤에 빨간색 원이 있으므로 약 2.6m를 이동하여 빨간색 원을 찾습니다.
빨간색 원을 찾으면 드론이 왼쪽으로 90도 회전하여 다시 주행합니다. 

두 번째 링의 경우 첫 번째 링에서 높이만 바뀌기 때문에 위의 과정을 통해 약간의 오차가 있을 수 있지만 링을 통과할 수 있는 위치에 드론을 이동시킬 수 있습니다.
드론을 약 2m 앞으로 이동시켜 두번째 링과 가까운 위치로 이동시킵니다.

상자를 추가하였을지 제거하였을지 모르기 때문에 우선 드론을 높게 띄운 다음 녹색을 확인하며 조금씩 하강하도록 하였습니다.
드론이 녹색을 감지하면 링의 두께를 고려하여 하강하도록 하였습니다.
하강한 후 링을 통과하기 위해 앞으로 이동하여 다시 빨간색 원을 찾고 위와 같이 왼쪽으로 90도 회전시켜 주행을 진행합니다.

세 번째 링을 찾기 위해서 readHeight 함수를 이용해 2번째 링의 고도를 찾아냈습니다. 
2번째 링과 3번째 링의 높이는 서로 반대이므로, 링이 위에 있는지 아래에 있는지 파악해서 범위를 좁혔습니다.
드론을 왼쪽 끝으로 1.7m를 이동해서 오른쪽으로 0.2m씩 이동하면서 초록색을 찾고 다시 0.5m 더 옆으로 이동후 직진해 링을 통과해 파란색 표식을 찾았습니다.

알고리즘 입니다.

이륙 → 고도 상승 → 앞으로 이동 → 빨간색 감지 → 왼쪽으로 90도 회전 → 앞으로 이동 → 고도 상승 → 하강하며 녹색 감지(녹색을 감지할 때의 고도 기억) → 고도 하강 → 앞으로 이동 →
왼쪽으로 90도 회전 → 앞으로 이동 → 왼쪽으로 이동 → 기억된 고도보다 높은지 낮은지 판별 → 높은 경우 고도 하강/ 낮은 경우 고도 상승 → 오른쪽으로 이동하며 녹색 감지 →
오른쪽으로 이동 → 앞으로 이동 → 파란색 감지 → 착륙


다음은 소스코드 입니다.

try
        drone = ryze();
    cam = camera(drone);
    
    % (1) takeoff
    takeoff(drone);
    pause(2);

    %위로 이동
    moveup(drone, 'distance', 0.3);
    pause(2);

    moveforward(drone, 'distance', 2.6);
    pause(2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%% 1첫번째 링
        
    while 1
        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_red = (h>1)+(h<0.05);

        if sum(detect_red, 'all') >= 17000
            % red color detected
            break
        end
    end

   turn(drone, deg2rad(-90));
   pause(2);

   moveforward(drone, 'distance', 2);
   pause(2);
   
   moveup(drone, 'distance', 0.85);
   pause(2);
   
  %%%%%%%%%%%%%%%%%%%%%%%%%% 링 22222222
    while 1
        movedown(drone, 'distance', 0.2);
        pause(2);

        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_green = (0.275<h)&(h<0.4);

        if sum(detect_green, 'all') >= 14000
            % green color detected
            break
        end
    end
    
    [height,~] = readHeight(drone);
    
    movedown(drone, 'distance', 0.45);
    pause(2);
    
    moveforward(drone, 'distance', 0.7);
    pause(2);
    
    while 1
        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_red = (h>1)+(h<0.05);

        if sum(detect_red, 'all') >= 17000
            % red color detected
            break
        end
    end
    
   turn(drone, deg2rad(-90));
   pause(2);
   
    moveforward(drone, 'distance', 2);
    pause(2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3번째 링

 moveleft(drone, 'distance', 1.65);
 pause(2);     

 if height > 1.3
    movedown(drone, 'distance', 0.7);
    pause(2);
    
 elseif height < 1.3
    moveup(drone, 'distance', 0.7);
    pause(2);
    
 end
  
     while 1
        moveright(drone, 'Distance', 0.2);
        pause(2);

        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_green = (0.275<h)&(h<0.4);

        if sum(detect_green, 'all') >= 14000
            % green color detected
            break
        end
    end
     
     moveright(drone, 'distance', 0.5);
     pause(2);
  
     moveforward(drone, 'distance', 0.75);
     pause(2);
     
    while 1
  
        frame = snapshot(cam);
        pause(2);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        detect_blue = (0.575<h)&(h<0.625);

        if sum(detect_blue, 'all') >= 15000
            % blue color detected
            break
        end
    end
  
   land(drone);
 
   catch error
    disp(error);
    clear;
    
end
    
예상치 못한 에러가 발생한 경우에 에러를 출력하기 위해 try-catch문을 이용하였습니다.
우선 드론 및 카메라 객체를 선언하고 드론을 이륙시킵니다.

호버링 제어를 위해 약 3초간 드론을 유지시킵니다. 모든 이동 과정에서 또한 호버링 제어를 위해 pause 함수를 이용했습니다.
이후 드론의 고도를 높입니다. 고도를 높인 드론을 링을 통과하도록 주행시킵니다.
링을 통과했으면 while 문을 통해 빨간색 원을 인식합니다. 인식 후 while문을 break시키고 turn함수를 이용해 드론을 왼쪽으로 90도 회전시킵니다.
회전 시킨 드론을 다시 주행시킵니다. 

처음 직전 코스에서 3m를 모두 이동하면 드론이 빨간색 원과 충돌할 수 있어 약간의 거리를 두고 주행 하였습니다.
이후 드론을 녹색 링 앞까지 주행 시킵니다. 이때도 역시 충돌을 방지하기 위해 2m에서 약간 차이를 두었습니다.
링 앞쪽으로 이동한 드론의 고도를 높입니다. 상자가 한개 늘어나거나 줄어드는데 한개 늘어난 경우의 위쪽 녹색 테두리보다 드론의 고도를 더 높여줍니다.

다음 while문을 이용하여 드론이 녹색을 감지하도록 합니다. 드론이 0.2m씩 하강하며 녹색을 감지합니다.
녹색을 감지하면 고도를 링의 위치를 고려하여 고도를 낮춥니다.
고도를 낮춘 드론이 링을 통과하도록 주행시키고 위의 빨간색 원을 찾는 과정을 반복하여 왼쪽으로 90도 회전시킨 후 다시 주행합니다.

3번째 링을 통과하기 위해서 readHeight 함수를 이용하였습니다.
드론의 고도를 측정하여서, 1.3m 보다 높으면 드론 높이를 0.7m 만큼 낮추고, 1.3m 보다 높으면 0.7m 만큼 높여서 초록색 링이 있는 고도의 위치를 맞추었습니다.

실제 주행 연습에서 오차를 줄이고 어느 지점에서 드론이 녹색, 빨간색, 파란색을 인식하는지 확인하기 위해 preview를 이용하였습니다.

감사합니다.

