function findandmove_yellow(mytello, camera_fwd)
    cnt = 1;
    turn_ang = 45;
    while 1
        [frame,ts] = snapshot(camera_fwd);
        [h, w, ~] = size(frame);
        r  = frame( :, :, 1);
        g  = frame( :, :, 2);
        b  = frame( :, :, 3);

        % 파란색 배경 확인 
        justblue = b - r/2 - g/2;
        threshold_blue = justblue > 40;
        [y, x] = find(threshold_blue);
        if ~isempty(x) && ~isempty(y)
            % 내부 원 확인
             stats = regionprops(~threshold_blue, "all");
             cx = []; cy = []; 
             for i = 1: length(stats)
                 if (stats(i).Area >400) && (stats(i).Circularity>0.7)
                     cx  =  stats(i).Centroid(1);
                     cy  =  stats(i).Centroid(2);
                     area  =  stats(i).Area;
                 end
             end
            if ~isempty(cx) && ~isempty(cy)
                % 드론과 원의 중심 확인 후 전진 및 90도 회전
                if ((cx-20 < (w/2))&&((w/2) < cx+20)) && ((cy-20 < (h/2) )&&((h/2) < cy+20))
                    moveforward(mytello, 'Distance', 0.2, 'Speed', 0.5);
                    
                elseif area > 300000
                    break
    
                % 드론과 원의 중심이 다른 경우
                else
                    move_based_error((w/2), (h/2), cx, cy, mytello);
                end
            
          % 원이 검출되지 않는 경우 
          else
               turn_ang = turn_ang -(2*cnt)*(-1)^cnt;
                cnt =   cnt +1;
                turn(mytello, deg2rad(turn_ang));
           end
          
        % 파란색 배경이 없는 경우    
        else
            turn_ang = turn_ang -(2*cnt)*(-1)^cnt;
            cnt =   cnt +1;
            turn(mytello, deg2rad(turn_ang));
        end

    end

end