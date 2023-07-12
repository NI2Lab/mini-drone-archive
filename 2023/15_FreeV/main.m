clear; close all; clc;

mytello = ryze()
camera_fwd = camera(mytello,'FPV');

% Take off
takeoff(mytello);
pause(3);

% Find red target and move
find_red_target(mytello, camera_fwd)

% Find red target and move
find_red_target(mytello, camera_fwd)

% Find green target and move
find_green_target(mytello, camera_fwd)

% Find purple target
findandmove_yellow(mytello, camera_fwd)

% Landing
land(mytello);
