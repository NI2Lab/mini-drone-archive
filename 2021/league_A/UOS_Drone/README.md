# 대회 진행 전략



# 알고리즘 설명

#### 1. 드론의 카메라에서 촬영되는 영상의 frame
----------
          드론의 전면 카메라에서 촬영한 영상에서 frame을 이미지로 가져옵니다.
<img src="https://user-images.githubusercontent.com/82210800/125578764-57107b42-a223-42cb-accd-a2f8b51734aa.PNG" width="960" height="720">
      
#### 2. frame을 hsv 색변환으로 이미지처리        
----------
          이미지 frame을 hsv_img로 변환
          hsv_img = rgb2hsv(frame)
<img src="https://user-images.githubusercontent.com/82210800/125579415-2c47d096-7c7e-4195-99e6-9ec31661f6d6.png" width="960" height="720">

#### 3. 원하는 색을 1, 나머지 색들은 0으로 처리(이진화)
--------
          3-1. hsv_img에서 추출해야하는 색 : 파란색
                    파란색 = 1 , 나머지 모든색 = 0
                    h=hsv_img(:,:,1); 
                    s=hsv_img(:,:,2); 
                    v=hsv_img(:,:,3);
                    이진화된 이미지 = mask = (0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
<img src="https://user-images.githubusercontent.com/82210800/125580245-66703a2e-487b-479b-add8-3d4b56c86b81.png" width="960" height="720">       

          3-2. 이진화된 이미지인 mask를 보정한 이미지 = res
                    mask=imcomplement(mask);
                    se=strel('disk',10);
                    res=imopen(mask,se);                    
<img src="https://user-images.githubusercontent.com/82210800/125580684-02ac2838-17cc-42df-9670-160365b91f11.png" width="960" height="720"> 

#### 4. res에서의 정보 가져오기 
----------
          5-1 Hole 찾기
          
                    hole = (0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1);
                    
                    stats_h=regionprops('table', hole, 'Area', 'Centroid', 'Circularity');
                    
          5-2 Hole의 원의 중심좌표 찾기
          
                    [~,Ih]=max(stats_h.Circularity);
                    
                    cx_h=round(stats_h.Centroid(Ih,1));
                    
                    cy_h=round(stats_h.Centroid(Ih,2));
                    
          5-3 mark 찾기
          
                    rect=((0.95<h)|(h<0.05))&(0.4<s)&(s<=1); //RED
                    
                    rect=(0.7<h)&(h<0.8)&(0.2<s)&(s<=0.8);   //Purple
                    
                    stats_r=regionprops('table', rect, 'Area', 'Centroid');
                    
          5-4 mark의 면적과 중심좌표 찾기
          
                    [~,Ir]=max(stats_r.Area);
                    
                    cx_r=round(stats_r.Centroid(Ir,1));
                    
                    cy_r=round(stats_r.Centroid(Ir,2));
         
#### 5. 드론의 자율주행을 위해 case를 3개로 나눔
----------
          case1 : 출발점 -->  1단계
                    
                    0. step = 1
          
                    1.mark(red rect)의 면적 = stats_r.Area
                    
                    2.300 < stats_r.Area < 3000 을 만족할 때는 flag = 1(6. flag에서 설명)
                    
                    3.stats_r.Area > 3000 을 만족할 때 mark(red rect)을 인식
                    
                    4.mark(red rect)을 인식하면 반시계방향 90도 회전하고 flag = 0(6. flag에서 설명)
                    
          case2 : 1단계  -->  2단계
                    
                    0. step = 2
          
                    1.mark(red rect)의 면적 = stats_r.Area
                    
                    2.300 < stats_r.Area < 3000 을 만족할 때는 flag = 1(6. flag에서 설명)
                    
                    3.stats_r.Area > 3000 을 만족할 때 mark(red rect)을 인식
                    
                    4.mark(red rect)을 인식하면 반시계방향 90도 회전하고 flag = 0(6. flag에서 설명)
                    
          case3 : 2단계  -->  3단계
          
                    0. step = 3
          
                    1.mark(purple rect)의 면적 = stats_r.Area
                    
                    2.300 < stats_r.Area < 3000 을 만족할 때는 flag = 1(6. flag에서 설명)
                    
                    3.stats_r.Area > 3000 을 만족할 때 mark(purple rect)을 인식
                    
                    4.mark(purple rect)을 인식하면 rand
                    
          
#### 6. Hole과 rect이 드론의 카메라의 화면상에 보이지 않을 때 search 알고리즘
----------
          


# 소스 코드 설명


## Function지정
-----
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
     
         t=0;   
         while t<2000
             switch step
## Case 1
------
                 case 1
                     frame=snapshot(cameraObj);
                     hsv_img=rgb2hsv(frame);

                     h=hsv_img(:,:,1); s=hsv_img(:,:,2); v=hsv_img(:,:,3);
                     mask=(0.55<h)&(h<0.65)&(0.3<s)&(s<=1)&(0.3<v)&(v<=1); 
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
## Case 2
----
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
## Case 3
----
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

Informaiton
=============
서울시립대학교 기계정보공학과
담당교수 황면중교수
석사과정 문선영
석사과정 박종훈
e-mail : rhaxls07@uos.ac.kr
e-mail : qkrwhdgns116@uos.ac.kr
연락처 : 010-8949-5756
연락처 : 010-7115-4220
