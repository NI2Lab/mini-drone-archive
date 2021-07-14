clear()
% HSV Threshold Blue
thdown_blue = [0.5, 0.25, 0.25];
thup_blue = [0.75, 1, 1];

% HSV Threshold Red
thdown_red1 = [0, 0.25, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.25, 0.25];
thup_red2 = [1, 1, 1];

% HSV Threshold Purple
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

droneObj = ryze();
cameraObj = camera(droneObj);
takeoff(droneObj);
moveup(droneObj, 'distance', 0.5);


while 1
    disp('Error Check Point 1');
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:, :, 1);
    src_s = src_hsv(:, :, 2);
    src_v = src_hsv(:, :, 3);

    disp('Error Check Point 2');
    % Image Preprocessing
%     bw_red = (thdown_red1(1) < src_h & src_h < thup_red1(1)) ...        % 빨간색1범위 검출
%            + (thdown_red2(1) < src_h & src_h < thup_red2(1));           % 빨간색2범위 검출
%     bw_purple = (thdown_purple(1) < src_h) & (src_h < thup_purple(1));      % 보라색범위 검출
    bw_red = (thdown_red1(1) < src_h)&(src_h < thup_red1(1)) & (thdown_red1(2) < src_s)&(src_s < thup_red1(2)) & (thdown_red1(3) < src_v)&(src_v < thup_red1(3)) ...
            | (thdown_red2(1) < src_h)&(src_h < thup_red2(1)) & (thdown_red2(2) < src_s)&(src_s < thup_red2(2)) & (thdown_red2(3) < src_v)&(src_v < thup_red2(3)); 
    bw_purple = (thdown_purple(1) < src_h)&(src_h < thup_purple(1)) & (thdown_purple(2) < src_s)&(src_s < thup_purple(2)) & (thdown_purple(3) < src_v)&(src_v < thup_purple(3));

    disp('Error Check Point 3');
    subplot(2, 2, 1), imshow(frame);
    subplot(2, 2, 2), imshow(frame);
    subplot(2, 2, 3), imshow(bw_red);
    subplot(2, 2, 4), imshow(bw_purple);

    disp('Error Check Point 4');
    % 빨간색 혹은 보라색 검출할 때까지 전진
    if (sum(bw_red, 'all') > 4000)                          % 빨간색이 검출되면
        disp('RED Color Detected!!! Drone Turn Left');
        turn(droneObj, deg2rad(-90));                       % Turn Left, 다음동작 크로마키 검출, 지난 링을 건드리지 않도록 일정거리 전진
        moveforward(droneObj, 'distance', 1.25);            % 맵에 따라서(크로마키의 앞뒤 위치에 따라서) 없애야 할 수도 있음
        break;
    elseif(sum(bw_purple, 'all') > 4000)                    % 보라색이 검출되면
        disp('Purple Color Detected!!! Drone Landing');
        land(droneObj);                                     % Landing
        return;                                             % 프로그램 종료
    end
end
