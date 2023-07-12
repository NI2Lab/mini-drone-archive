%DoRed 표식이 빨간색이었을 경우 통과 동작
%2m 이동 후 90도 우회전
%드론 객체 이름 dr

moveforward(dr,'Distance', 2,'WaitUntilDone', true); 
pause(2);

turn(dr, deg2rad(90));
pause(2);
