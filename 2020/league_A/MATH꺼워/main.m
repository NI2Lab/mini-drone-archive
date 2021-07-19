drone=ryze();
pause(4);
cam=camera(drone);
pause(7);
takeoff(drone);
pause(1);
moveup(drone,'Distance',0.25,'WaitUntilDone',false);
pause(3);
moveforward(drone,'Distance',1.2,'WaitUntilDone',false);
pause(3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0. 변수 설정 
max=1;
max2=1;
max_1=1;
max_1_2=1;
max_2_2=1;
max_2=1;
max_for_3=1;
max_for_2=1;
green_x_length=0;
green_match=0;
green_match_first=1; 
green_match_first_yaw=0;
miss_green=0;
green_a=10;
green_empty=0;

red_close=3;
red_match=0;    
red_match_check=0;
blue_close=3;
blue_match=0;
blue_match_check=0;
center_green=[0  0];
center_green_for_stage3= [0 0];
center_green_for_stage2= [0 0];
center_red=[0 0];
center_red_save=[0 0];
center_blue=[0 0];
center_blue_save=[0 0];
stage_check=1;
dilemma_count=0;
up=0; %stage_check 2에서  green_match_first 할때 up, down 수를 세어 준다
down=0;
yaw_y_left=0;
yaw_y_right=0;
yaw_data=6;
ydif=0;
check_1=[0 0];
find_yaw_left=0;
find_yaw_right=0;
yaw_start_for_stage3=0;
yaw_start_for_stage2=0;
mode_control_done=11;
 x_d = 130;
 y_d = 120;
 fix_center= [480 210];
 
 find_stage3 =0;
 find_stage2 =0;
mode = 1;
while(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1. 기본 영상 처리를 위한 RGB 처리
    %clearvars frame mySize a b R G B img justGreen bw x y xm ym xx yy bwbw stats props; 
    frame=snapshot(cam);
    
    mySize=size(frame);
    a=mySize(2);
    b=mySize(1);
    img=frame;
    titleSection=sprintf('mode_control_done:%d',mode_control_done);
    imshow(img),title(titleSection);
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    hold on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2.1 초록색 링 검출을 위한 필터
    justGreen = G - R/2 - B/2;
    justRed = R - G/2 - B/2;
    justBlue = B - G/2 - R/2;
    bw = justGreen > 40; 
    bwred = justRed > 55;
    bwblue = justBlue > 55; 
    bw2 =imcomplement(bw);
        
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2.2빨간색 원형 중앙값,반지름 값 검출 
if ~isempty (bwred) 
     [center_red,radii_red] = imfindcircles(bwred,[6 20],'ObjectPolarity','bright', ...
    'Sensitivity',0.9,'Method','twostage');  
         if ~isempty (center_red) 
              disp(radii_red);
              viscircles(center_red,radii_red,'Color','r');
              if red_close<=radii_red(1) && mode==2
                 red_close=radii_red(1);
              else
                   red_close=radii_red(1);
              end
              center_red_save=center_red;
              plot(center_red_save(1),center_red_save(2),'-r+');
         end
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2.3 파란색 원형 중앙값,반지름 값 검출 
if ~isempty (bwblue)
     [center_blue,radii_blue] = imfindcircles(bwblue,[6 20],'ObjectPolarity','bright', ...
    'Sensitivity',0.9,'Method','twostage');   
        if ~isempty (center_blue) 
                  disp(radii_blue);
                  viscircles(center_blue,radii_blue,'Color','b');
                  
                  if blue_close<=radii_blue(1) &&mode==3
                     blue_close=radii_blue(1);
                  else
                     blue_close=radii_blue(1);
                  end
                  center_blue_save=center_blue;
                  plot(center_blue(1),center_blue(2),'-b+');
        end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2.4 초록색링 중앙 검출
    props = regionprops(bw2,'Image','BoundingBox','Centroid','Area');
    
        if ~isempty (props)  
            miss_green=0;
            if length (props)==1
             miss_green=1;
           
            elseif length (props)>1 
             A= zeros(length (props));
                for j=1:length (props)
%                      if props(j).Area<10000
%                       continue;
%                      end
                  A(j)=props(j).Area;
                end
             B = sort(A,'descend');
             for j=1:length (props)
                if B(2)==props(j).Area
                    max2=j;
                end
                if B(1)==props(j).Area
                    max=j;
                end
             end
             
             bbbb1=props(max).BoundingBox;
                 if(bbbb1(3)==960 || bbbb1(4)==720 )
                    max=max2; 
                 end
             green_box=props(max).BoundingBox;
             green_x_length_before=green_x_length;
                if green_x_length<green_box(3)
                    green_x_length = green_box(3);
                end
             rectangle('Position',green_box,'EdgeColor','m','LineWidth',3);
             center_green=props(max).Centroid;
             disp(green_x_length);
             plot(center_green(1),center_green(2),'-r+');     
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2.5 yaw 제어를 위한 링 검출
if miss_green==0 && mode ==1 &&  green_match_first==1 &&yaw_start_for_stage3==0 &&yaw_start_for_stage2==0
        
    props1 = regionprops(bw,'Image','BoundingBox','Centroid','Area');
    if~isempty (props) &&mode ==1
         if length(props1)==1
           max_1=1;

       elseif length (props1)>1
         A= zeros(length (props1));
         for j=1:length (props1)
%              if props1(j).Area<10000
%                         continue;
%              end
            A(j)=props1(j).Area;
         end
         B = sort(A,'descend');
            for j=1:length (props1)
                    if B(2)==props1(j).Area
                        max_1_2=j;
                    end
                    if B(1)==props1(j).Area
                        max_1=j;
                    end
            end
        bbbb1=props1(max_1).BoundingBox;
         if(bbbb1(3)==960 && bbbb1(4)==720 )
            max_1=max_1_2; 
         end
         end 
    
    image_1 = props1(max_1).Image;
    image_1_inverse = imcomplement(image_1);
    props2 = regionprops(image_1_inverse,'Image','BoundingBox','Centroid','Area');

    if length(props2)==1
           max_2=1;

       elseif length (props2)>1
         A= zeros(length (props2));
         for j=1:length (props2)
%              if props2(j).Area<10000
%                         continue;
%              end
            A(j)=props2(j).Area;
         end
         B = sort(A,'descend');
            for j=1:length (props2)
                    if B(2)==props2(j).Area
                        max_2_2=j;
                    end
                    if B(1)==props2(j).Area
                        max_2=j;
                    end
            end
        bbbb1=props2(max_2).BoundingBox;
         if(bbbb1(3)==960 && bbbb1(4)==720 )
            max_2=max_2_2; 
         end
    end 
    
    
    image_2 = props2(max_2).Image;

    x_1=props1(max_1).BoundingBox(1);
    x_2=props2(max_2).BoundingBox(1);
    y_1=props1(max_1).BoundingBox(2);
    y_2=props2(max_2).BoundingBox(2);

    width = props2(max_2).BoundingBox(3);
    height = props2(max_2).BoundingBox(4);

    final_left=[0 0 1 1];
    final_right=[0 0 1 1];
   

    for j= 1:width/2
        yaw_y_left= height-j+1;
        yaw_x_left= 1 ;
        while(1)
          find_yaw_left=0;
              if image_2(yaw_y_left,yaw_x_left) ==1
                  find_yaw_left=1;
                break;
              elseif yaw_y_left ==height && yaw_x_left==j
                break;   
              end
          yaw_y_left=yaw_y_left+1;
          yaw_x_left=yaw_x_left+1;
        end
               if find_yaw_left==1
                break;
               end
    end
    
    for j= 1:width/2
        yaw_y_right= height-j+1;
        yaw_x_right= width ;
        while(1)
          find_yaw_right=0;
              if image_2(yaw_y_right,yaw_x_right) ==1
                  find_yaw_right=1;
                break;
              elseif yaw_y_right ==height && yaw_x_right==width-j+1
                break;   
              end
          yaw_y_right=yaw_y_right+1;
          yaw_x_right=yaw_x_right-1;
        end
               if find_yaw_right==1
                break;
               end
    end



    final_left(1)=x_1+x_2+yaw_x_left;
    final_left(2)=y_1+y_2+yaw_y_left;

    final_right(1)=x_1+x_2+yaw_x_right;
    final_right(2)=y_1+y_2+yaw_y_right;
 

        rectangle('Position',final_left,'EdgeColor','r','LineWidth',3);
        rectangle('Position',final_right,'EdgeColor','r','LineWidth',3);

    end
end
        else
            miss_green=1;
        end
%%%%%%%%%%%%%%%%% stage 3 를 위한  녹색 탐색
if stage_check ==3 && mode==1 && green_match_first==1 && ~isempty (bw) &&find_stage3==0
     
    props3_for_stage3 = regionprops(bw,'BoundingBox','Centroid','Area');
    
     A= zeros(length (props3_for_stage3));
         for j=1:length (props3_for_stage3)
            A(j)=props3_for_stage3(j).Area;
         end
         B = sort(A,'descend');
            for j=1:length (props3_for_stage3)
                    if B(1)==props3_for_stage3(j).Area
                        max_for_3=j;
                    end
                    
            end
            center_green_for_stage3=props3_for_stage3(max_for_3).Centroid;
            jk3= sprintf("center_green_for_stage2 %d %d",center_green_for_stage3(1),center_green_for_stage3(2));
            disp(jk3);
            if  center_green_for_stage3(1)<480
                disp('find_stage3 _ go left@@@@@@@@@@@@@@@@@');
                pause(2);
                moveleft(drone,'Distance',0.9,'WaitUntilDone',false);
                pause(2);
            elseif center_green_for_stage3(1)>=480
                disp('find_stage3 _ go right@@@@@@@@@@@@@@@@@');
                pause(2);
                moveright(drone,'Distance',0.9,'WaitUntilDone',false);
                pause(2);
            end
            
           
            find_stage3=1;
            yaw_start_for_stage3=0;
            
end

if stage_check ==2 && mode==1 && green_match_first==1 && ~isempty (bw) &&find_stage2==0
    props3_for_stage2 = regionprops(bw,'BoundingBox','Centroid','Area');
    
     A= zeros(length (props3_for_stage2));
         for j=1:length (props3_for_stage2)
            A(j)=props3_for_stage2(j).Area;
         end
         B = sort(A,'descend');
            for j=1:length (props3_for_stage2)
                    if B(1)==props3_for_stage2(j).Area
                        max_for_2=j;
                    end
                    
            end
            center_green_for_stage2=props3_for_stage2(max_for_2).Centroid;
            jk3= sprintf("center_green_for_stage2 %d %d",center_green_for_stage2(1),center_green_for_stage2(2));
            disp(jk3);
            if  center_green_for_stage2(2)<200
                disp('find_stage2 _ go up@@@@@@@@@@@@@@@@@');
                pause(3);
                moveup(drone,'Distance',0.45,'WaitUntilDone',false);
                pause(3);
            elseif center_green_for_stage2(2)>=200
                disp('find_stage2 _ go down@@@@@@@@@@@@@@@@@');
                pause(3);
                movedown(drone,'Distance',0.45,'WaitUntilDone',false);
                pause(3);
            end
            find_stage2=1;
            yaw_start_for_stage2=0;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2.21 빨간색 원형 검출을 위한 필터

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3.11 모터 제어 전에 x_d ,y_d를 결정 해준다
      

    if mode ==1 && ~isempty (props) &&green_match_first ==0  % green_x_length 가 기준 stage에 따라 기준이 다르다
                                                % 단 첫번째는 default로 x_d=90
                                                % y_d=80
        fix_center= [480 210];                                         
        if stage_check==1      
               if green_x_length <400
                  x_d=83;
                  y_d=70;
               elseif green_x_length <450   
                  x_d=85;
                  y_d=72;
               elseif green_x_length <500   
                  x_d=87;
                  y_d=74;
               elseif green_x_length <600   
                  x_d=89;
                  y_d=78;
               else
                  x_d=87;
                  y_d=83;
               end
               
        elseif stage_check==2
                if green_x_length <400
                  x_d=72;
                  y_d=65;
               elseif green_x_length <500   
                  x_d=77;
                  y_d=66;
               elseif green_x_length <600   
                  x_d=76;
                  y_d=68;
               elseif green_x_length <650   
                  x_d=78;
                  y_d=71;
               elseif green_x_length <700   
                  x_d=80;
                  y_d=74;
               elseif green_x_length <750   
                  x_d=82;
                  y_d=76; 
               elseif green_x_length <800   
                  x_d=84;
                  y_d=77;   
               else
                  x_d=87;
                  y_d=79;
               end
        elseif stage_check==3
            if green_x_length <300
                  x_d=65;
                  y_d=55;
               elseif green_x_length <400   
                  x_d=67;
                  y_d=58;
               elseif green_x_length <500   
                  x_d=69;
                  y_d=61;
               elseif green_x_length <60   
                  x_d=66;
                  y_d=59;
               elseif green_x_length <700   
                  x_d=73;
                  y_d=67;
               elseif green_x_length <750   
                  x_d=74;
                  y_d=69; 
               elseif green_x_length <800   
                  x_d=74;
                  y_d=70;   
               else
                  x_d=77;
                  y_d=73;
            end
       end
        
    elseif mode==2 && ~isempty (center_red) 
        if stage_check==1
            fix_center= [480 185];
                if red_close<7
                     x_d =76;
                    y_d = 80;
                elseif red_close<8
                    x_d =83;
                    y_d = 85;
                end
                
        elseif stage_check==2  
            fix_center= [480 185];
                if red_close<7
                     x_d =88;
                    y_d = 70;
                elseif red_close<8
                    x_d =90;
                    y_d = 73;
                end
        end
    elseif mode==3 && ~isempty (center_blue)
        fix_center= [480 185];
            if blue_close<7
                 x_d =82;
                y_d = 72;
            elseif blue_close<8
                x_d =85;
                y_d = 72;
            end
            
    end
    jk= sprintf("x_d,y_d      %d %d",x_d,y_d);
    disp(jk);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3.12 현재 모드에 따라 box를 plot 해준다   
    
    
        p1 = [fix_center(1)-x_d,fix_center(1)+x_d];
        p2 = [fix_center(2)-y_d,fix_center(2)-y_d]; 
        plot(p1,p2,'Color','m','LineWidth',1); % 위쪽   위쪽 y_d는 항상 45로 고정 
        
        p3 = [fix_center(1)-x_d,fix_center(1)-x_d];
        p4 = [fix_center(2)-y_d,fix_center(2)+y_d];
        plot(p3,p4,'Color','m','LineWidth',1); %왼쪽
        
        p5 = [fix_center(1)+x_d,fix_center(1)+x_d];
        p6 = [fix_center(2)-y_d,fix_center(2)+y_d];
        plot(p5,p6,'Color','m','LineWidth',1); % 오른쪽
        
        p7 = [fix_center(1)-x_d,fix_center(1)+x_d];
        p8 = [fix_center(2)+y_d,fix_center(2)+y_d];
        plot(p7,p8,'Color','m','LineWidth',1); % 아래쪽
        
    
    
    hold off
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5.10 모드에 따라서 중심이 되는 기준이 다르다
    if mode ==1
        mode_control_done=11;
    elseif mode ==2 && red_close<8
        mode_control_done=21;
    elseif mode ==3 && blue_close<8
        mode_control_done=31;
    else 
        mode_control_done=0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4.1 mode_control_done에 따라 직접 모터를 제어한다.
   if mode_control_done ==11
    
       if center_green(1)<fix_center(1)-x_d
          moveleft(drone,'Distance',0.2,'WaitUntilDone',false);
          disp('green_left');
          dilemma_count=dilemma_count+1;
          pause(2.5);
       elseif center_green(1)>fix_center(1)+x_d
           moveright(drone,'Distance',0.2,'WaitUntilDone',false);
           disp('green_right');
           dilemma_count=dilemma_count+1;
          pause(2.5);
       end
       
        if center_green(2)<fix_center(2)-y_d
            moveup(drone,'Distance',0.2,'WaitUntilDone',false);
            disp('green_up');
            dilemma_count=dilemma_count+1;
                if stage_check==2 &&green_match_first==1
                    up=up+1;
                end
            
            pause(2.5);
       elseif center_green(2)>fix_center(2)+y_d
            movedown(drone,'Distance',0.2,'WaitUntilDone',false);
            disp('green_down');
            dilemma_count=dilemma_count+1;
                if stage_check==2 &&green_match_first==1
                    down=down+1;
                end
            pause(3);
        end
        
        green_match=0;
        if center_green(1)<=fix_center(1)+x_d &&center_green(1)>=fix_center(1)-x_d && center_green(2)>=fix_center(2)-y_d &&center_green(2)<=fix_center(2)+y_d
         disp('green_match')
         dilemma_count=0;
         green_match=1;
        end
        if dilemma_count>6 && green_match_first==0
            dilemma_count=0;
             disp('dilemma_count_green_match');
            green_match=1;
        end
   elseif mode_control_done == 21 && mode==2 &&~isempty (center_red) 
       
        if center_red_save(1)<fix_center(1)-x_d
          moveleft(drone,'Distance',0.2,'WaitUntilDone',false);
          disp('red_left');
          dilemma_count=dilemma_count+1;
          pause(2.5);
        elseif center_red_save(1)>fix_center(1)+x_d
           moveright(drone,'Distance',0.2,'WaitUntilDone',false);
           disp('red_right');
           dilemma_count=dilemma_count+1;
          pause(2.5);
        end
       
        if center_red_save(2)<fix_center(2)-y_d
            moveup(drone,'Distance',0.2,'WaitUntilDone',false);
            disp('red_up');
            dilemma_count=dilemma_count+1;
            pause(2.5);
       elseif center_red_save(2)>fix_center(2)+y_d
            movedown(drone,'Distance',0.2,'WaitUntilDone',false);
            disp('red_down');
            dilemma_count=dilemma_count+1;
            pause(3.5);
        end
        
        red_match=0;
        if center_red_save(1)<=fix_center(1)+x_d &&center_red_save(1)>=fix_center(1)-x_d && center_red_save(2)>=fix_center(2)-45 &&center_red_save(2)<=fix_center(2)+y_d
         disp('red_match');
         red_match=1;
        end
        
        if dilemma_count>6
            dilemma_count=0;
            disp('dilemma_count_red_match');
            red_match=1;
        end
   elseif mode_control_done == 31 && mode==3 &&~isempty (center_blue) 
       
        if center_blue_save(1)<fix_center(1)-x_d
          moveleft(drone,'Distance',0.2,'WaitUntilDone',false);
          disp('blue_left');
          dilemma_count=dilemma_count+1;
          pause(2.5);
        elseif center_blue_save(1)>fix_center(1)+x_d
           moveright(drone,'Distance',0.2,'WaitUntilDone',false);
           disp('blue_right');
           dilemma_count=dilemma_count+1;
          pause(2.5);
        end
       
        if center_blue_save(2)<fix_center(2)-y_d
            moveup(drone,'Distance',0.2,'WaitUntilDone',false);
            disp('blue_up');
            dilemma_count=dilemma_count+1;
            pause(2.5);
       elseif center_blue_save(2)>fix_center(2)+y_d
            movedown(drone,'Distance',0.2,'WaitUntilDone',false);
            disp('blue_down');
            dilemma_count=dilemma_count+1;
            pause(3.5);
        end
        
        blue_match=0;
        if center_blue_save(1)<=fix_center(1)+x_d &&center_blue_save(1)>=fix_center(1)-x_d && center_blue_save(2)>=fix_center(2)-y_d &&center_blue_save(2)<=fix_center(2)+y_d
         disp('blue_match');
         pause(2);
         blue_match=1;
        end
        
        if dilemma_count>6
            dilemma_count=0;
            disp('dilemma_count_blue_match');
            blue_match=1;
        end
   elseif mode==2 &&isempty (center_red) ||  mode==3 &&isempty (center_blue)
       
       moveforward(drone,'Distance',0.2,'WaitUntilDone',false);
       pause(2);
       disp('nothing found, just go ')
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5.1  mode1에 따른 알고리즘

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% 5.11  green_match_first==1 에서 yaw 제어 한번 해준다
 

     
  
    if mode ==1 && green_match==1 &&green_match_first==1&&yaw_start_for_stage3==0 &&yaw_start_for_stage2==0
        jk= sprintf("yaw          %d %d",final_left(2),final_right(2));
        disp(jk);
        if stage_check==3 && green_x_length>650
            disp('too close to set yaw!');
            pause(2);
            moveback(drone,'Distance',0.3,'WaitUntilDone',false);
            pause(2);
            continue;
            
        end
            ydif=final_right(2)-final_left(2);
        if ydif>19 || ydif< -19
            yaw_data=0.10472;
        else
            yaw_data=0.0523599;
        end
            
        if final_left(2) - final_right(2) >2
            turn(drone,-1*yaw_data);
            %mode_control_done=0;   이걸 넣어야 하나 말아야 하나 해보자 
            continue;
        elseif final_left(2) - final_right(2) < -2
            turn(drone,yaw_data);
            %mode_control_done=0;
            continue;
        else
                if final_left(2) - final_right(2)==0
                    green_match_first_yaw=1;
                    disp('yaw is correct!')
                elseif final_left(2) - final_right(2)>0                   
                    turn(drone,deg2rad(-3));
                    green_match_first_yaw=1;
                    disp('yaw is correct!')
                    
                elseif final_left(2) - final_right(2)<0
                    turn(drone,deg2rad(3));
                    green_match_first_yaw=1;
                    disp('yaw is correct!')
                end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5.12 mode 1 처음 시작 할때  고정된 x_d y_d
        green_empty=0;
    if mode==2 || mode ==3
    if bw(720-green_a,960-green_a)==0&&bw(720-green_a,green_a)==0&&bw(green_a,960-green_a)==0&&bw(green_a,green_a)==0 && ~isempty (bw)
                      disp('now green is empty!!!!!!!!!!!!!!!!!!!!!!!!!!1');
                      green_empty=1;
    end
    end

    if mode ==1 && green_match==1 &&green_match_first ==1 &&green_match_first_yaw==1 
        disp('mode1_green_match_first')
        moveforward(drone,'Distance',0.2,'WaitUntilDone',false);
        green_match_first =0;
        green_match_first_yaw=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5.12 mode 1 x_d y_d 키우면서 빨간원 or 파란원 찾을때까지 직진해준다         
    elseif mode ==1  &&green_match_first ==0
        
        if ~isempty (center_red)&&red_close>5 && green_box(1)< center_red(1)&&center_red(1)<green_box(1)+green_box(3) && green_box(2)< center_red(2)&&center_red(2)<green_box(2)+green_box(4) &&stage_check<3
            mode=2;
            disp('mode2 start');
            moveforward(drone,'Distance',0.4,'WaitUntilDone',false);
            pause(2);
            mode_control_done=21;
            red_close=6;
        elseif ~isempty (center_blue)&&blue_close>5 && green_box(1)< center_blue(1)&&center_blue(1)<green_box(1)+green_box(3) && green_box(2)< center_blue(2)&&center_blue(2)<green_box(2)+green_box(4) &&stage_check==3
            mode=3;
            disp('mode3 start');
            moveforward(drone,'Distance',0.4,'WaitUntilDone',false);
            pause(2);
            mode_control_done=31;
        elseif green_match==1
            disp('mode1_green_match_just_go')
            moveforward(drone,'Distance',0.45,'WaitUntilDone',false); % 속도 높여도 될지 돌리면서 결정하기
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5.2  mode2에 따른 알고리즘    
    if mode ==2 &&red_close<7 && red_match==1
        disp('mode2_red_match_1')
        moveforward(drone,'Distance',0.2,'WaitUntilDone',false);
        mode_control_done=21;
        pause(3);

    elseif mode ==2 &&red_close==7 &&red_match==1 ||  mode ==2 &&red_close>7 || mode==2 && red_close==7&&green_empty==1
        disp(red_close);
        disp('mode2_red_match_2_success')
        red_match_check=0;
        mode_control_done=0;
        green_match_first_yaw=0;
        green_match_first=1;
        green_x_length=0;
        red_match=0;
        pause(3);
        if red_close<8
            disp('red_match_go_1');
            moveforward(drone,'Distance',1,'WaitUntilDone',false);
        elseif  red_close<9
            disp('red_match_go_0.9');
            moveforward(drone,'Distance',0.9,'WaitUntilDone',false);
        elseif red_close<10
            disp('red_match_go_0.8');
            moveforward(drone,'Distance',0.8,'WaitUntilDone',false);
        else
            disp('red_match_go_0.7');
            moveforward(drone,'Distance',0.7,'WaitUntilDone',false);
        end
        pause(4);
        turn(drone,-1.5708);
        pause(4);
      
         x_d = 130;
         y_d = 120;
   
         green_match=0;
        stage_check=stage_check+1;
        
        
        if stage_check==2
           pause(1);
           moveforward(drone,'Distance',1,'WaitUntilDone',false);
           pause(4);
           yaw_start_for_stage2=1;
        elseif stage_check==3
           moveforward(drone,'Distance',1.05,'WaitUntilDone',false);
           pause(2);
           yaw_start_for_stage3=1;
           if  center_green_for_stage2(2)<200
                disp('find_stage3 _ go down@@@@@@@@@@@@@@@@@');
                pause(3);
                movedown(drone,'Distance',0.65,'WaitUntilDone',false);
                pause(3);
            elseif center_green_for_stage2(2)>=200
                disp('find_stage3 _ go up@@@@@@@@@@@@@@@@@');
                pause(3);
                moveup(drone,'Distance',0.8,'WaitUntilDone',false);
                pause(3);
            end
        end
        disp('mode2 done');
        mode =1;
        dilemma_count=0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5.3  mode3에 따른 알고리즘    
    if mode ==3 &&blue_close<7 && blue_match==1
        disp('mode3_blue_match_1')
        moveforward(drone,'Distance',0.2,'WaitUntilDone',false);
        mode_control_done=31;
        pause(3);
    elseif mode ==3 &&blue_close==7 &&blue_match==1  || mode ==3 &&blue_close>7|| mode ==3 &&blue_close==7 && green_empty==1
        disp('mode3_blue_match_2_success')
        blue_match_check=0;
        mode_control_done=0;
        green_match_first=1;
        blue_match=0;
        pause(3);
        if blue_close<8
            disp('blue_match_go_1');
            moveforward(drone,'Distance',1,'WaitUntilDone',false);
        elseif  blue_close<9
            disp('blue_match_go_0.8');
            moveforward(drone,'Distance',0.8,'WaitUntilDone',false);
        elseif blue_close<10
            disp('blue_match_go_0.7');
            moveforward(drone,'Distance',0.7,'WaitUntilDone',false);
        else
            disp('blue_match_go_0.6');
            moveforward(drone,'Distance',0.6,'WaitUntilDone',false);
            
        end
        pause(5);
        disp('fianlly mode3 done'); 
           break; 
       
    end
end

    %jk= sprintf("%d %d",B(1),B(2));
    %disp(jk);
land(drone);