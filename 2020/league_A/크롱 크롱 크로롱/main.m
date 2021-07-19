function main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 시작 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
crong= ryze();
cam = camera(crong);
takeoff(crong);
moveup(crong,'Distance',0.2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%변수설정%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
orientation = rad2deg(readOrientation(crong));
st=0; tr=0; prevori=""; z=0;
section=1; count2=0; count3=0; count4=0;
rangetop=16; rangebottom=48; rangeleft=79; rangeright=108;
rangetop2=22; rangebottom2=50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%알고리즘%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z = -orientation(1);
turn(crong,deg2rad(z)); 
while 1
    count=0; count1=0; tr=0; 
    ori=[0 0 0 0];  
    frame = snapshot(cam);
    
    if isempty(frame)
        frame = snapshot(cam);
    end
    
    frame = imresize(frame,0.2);
    frame = double(frame);
    [R C X] = size(frame);

    if section==1
        %%%%%%%%%%%%st값 초기화%%%%%%%%%%%%%%%%%
        if frame(1,1,2)-frame(1,1,1)<15 || frame(1,1,2)-frame(1,1,3)<15
            prev=0;
        else
            prev=1;
        end
        for r=1:R
            if frame(r,1,2)-frame(r,1,1)<15 || frame(r,1,2)-frame(r,1,3)<15 %top
                ori(3)=0;
            else
                ori(3)=1;
                break;
            end
        end
        for r=1:R
            if frame(r,192,2)-frame(r,192,1)<15 || frame(r,192,2)-frame(r,192,3)<15 %bottom
                ori(4)=0;
            else
                ori(4)=1;
                break;
            end
        end
        for c=1:C 
            if frame(1,c,2)-frame(1,c,1)<15 || frame(1,c,2)-frame(1,c,3)<15 %up
                resent=0;
                if prev ~= resent
                    prev=resent;
                    count1 = count1+1;
                end
            else
                resent=1;
                if prev~=resent
                    prev=resent;
                    count1 = count1+1;
                end
            end
        end
        if count1<=2
            ori(1)=0;
        else
            ori(1)=1;
        end
        for c=1:C       
            if frame(144,c,2)-frame(144,c,1)<15 || frame(144,c,2)-frame(144,c,3)<15 %down
                ori(2)=0;
            else
                ori(2)=1;
                break;
            end
        end

        if nnz(ori)==1 || nnz(ori)==2 %nnz()=> 0이 아닌 요소의 갯수.
            st=1;
        else
            st=0;
        end
        %%%%%% 사각형이 화면안에 들어와 있지X 경우 st==1 %%%%%%
        if st==1
            if ori(1)==1
                count3=count3+1;
                a="upX"
                moveup(crong,'distance',0.2);       
            end
            if ori(2)==1
                count3=count3+1;
                a="downX"
                movedown(crong,'distance',0.3);
            end
            if ori(3)==1
                count3=count3+1;
                a="leftX"
                moveleft(crong,'distance',0.2);
            end
            if ori(4)==1
                count3=count3+1;
                a="rightX"
                moveright(crong,'distance',0.2);
            end
        %%%%%% 사각형이 화면안에 들어와 있지O 경우 st==0 %%%%%%
        elseif st==0
            %%%%녹색링의 중점찾기%%%%
            for r=1:R
                for c=1:C
                    if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15  %녹색점 찾기
                    else
                        if count == 0
                           miny=r;
                           count=1;
                        end
                        maxy=r;
                    end
                end
            end
            count=0;
            for c=1:C
                for r=1:R
                    if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15  %녹색점 찾기 
                    else
                        if count == 0
                           minx=c;
                           count=1;
                        end
                        maxx=c;
                    end
                end
            end

            medx=(maxx+minx)/2;
            medy=(maxy+miny)/2;

            if medx<rangeleft && medx>0
                count3=count3+1;
                a="left0"
                moveleft(crong,'distance',0.2);
            end
            if medx>rangeright
                count3=count3+1;
                a="right0"
                moveright(crong,'distance',0.2); 
            end
            if medy<rangetop
                count3=count3+1;
                a="up0"
                moveup(crong,'distance',0.2); 
            end
            if medy>rangebottom
                count3=count3+1;
                a="down0"
                movedown(crong,'distance',0.2);
            end
            %%%%링의 중점에 들어온 경우%%%%
            if medx>=rangeleft && medx<=rangeright && medy>=rangetop && medy<=rangebottom
                a="correct"                
                if count3>=2
                    moveforward(crong,'Distance',2.3,'Speed',0.9);                   
                else
                     moveforward(crong,'Distance',2.35,'Speed',1); 
                end
                turn(crong,deg2rad(-90));
                count3=0;                
                moveforward(crong,'Distance',0.75,'Speed',1);
                minx=0;miny=0;maxx=0;maxy=0;medx=0;medy=0;
                pause(1);
                z =-orientation(1);
                turn(crong,deg2rad(z));
                section=section+1;
            end
        end
        disp("section1 time : ")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5        
    elseif section==2
        %%%%%%%%%%%%st값 초기화%%%%%%%%%%%%%%%%%
        if frame(1,1,2)-frame(1,1,1)<15 || frame(1,1,2)-frame(1,1,3)<15
            prev=0;
        else
            prev=1;
        end
        for r=1:R
            if frame(r,1,2)-frame(r,1,1)<15 || frame(r,1,2)-frame(r,1,3)<15 %top
                ori(3)=0;
            else
                ori(3)=1;
                break;
            end
        end
        for r=1:R
            if frame(r,192,2)-frame(r,192,1)<15 || frame(r,192,2)-frame(r,192,3)<15 %bottom
                ori(4)=0;
            else
                ori(4)=1;
                break;
            end
        end
        for c=1:C 
            if frame(1,c,2)-frame(1,c,1)<15 || frame(1,c,2)-frame(1,c,3)<15 %up
                resent=0;
                if prev ~= resent
                    prev=resent;
                    count1 = count1+1;
                end
            else
                resent=1;
                if prev~=resent
                    prev=resent;
                    count1 = count1+1;
                end
            end
        end
        if count1<=2
            ori(1)=0;
        else
            ori(1)=1;
        end
        for c=1:C       
            if frame(144,c,2)-frame(144,c,1)<15 || frame(144,c,2)-frame(144,c,3)<15 %down
                ori(2)=0;
            else
                ori(2)=1;
                break;
            end
        end

        if nnz(ori)==1 || nnz(ori)==2 %nnz()=> 0이 아닌 요소의 갯수.
            st=1;
        else
            st=0;
        end
        %%%%%% 사각형이 화면안에 들어와 있지X 경우 st==1 %%%%%%
        if st==1
            if ori(1)==1
                a="upX"
                prevori=a;
                count4=0;
                moveup(crong,'distance',0.2);       
            end
            if ori(2)==1
                a="downX"
                prevori=a;
                count4=0;
                movedown(crong,'distance',0.3);
            end
            if ori(3)==1
                a="leftX"
                if prevori=="rightX"
                    count4=count4+1;
                else
                    count4=0;
                end
                prevori=a;
                moveleft(crong,'distance',0.2);
            end
            if ori(4)==1
                a="rightX"
                if prevori=="leftX"
                    count4=count4+1;
                else
                    count4=0;
                end
                prevori=a;
                moveright(crong,'distance',0.2);
            end
            
            if count4>=4
                count4=0;
                moveforward(crong,'Distance',1.8,'Speed',1);
                turn(crong,deg2rad(-90));            
                moveforward(crong,'Distance',1,'Speed',1);
                minx=0;miny=0;maxx=0;maxy=0;medx=0;medy=0;
                pause(1);
                z =-orientation(1);
                turn(crong,deg2rad(z));
                section=section+1;
            end
        %%%%%% 사각형이 화면안에 들어와 있지O 경우 st==0 %%%%%%
        elseif st==0
            %%%%녹색링의 중점찾기%%%%
            for r=1:R
                for c=1:C
                    if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15  %녹색점 찾기
                    else
                        if count == 0
                           miny=r;
                           count=1;
                        end
                        maxy=r;
                    end
                end
            end
            count=0;
            for c=1:C
                for r=1:R
                    if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15  %녹색점 찾기 
                    else
                        if count == 0
                           minx=c;
                           count=1;
                        end
                        maxx=c;
                    end
                end
            end

            medx=(maxx+minx)/2;
            medy=(maxy+miny)/2;

            if medx<rangeleft
                a="left0"
                moveleft(crong,'distance',0.2);
            end
            if medx>rangeright
                a="right0"
                moveright(crong,'distance',0.2); 
            end
            if medy<rangetop2
                a="up0"
                moveup(crong,'distance',0.2); 
            end
            if medy>rangebottom2
                a="down0"
                movedown(crong,'distance',0.2);
            end
            %%%%링의 중점에 들어온 경우%%%%
            if medx>=rangeleft && medx<=rangeright && medy>=rangetop2 && medy<=rangebottom2
                a="correct"      
                moveforward(crong,'Distance',2.2,'Speed',1); 
                turn(crong,deg2rad(-90));            
                moveforward(crong,'Distance',1.1,'Speed',1);
                minx=0;miny=0;maxx=0;maxy=0;medx=0;medy=0;
                pause(1);
                z =-orientation(1);
                turn(crong,deg2rad(z));
                section=section+1;
            end 
        end
        disp("section2 time : ")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    elseif section==3
        %%%%%%%%%%%%st값 초기화%%%%%%%%%%%%%%%%%
        if frame(1,1,2)-frame(1,1,1)<15 || frame(1,1,2)-frame(1,1,3)<15
            prev=0;
        else
            prev=1;
        end
        for r=1:R
            if frame(r,1,2)-frame(r,1,1)<15 || frame(r,1,2)-frame(r,1,3)<15 %top
                ori(3)=0;
            else
                ori(3)=1;
                break;
            end
        end
        for r=1:R
            if frame(r,192,2)-frame(r,192,1)<15 || frame(r,192,2)-frame(r,192,3)<15 %bottom
                ori(4)=0;
            else
                ori(4)=1;
                break;
            end
        end
        for c=1:C 
            if frame(1,c,2)-frame(1,c,1)<15 || frame(1,c,2)-frame(1,c,3)<15 %up
                resent=0;
                if prev ~= resent
                    prev=resent;
                    count1 = count1+1;
                end
            else
                resent=1;
                if prev~=resent
                    prev=resent;
                    count1 = count1+1;
                end
            end
        end
        if count1<=2
            ori(1)=0;
        else
            ori(1)=1;
        end
        for c=1:C       
            if frame(144,c,2)-frame(144,c,1)<15 || frame(144,c,2)-frame(144,c,3)<15 %down
                ori(2)=0;
            else
                ori(2)=1;
                break;
            end
        end

        if nnz(ori)==1 || nnz(ori)==2 %nnz()=> 0이 아닌 요소의 갯수.
            st=1;
        else
            st=0;
        end
        %%%%%% 사각형이 화면안에 들어와 있지X 경우 st==1 %%%%%%
        if st==1
            if ori(1)==1
                a="upX"
                prevori=a;
                count4=0;
                moveup(crong,'distance',0.2);       
            end
            if ori(2)==1
                a="downX"
                prevori=a;
                count4=0;
                movedown(crong,'distance',0.3);
            end
            if ori(3)==1
                a="leftX"
                if isequal(prevori,"rightX")                    
                    count4=count4+1;
                else
                    count4=0;
                end
                prevori=a;
                moveleft(crong,'distance',0.2);
            end
            if ori(4)==1
                a="rightX"
                if isequal(prevori,"leftX")                    
                    count4=count4+1;
                else
                    count4=0;
                end
                prevori=a;
                moveright(crong,'distance',0.2);
            end            
            if count4>=4
                count4=0;
                moveforward(crong,'Distance',1.8,'Speed',1);
                st=2;
            end
        %%%%%% 사각형이 화면안에 들어와 있지O 경우 st==0 %%%%%%
        elseif st==0
            %%%%녹색링의 중점찾기%%%%
            for r=1:R
                for c=1:C
                    if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15  %녹색점 찾기
                    else
                        if count == 0
                           miny=r;
                           count=1;
                        end
                        maxy=r;
                    end
                end
            end
            count=0;
            for c=1:C
                for r=1:R
                    if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15  %녹색점 찾기 
                    else
                        if count == 0
                           minx=c;
                           count=1;
                        end
                        maxx=c;
                    end
                end
            end

            medx=(maxx+minx)/2;
            medy=(maxy+miny)/2;

            if medx<rangeleft && 0<medx
                a="left0"
                moveleft(crong,'distance',0.2);
            end
            if medx>rangeright
                a="right0"
                moveright(crong,'distance',0.2); 
            end
            if medy<rangetop2
                a="up0"
                moveup(crong,'distance',0.2); 
            end
            if medy>rangebottom2
                a="down0"
                movedown(crong,'distance',0.2);
            end
            %%%%링의 중점에 들어온 경우%%%%
            if medx==0 && medy==0 && count2==0
                a="rightXX"
                count2=count2+1;
                moveright(crong,'Distance',1,'Speed',1);
                continue;
            elseif medx==0 && medy==0 && count2==1
                count2=0;
                a="leftXX"
                moveleft(crong,'Distance',1.8,'Speed',1);
                continue;
            end

            if medx>=rangeleft && medx<=rangeright && medy>=rangetop2 && medy<=rangebottom2
                a="correct"     
                moveforward(crong,'Distance',2.1,'Speed',1); 
                st=2;
            end
        end
        
        %%%%파란색 판별%%%%
        if st==2
            frame = snapshot(cam);
            frame = imresize(frame,0.5);
            frame = double(frame);
            [R C X] = size(frame);

            for r=1:R
                for c=1:C
                    if frame(r,c,3)-frame(r,c,1)<15 || frame(r,c,3)-frame(r,c,2)<15
                        tr=0;
                    else
                        tr=1;
                        break;
                    end
                end
                if tr==1
                    break;
                end
            end
            if tr==1
               break; 
            else            
               disp("Blue Error") 
               break;
            end
        end
    else
        section=3;
        disp("Section Error!!")
        break;
    end
    clear('frame');
end
land(crong);
clear crong;
clear cam;
end