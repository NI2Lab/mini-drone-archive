%% 단순 이륙 & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% land(droneObj); % 착륙

%% 이동 지속시간 이용한 방향 제어
% 좌우 이동 - 이륙 & 오른쪽으로 이동(3초) & 왼쪽으로 이동(3초) & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% moveright(droneObj,3); % 오른쪽으로 이동
% pause(3); % 3초 대기
% moveleft(droneObj,3); % 왼쪽으로 이동
% pause(3); % 3초 대기
% land(droneObj); % 착륙

% 상하 이동 - 이륙 & 위로 이동(3초) & 아래로 이동(3초) & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% moveup(droneObj,3); % 위로 이동
% pause(3); % 3초 대기
% movedown(droneObj,3); % 아래로 이동
% pause(3); % 3초 대기
% land(droneObj); % 착륙

% 앞뒤 이동 - 이륙 & 앞으로 이동(3초) & 뒤로 이동(3초) & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% moveforward(droneObj,3); % 앞으로 이동
% pause(3); % 3초 대기
% moveback(droneObj,3); % 뒤로 이동
% pause(3); % 3초 대기
% land(droneObj); % 착륙

%% 이동 거리 값을 이용한 방향 제어
% 좌우 이동 - 이륙 & 오른쪽으로 이동(0.5m) & 왼쪽으로 이동(0.5m) & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% moveright(droneObj,'Distance', 0.5); % 오른쪽으로 이동
% pause(3); % 3초 대기
% moveleft(droneObj,'Distance', 0.5); % 왼쪽으로 이동
% pause(3); % 3초 대기
% land(droneObj); % 착륙

% 상하 이동 - 이륙 & 위로 이동(0.5m) & 아래로 이동(0.5m) & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% moveup(droneObj,'Distance', 0.5); % 위로 이동
% pause(3); % 3초 대기
% movedown(droneObj,'Distance', 0.5); % 아래로 이동
% pause(3); % 3초 대기
% land(droneObj); % 착륙

% 앞뒤 이동 - 이륙 & 앞으로 이동(0.5m) & 뒤로 이동(0.5m) & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% moveforward(droneObj,'Distance', 0.5); % 앞으로 이동
% pause(3); % 3초 대기
% moveback(droneObj,'Distance', 0.5); % 뒤로 이동
% pause(3); % 3초 대기
% land(droneObj); % 착륙

%% 회전 및 방향 제어
% 이륙 & 오른쪽으로 45도 회전 & 앞으로 이동(0.5m) & 왼쪽으로 45도 회전 & 앞으로 이동(0.5m) & 착륙
% droneObj=ryze(); % 드론 객체 선언
% takeoff(droneObj); % 이륙
% pause(3); % 3초 대기
% turn(droneObj, deg2rad(45)); % 오른쪽으로 45도 회전
% pause(3); % 3초 대기
% moveforward(droneObj,'Distance', 0.5); % 앞으로 이동
% pause(3); % 3초 대기
% turn(droneObj, deg2rad(-45)); % 왼쪽으로 45도 회전
% pause(3); % 3초 대기
% moveforward(droneObj,'Distance', 0.5); % 앞으로 이동
% pause(3); % 3초 대기
% land(droneObj); % 착륙