크롱 크롱 크로롱팀 소스코드

링 통과하기
---------------
![g](https://user-images.githubusercontent.com/65802459/87505306-80bc1480-c6a3-11ea-9845-b2496be5f879.gif) 
![KakaoTalk_20200715_150843305](https://user-images.githubusercontent.com/65802459/87509790-43f51b00-c6ad-11ea-8e9e-f29afeae3730.gif)


### 시작하기
이 지침은 프로젝트를 설정하고 코드의 진행방향을 이해하는데 도움이됩니다.

### 요구사항

전원을 켤 때 정면을 바라보는 방향으로 둔 채 켜주십시오.
시작 시 clear를 실행하십시오.(●'◡'●)
```c
>> clear
```

### 실행하기
드론을 시작하려면 명령창에서 다음을 시작하십시오.
```c
>> main
```

### 대회진행전략

*  720x960의 이미지를 처리하기엔 연산 시간이 오래걸리기 때문에 imresize함수를 사용하여 받아온 이미지를 0.2배로 줄여서 처리 속도를 빠르게 한다. 이미지를 144x192로 줄이고, 파란색 원을 판별하는 경우엔 이미지가 작으면 원도 작아져 색 판별이 어려워지기 때문에 마지막 세 번째 section에선 이미지를 0.5배로 줄여서 360x480으로 정확하게  인식하도록 한다.
* 링을 판단할 때 ori라는 [0 0 0 0] 배열로 받아오는 화면의 가장자리만 검사하여 화면 전체를 검사하는 것보다 처리속도를 빠르게 한다.
* 드론이 takeoff하고 정면을 보고 뜬 후에, 다음 section에서 정면을 보지 않는 경우 turn하여 정면을 보게한다.

### 알고리즘 설명
<img width="1039" alt="알고리즘" src="https://user-images.githubusercontent.com/65802459/87422209-33906200-c613-11ea-8aad-d4f144579499.png">


### 소스코드 설명

* 우선 처음 드론을 띄운 후에 z값을 조절하여 정면을 바라볼 수 있게 하고, 정면을 바라보고 있지 않을 경우 틀어진 각도만큼 드론의 방향도 틀어 정면을 볼 수 있게한다. 
```c
orientation = rad2deg(readOrientation(crong));
z = -orientation(1);
turn(crong,deg2rad(z));
```
* 링을 통과하는 경우를 각각 section 1, 2, 3 으로 나누어 진행한다. 처음 section은 1을 기본값으로 준 후, 첫 번째 링부터 시작하도록 한다. takeoff로 드론을 띄우고 이미지를 받아올 수 있도록한다. 이때 이미지를 받아오지 못한 경우(isempty함수) 다시 이미지를 받아와서 1/5배 줄여준다. size함수에서 R은 행, C는 열, X는 차수를 의미하며, 여기서는 RGB의 3차원을 의미한다. 
```c
crong= ryze();
cam = camera(crong);
takeoff(crong);
moveup(crong,'Distance',0.2);
section=1; 
frame = snapshot(cam);
if isempty(frame)
    frame = snapshot(cam);
end
frame = imresize(frame,0.2);
frame = double(frame);
[R C X] = size(frame);
```

* 전체 초록색 링을 드론이 받아오는 화면 안에 모두 들어오는 지 확인하는 것을 첫 번째 목표로 하여 받아오는 화면인 144x192의 위, 아래, 왼쪽, 오른쪽의 가장자리 부분에 초록색이 닿아있는지 판별한다.
* ori라는 기본 배열을 만든 후 [0 0 0 0]으로 설정하고, 맨 윗부분을 ori(1), 아랫부분을 ori(2), 왼쪽부분을 ori(3), 오른쪽 부분을 ori(4)로 지정, 초록색 링이 닿는 경우 배열의 요소를 1로 변경한다. 이때 ori(1)인 윗부분에 닿은 초록색 링의 엣지의 갯수를 카운트 하여 만약 2개 이하이면, 화면의 윗부분에 링이 닿지 않았다고 판별하고, 그 외에는 링이 닿았다고 판별한다. (받아오는 이미지상 초록색 링의 윗 부분이 화면의 가장자리에 걸쳐있어야 안정적인 범위 내에서 통과할 수 있기 떄문에 이처럼 작성하였다.)

```c
        if frame(1,1,2)-frame(1,1,1)<15 || frame(1,1,2)-frame(1,1,3)<15
            prev=0;
        else
            prev=1;
        end
        for r=1:R
            if frame(r,1,2)-frame(r,1,1)<15 || frame(r,1,2)-frame(r,1,3)<15  
                ori(3)=0;
            else
                ori(3)=1;
                break;
            end
        end
        for r=1:R
            if frame(r,192,2)-frame(r,192,1)<15 || frame(r,192,2)-frame(r,192,3)<15  
                ori(4)=0;
            else
                ori(4)=1;
                break;
            end
        end
        for c=1:C 
            if frame(1,c,2)-frame(1,c,1)<15 || frame(1,c,2)-frame(1,c,3)<15  
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
            if frame(144,c,2)-frame(144,c,1)<15 || frame(144,c,2)-frame(144,c,3)<15   
                ori(2)=0;
            else
                ori(2)=1;
                break;
            end
        end
```
* ori의 배열요소 중 0이 아닌 요소의 수(요소가 1인 경우)가 1  또는 2인 경우엔 st=1로, 사각형이 화면에 들어와 있지 않다고 판별한다. nnz(ori)가 1,2가 아닌 경우엔 st=0으로 구분하여 사각형이 화면에 들어와있다고 인식한다.

st 1 | st 0
------------ | ------------- 
사각형이 화면에 들어와 있지 않은 경우 | 사각형이 화면에 모두 들어와 있는 경우

```c
        if nnz(ori)==1 || nnz(ori)==2   %nnz()=> 0이 아닌 요소의 수
            st=1;
        else
            st=0;
        end
```
* 먼저 사각형이 화면에 들어와 있지 않은 st=1인 경우 위에서 설정한 ori배열로 초록색이 닿은 부분으로 이동시켜 링이 화면 안에 들어올 수 있도록 조정한다. 이 때 드론이 위치를 조정하면서 앞으로 조금씩 움직이는 현상이 발생한다. 따라서 차후에 직진하는 거리는 조정하기 위해 count3이라는 변수를 넣어 드론이 위치를 조정할 때마다 카운트를 해준다.
```c
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
```
* 화면에 사각형이 모두 들어온 경우는 st=0으로 우선 픽셀의 RGB를 판별한다. 이 때 화면의 가장자리에 닿은 녹색부분이 아무것도 없을 경우는 녹색링의 중점을 찾도록 한다. 여기서 frame을 보면 드론이 불러오는 이미지인 frame에서 첫번째 인자는 행을 의미하며, 두번째 인자는 열을 의미한다. 그리고 마지막 인자인 숫자는 1이 red, 2가 green, 3이 blue 를 의미하며, 녹색의 경우엔 녹색의 숫자가 높게 나올 것이므로 이러한 차를 이용해서 색을 판별하도록 한다. 다음으로 링의 중점을 판별하는 방법은 처음 만나는 x축의 값을 minx, 가장 마지막에 만나는 값을 maxx, 처음만나는 y축은 miny, 마지막에 만나는 y축의 값은 maxy로 값을 초기화 하도록 한다.

```c
        elseif st==0
                %%%%녹색링의 중점찾기%%%%
                for r=1:R
                    for c=1:C
                        if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15 
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
                        if frame(r,c,2)-frame(r,c,1)<15 || frame(r,c,2)-frame(r,c,3)<15  
                        else
                            if count == 0
                               minx=c;
                               count=1;
                            end
                            maxx=c;
                        end
                    end
                end
```

* 앞에서 구한 minx, miny, maxx, maxy를 통해 중간값인 medx, medy를 구한다.
```c
medx=(maxx+minx)/2;
medy=(maxy+miny)/2;
```
* snapshot으로 찍은 화면을 봤을 때 드론이 안정적으로 지나갈 수 있는 범위를 찾아 rangeleft, rangeright, rangetop, rangebottom의 값을 설정해주고 medx와 medy가 범위 안에 드는지 판별을 한다. 사각형이 화면에 들어왔지만 medx와 medy가 범위안에 들지 않는 경우, 중점을 설정범위에 맞추기위해 조금씩 움직이며 보정을 해준다. 이때도 마찬가지로 차후의 직진거리를 조정해주기 위해 앞서 사용된 count3를 이어서 사용하여 위치조정횟수를 카운트해준다.
```c
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
```
* 만약 medx와 medy가 설정해준 범위 안에 드는 경우 앞으로 직진하는데, 앞서 설명했던 count3를 이용하여, 두 번 이상 위치를 맞춰준 경우엔 2.3, 한 번 이하로 움직인 경우엔 2.35만큼 직진하도록 한다.
```c
                if medx>=rangeleft && medx<=rangeright && medy>=rangetop && medy<=rangebottom
                    a="correct"                
                    if count3>=2
                        moveforward(crong,'Distance',2.3,'Speed',0.9);                   
                    else
                         moveforward(crong,'Distance',2.35,'Speed',1); 
                    end
```
* 직진시킨 후에 좌측으로 90도 회전을 시키고, 다음 section에서 사용할 minx, maxx, miny, maxy, medx, medy를 모두 0으로 초기화시킨다. 회전 후 살짝 앞으로 이동시켜 다음 두 번째 링을 판별하는 section으로 이동하도록 한다. 
```c
                    turn(crong,deg2rad(-90));
                    count3=0;                
                    moveforward(crong,'Distance',0.75,'Speed',1);
                    minx=0;miny=0;maxx=0;maxy=0;medx=0;medy=0;
                    pause(1);
                    z = -orientation(1)
                    turn(crong,deg2rad(z));
                    section=section+1
                end
```
* section2는 section1과 비슷한 구조로 되어있지만, st가 1일경우, 즉, 사각형이 화면 안에 들어와있지 않은 경우에 이전 section1과 달리 드론이 계속 움직이고 있던 상황이기 때문에 드론과 링의 거리가 가까울 수 있는 문제가 있다. 이 때 거리가 가까운 경우 드론이 왼쪽과 오른쪽이 번갈아서 이동하게 되면서 링이 화면 밖에 있다고 나올 수 있기 때문에 왼쪽과 오른쪽이 연속으로 번갈아서 2번이상 실행 시 바로 직진하도록 한다. 이때 다음 section에서도 사용할 수 있게 count4는 0으로 초기화 시킨다.
```c
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
```
* 링의 중점에 들어온 경우, 2.2m를 직진한 후 90도를 돌려 1m를 추가로 더 직진 시킨다. 그 다음 마찬가지로 다음 section에서 사용할 minx, maxx, miny, maxy, medx, medy를 모두 0으로 초기화시키고, 드론이 정면을 볼 수 있도록 z값을 조정한다.
```c
           if medx>=rangeleft && medx<=rangeright && medy>=rangetop2 && medy<=rangebottom2
                a="correct"      
                moveforward(crong,'Distance',2.2,'Speed',1); 
                turn(crong,deg2rad(-90));            
                moveforward(crong,'Distance',1,'Speed',1);
                minx=0;miny=0;maxx=0;maxy=0;medx=0;medy=0;
                pause(1);
                z =-orientation(1);
                turn(crong,deg2rad(z));
                section=section+1;
            end 
```
* section3는 section2에서의 알고리즘과 거의 같지만, 다음 section이 아닌 파란색 점을 찾아야 하므로, 1.8만큼 직진한 후 파란색을 판별하는 st=2의 상태로 넘어간다.
```c
            if count4>=4
                count4=0;
                moveforward(crong,'Distance',1.8,'Speed',1);
                st=2;
            end
```
* section3의 경우 링의 위치에서 좌우로 움직이는 거리가 넓기 때문에 화면에 링이 보이지 않는 경우가 발생한다. 이때 화면의 테두리에 모두 초록색이 없어서 링이 화면안에 들어와 있다고 판별 할 것이고, 초록색이 없기 때문에 medx값과 medy값은 0일 것이다. 따라서 st=0, 즉, 링이 화면에 들어와 있는 경우 medx와 medy가 0일경우 좌우로 움직이는 소스를 추가한다.
```c
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
```
* 링을 찾은 후 중점을 판별하고 직진 한 후 st를 2로 변경시켜 주면서 파란점을 찾는 state로 넘어가도록 한다.
```c
            if medx>=rangeleft && medx<=rangeright && medy>=rangetop2 && medy<=rangebottom2
                a="correct"     
                moveforward(crong,'Distance',2.1,'Speed',1); 
                st=2;
            end
```
* 파란색 점을 판별하기 위해 다시 이미지를 찍은 후 1행 1열부터 차례로 판별하다 파란색을 만나면 바로 모든 반복문을 빠져나와 착륙할 수 있도록 한다. 만약 파란색을 찾지 못하면 'blue error'라는 문자열을 출력 후 바로 착륙하도록 한다. 또한 나눠둔 section 1,2,3 이외에 다른 section이 돼도 'section error'라는 문자열 출력 후 바로 착지 할 수 있도록 한다.
```c
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
        disp("Section Error!!")
        break;
    end
    clear('frame');
end
land(crong);
```
* 드론 착륙 후 cam과 드론을 clear시켜주면서 마무리 한다.
```c
clear crong;
clear cam;
end
```
