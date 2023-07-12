%main
dr = ryze();
cam = camera(dr);

%initialize
finish = 0;
state = 'd'; %default

%operate
takeoff(dr);
pause(2);

while ~finish
    img = snapshot(cam);
    [haveCircle, center] = getCircle(img);
    big = size(img(:,:,1));
    mid = [big(2)/2 big(1)/2];

    if haveCircle
        getCenter = AimStraight(center, mid); %화면의 중심에 맞춤
        
        if getCenter
            [color, place] = findrgv(img);
            
            switch color
                case 1
                    DoRed;
                case 2
                    DoGreen;
                    state = 'f'; %final
                case 3
                    finish = DoViolet(center, place);
                case 4 %nothing found

            end
        
        end
        
    else %cant find circle
        if state == 'f'
            turn(dr, deg2rad(15));
        else
            % 파란색 찾고 움직이기
            good = whereisCircle(img);
            if good == 0
                DoRed;
            end
        end

    end
end