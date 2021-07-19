clear; clear All;

t = ryze();
c = camera(t);
takeoff(t)
pause(1)
moveforward(t,'Speed',1,'Distance', 1.3)
moveup(t,'Distance',0.2)

% 공통 변수
timer = 0;
function_switch = 0;

% ring_tracking 변수
ring_lost_count = 0;
side_lean = 0;

% dot_tracking 변수
dot_lost_count = 0;
process = 1;


while(function_switch <= 1)
    if function_switch == 0
        try
            [timer, function_switch, dot_lost_count, process] = dot_tracking(t,c, timer, function_switch, dot_lost_count, process);
        end
        
    elseif function_switch == 1
        try
            [timer, function_switch, side_lean, ring_lost_count] = ring_tracking(t, c, timer, function_switch, side_lean, ring_lost_count);
        end
    end
    pause(0.5)
end