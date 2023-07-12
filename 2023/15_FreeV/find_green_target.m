function find_green_target(mytello, camera_fwd)
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
                 end
             end
            if ~isempty(cx) && ~isempty(cy)
                % 드론과 원의 중심 확인 후 전진 및 전45도 회전
                if ((cx-20 < (w/2))&&((w/2) < cx+20)) && ((cy-20 < (h/2) )&&((h/2) < cy+20))
                    moveforward(mytello, 'Distance', 1.5, 'Speed', 0.5);
                    pause(3);
                    turn(mytello, deg2rad(45));
                    pause(3);
                    moveforward(mytello, 'Distance', 0.2, 'Speed', 0.5);
                    break
    
                % 드론과 원의 중심이 다른 경우
                else
                    move_based_error((w/2), (h/2), cx, cy, mytello);
                end
            
          % 원이 검출되지 않는 경우 
          else
               moveback(mytello, 'Distance', 0.2, 'Speed', 0.2);
           end
          
        % 파란색 배경이 없는 경우    
        else
            moveback(mytello, 'Distance', 0.2, 'Speed', 0.2);
        end

    end

end