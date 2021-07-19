%% 드론 카메라에서 실시간 영상 받아오기 : preview()
% droneObj=ryze();
% drone_cam=camera(droneObj);
% preview(drone_cam);
% takeoff(droneObj);
% pause(3);
% moveup(droneObj, 2);
% pause(3);
% land(droneObj);
% closePreview(drone_cam);

%% 드론 카메라에서 이미지 프레임 받아오기 : snapshot()
% droneObj=ryze();
% drone_cam=camera(droneObj);
% takeoff(droneObj);
% pause(3);
% [frame, ts]=snapshot(drone_cam);
% for i=1:2
%     pause(1);
%     disp(ts);
%     imshow(frame);
%     pause(1);
%     turn(droneObj, deg2rad(90));
%     pause(3);
%     [frame, ts]=snapshot(drone_cam);
% end
% pause(1);
% disp(ts);
% imshow(frame);
% pause(1);
% land(droneObj);