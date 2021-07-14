function hole_search
    diff=20;
    y_lim=0; z_lim=0;
    cx_r=0; cy_r=0; cx_h=0; cy_h=0;
    flag=0; step=1; search=1;
    droneObj=ryze()
    cameraObj=camera(droneObj)
    pause(0.1);
    takeoff(droneObj);
    pause(0.1);
    moveup(droneObj,'Distance', 0.5);
%%
    t=0;    
    while t<2000
        switch step
            case 1
                frame=snapshot(cameraObj);
                hsv_img=rgb2hsv(frame);

                h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);
                mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1); % 특정 hsv 범위 내의 픽셀만 1로 만듦
                
                hole=imcomplement(mask);
                se=strel('disk',10);
                hole=imclose(hole,se);

                rect=((0.95<h)|(h<0.05))&(0.4<s)&(s<=1);

                stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.7);
                stats_h(A,:) = [];

                stats_r=regionprops('table', rect, 'Area', 'Centroid');
                stats_r.Area
                
                if size(stats_h, 1)>0 && flag==0
                    [~,Ih]=max(stats_h.Circularity);
                    cx_h=round(stats_h.Centroid(Ih,1));
                    cy_h=round(stats_h.Centroid(Ih,2));
                else
                    if flag==0
                        switch search
                            case 1
                                move(droneObj,[0 0.3 -0.3]);
                                pause(0.2); search=2;
                                continue;
                            case 2
                                move(droneObj,[0 0 0.6]);
                                pause(0.2); search=3;
                                continue;
                            case 3
                                move(droneObj,[0 -0.6 -0.6]);
                                pause(0.2); search=4;
                                continue;
                            case 4
                                move(droneObj,[0 0 0.6]);
                                pause(0.2); search=1;
                                continue;
                        end
                    end
                end

                
                if size(stats_r, 1)>0
                    [~,Ir]=max(stats_r.Area);
                    cx_r=round(stats_r.Centroid(Ir,1));
                    cy_r=round(stats_r.Centroid(Ir,2));
                    
                    if 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                        flag=1;
                    elseif stats_r.Area(Ir)>=3000
                        turn(droneObj, deg2rad(-90));
                        pause(0.1);
                        moveforward(droneObj,'Distance', 1, 'speed', 1);
                        step=step+1;
                        flag=0;
                        continue;
                    end
                else
                    switch search
                        case 1
                            move(droneObj,[0 0.3 -0.3]);
                            pause(0.2); search=2;
                            continue;
                        case 2
                            move(droneObj,[0 0 0.6]);
                            pause(0.2); search=3;
                            continue;
                        case 3
                            move(droneObj,[0 -0.6 -0.6]);
                            pause(0.2); search=4;
                            continue;
                        case 4
                            move(droneObj,[0 0 0.6]);
                            pause(0.2); search=1;
                            continue;
                    end
                end
                
                search=1;
                
                if size(stats_h, 1)>0 && flag==0
                    cx=cx_h; cy=cy_h;
                    y_lim=480; z_lim=270;
                    disp("hole");
                    
                elseif size(stats_r, 1)>0 && flag==1
                    cx=cx_r; cy=cy_r;
                    y_lim=460; z_lim=250;
                    stats_r.Area(Ir)
                    disp("rect");
                else
                    cx=-1; cy=-1;
                end
                
                if cx>=0 && cy>=0
                    dx=0; dy=cx-y_lim; dz=cy-z_lim;
                    
                    if dy>diff && dz>diff
                        dy=0.1; dz=0.2;
                    elseif dy>diff && dz<-diff
                        dy=0.1; dz=-0.2;
                    elseif dy<-diff && dz>diff
                        dy=-0.1; dz=0.2;
                    elseif dy<-diff && dz<-diff
                        dy=-0.1; dz=-0.2;
                    else
                        dx=0.3; dy=0; dz=0.1;
                    end
                    move(droneObj,[dx dy dz]);
                    pause(0.2);
                end

                subplot(2,2,1); imshow(frame);                
                subplot(2,2,2); imshow(hole);                
                hold on                
                if size(stats_h, 1)>0
                    plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                end
                hold off

                subplot(2,2,3);imshow(rect);
                hold on
                if size(stats_r, 1)>0
                    plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                end
                hold off
                
                t=t+1;
          
            case 2
                frame=snapshot(cameraObj);
                hsv_img=rgb2hsv(frame);

                h=hsv_img(:,:,1); s=hsv_img(:,:,2);v=hsv_img(:,:,3);
                mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);                
                hole=imcomplement(mask);
                se=strel('disk',10);
                hole=imclose(hole,se);

                rect=((0.95<h)|(h<0.05))&(0.4<s)&(s<=1);

                stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.7);
                stats_h(A,:) = [];

                stats_r=regionprops('table', rect, 'Area', 'Centroid');
                
                if size(stats_h, 1)>0 && flag==0
                    [~,Ih]=max(stats_h.Circularity);
                    cx_h=round(stats_h.Centroid(Ih,1));
                    cy_h=round(stats_h.Centroid(Ih,2));
                else
                    if flag==0
                        switch search
                            case 1
                                move(droneObj,[0 0.3 -0.3]);
                                pause(0.2);
                                search=2;
                                continue;
                            case 2
                                move(droneObj,[0 0 0.6]);
                                pause(0.2);
                                search=3;
                                continue;
                            case 3
                                move(droneObj,[0 -0.6 -0.6]);
                                pause(0.2);
                                search=4;
                                continue;
                            case 4
                                move(droneObj,[0 0 0.6]);
                                pause(0.2);
                                search=1;
                                continue;
                        end
                    end
                end

                
                if size(stats_r, 1)>0
                    [~,Ir]=max(stats_r.Area);
                    cx_r=round(stats_r.Centroid(Ir,1));
                    cy_r=round(stats_r.Centroid(Ir,2));
                    
                    if 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                        flag=1;
                    elseif stats_r.Area(Ir)>=3000
                        turn(droneObj, deg2rad(-90));
                        pause(0.1);
                        moveforward(droneObj,'Distance', 1, 'speed', 1);
                        step=step+1;
                        flag=0;
                        continue;
                    end
                else
                    switch search
                        case 1
                            move(droneObj,[0 0.3 -0.3]);
                            pause(0.2);
                            search=2;
                            continue;
                        case 2
                            move(droneObj,[0 0 0.6]);
                            pause(0.2);
                            search=3;
                            continue;
                        case 3
                            move(droneObj,[0 -0.6 -0.6]);
                            pause(0.2);
                            search=4;
                            continue;
                        case 4
                            move(droneObj,[0 0 0.6]);
                            pause(0.2);
                            search=1;
                            continue;
                    end
                end
                
                search=1;
                
                if size(stats_h, 1)>0 && flag==0
                    cx=cx_h; cy=cy_h;
                    y_lim=480; z_lim=270;
                    disp("hole");
                elseif size(stats_r, 1)>0 && flag==1
                    cx=cx_r; cy=cy_r;
                    y_lim=460; z_lim=250;
                    stats_r.Area(Ir)
                    disp("rect");
                else
                    cx=-1;
                    cy=-1;
                end


                if cx>=0 && cy>=0
                    dx=0; dy=cx-y_lim; dz=cy-z_lim;
                    if dy>diff && dz>diff
                        dy=0.1; dz=0.2;
                    elseif dy>diff && dz<-diff
                        dy=0.1; dz=-0.2;
                    elseif dy<-diff && dz>diff
                        dy=-0.1; dz=0.2;
                    elseif dy<-diff && dz<-diff
                        dy=-0.1; dz=-0.2;
                    else
                        dx=0.3; dy=0; dz=0.1;
                    end                
                    move(droneObj,[dx dy dz]);
                    pause(0.2);
                end
                subplot(2,2,1); imshow(frame); 
                subplot(2,2,2);imshow(hole);
                hold on
                if size(stats_h, 1)>0
                    plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                end
                hold off

                subplot(2,2,3);imshow(rect)
                hold on
                if size(stats_r, 1)>0
                    plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                end
                hold off

                t=t+1;                
            case 3
                frame=snapshot(cameraObj);
                hsv_img=rgb2hsv(frame);

                h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3); 
                mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
                hole=imcomplement(mask);
                se=strel('disk',10);
                hole=imclose(hole,se);
                
                rect=(0.7<h)&(h<0.8)&(0.2<s)&(s<=0.8);

                stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                A=find([stats_h.Area] <= 1000 | [stats_h.Circularity] < 0.7);
                stats_h(A,:) = [];

                stats_r=regionprops('table', rect, 'Area', 'Centroid');
                if size(stats_h, 1)>0 && flag==0
                    [~,Ih]=max(stats_h.Circularity);
                    cx_h=round(stats_h.Centroid(Ih,1));
                    cy_h=round(stats_h.Centroid(Ih,2));
                else
                    if flag==0
                        switch search
                            case 1
                                move(droneObj,[0 0.3 -0.3]);
                                pause(0.2); search=2;
                                continue;
                            case 2
                                move(droneObj,[0 0 0.6]);
                                pause(0.2); search=3;
                                continue;
                            case 3
                                move(droneObj,[0 -0.6 -0.6]);
                                pause(0.2); search=4;
                                continue;
                            case 4
                                move(droneObj,[0 0 0.6]);
                                pause(0.2); search=1;
                                continue;
                        end
                    end
                end

                
                if size(stats_r, 1)>0
                    [~,Ir]=max(stats_r.Area);
                    cx_r=round(stats_r.Centroid(Ir,1));
                    cy_r=round(stats_r.Centroid(Ir,2));
                    
                    if 300<stats_r.Area(Ir) && stats_r.Area(Ir)<3000
                        flag=1;
                    elseif stats_r.Area(Ir)>=3000
                        turn(droneObj, deg2rad(-90));
                        pause(0.1);
                        moveforward(droneObj,'Distance', 1, 'speed', 1);
                        step=step+1;
                        flag=0;
                        continue;
                    end
                else
                    switch search
                        case 1
                            move(droneObj,[0 0.3 -0.3]);
                            pause(0.2); search=2;
                            continue;
                        case 2
                            move(droneObj,[0 0 0.6]);
                            pause(0.2); search=3;
                            continue;
                        case 3
                            move(droneObj,[0 -0.6 -0.6]);
                            pause(0.2); search=4;
                            continue;
                        case 4
                            move(droneObj,[0 0 0.6]);
                            pause(0.2); search=1;
                            continue;
                    end
                end
                
                search=1;
                
                if size(stats_h, 1)>0 && flag==0
                    cx=cx_h; cy=cy_h;
                    y_lim=480; z_lim=270;
                    disp("hole");
                elseif size(stats_r, 1)>0 && flag==1
                    cx=cx_r; cy=cy_r;
                    y_lim=460; z_lim=250;
                    stats_r.Area(Ir)
                    disp("rect");
                else
                    cx=-1; cy=-1;
                end


                if cx>=0 && cy>=0
                    dx=0; dy=cx-y_lim; dz=cy-z_lim;
                    if dy>diff && dz>diff
                        dy=0.1; dz=0.2;
                    elseif dy>diff && dz<-diff
                        dy=0.1; dz=-0.2;
                    elseif dy<-diff && dz>diff
                        dy=-0.1; dz=0.2;
                    elseif dy<-diff && dz<-diff
                        dy=-0.1; dz=-0.2;
                    else
                        dx=0.3; dy=0; dz=0.1;
                    end
                    move(droneObj,[dx dy dz]);
                    pause(0.2);
                end

                subplot(2,2,1); imshow(frame);
                subplot(2,2,2); imshow(hole);
                hold on
                if size(stats_h, 1)>0
                    plot(cx_h, cy_h, 'g+', 'LineWidth', 2);
                end
                hold off

                subplot(2,2,3); imshow(rect);
                hold on
                if size(stats_r, 1)>0
                    plot(cx_r, cy_r, 'g+', 'LineWidth', 2);
                end
                hold off

                t=t+1;
        end  
    end
    land(droneObj);
end