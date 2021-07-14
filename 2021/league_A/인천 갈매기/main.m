% 드론 초기 설정
clear;
d=ryze();
c=camera(d);
takeoff(d);

frameCenter=[480,360];  %드론이 보는 중점(화면의 중점)
circle_cnt=0; %원이 영상에 들어왔는지 확인할 때 사용되는 변수
cnt=0; %시계 방향으로 드론이 회전하며 원을 찾을 때 사용되는 변수 


for i=1:3 %3단계 과정 수행 
    
      % 원을 찾는 과정
      if i==1
        f=snapshot(c);  %f는 frame(이미지)
        hsv=rgb2hsv(f);

        h=hsv(:,:,1);
        s=hsv(:,:,2);
        v=hsv(:,:,3);

        bw=zeros(size(f,1),size(f,2));
        bw(~((0.55<h)&(0.8>h)&(0.8<s)&(1.0>=s)))=1; %파란색 천이 있는 부분만 0
        bw=bwareaopen(bw,30); %픽셀 수가 30개 미만인 경우 제거(이진 영상에서 크기가 작은 객체 제거)

      %영상 안에 원이 완전히 담겼는지 확인 
      elseif i==2||i==3
          
         while 1
            if cnt==1
                moveup(d,'distance',0.8);
            elseif cnt==2
                moveright(d,'distance',1.8);
            elseif cnt==3
                movedown(d,'distance',0.7);
            elseif cnt==4
                movedown(d,'distance',0.5);
            elseif cnt==5
                moveleft(d,'distance',1.8);
            elseif cnt==6
                moveleft(d,'distance',1.8);
            elseif cnt==7
                moveup(d,'distance',0.6);
            elseif cnt==8
                moveup(d,'distance',0.7);
            else
                moveright(d,'distance',1.8);
            end
            
            f=snapshot(c); 
            hsv=rgb2hsv(f);

            h=hsv(:,:,1);
            s=hsv(:,:,2);
            v=hsv(:,:,3);

            bw=zeros(size(f,1),size(f,2));
            bw(~((0.55<h)&(0.8>h)&(0.8<s)&(1.0>=s)))=1; %파란색 천이 있는 부분만 0
            bw=bwareaopen(bw,30); %픽셀 수가 30개 미만인 경우 제거(이진 영상에서 크기가 작은 객체 제거)
            [B,L]=bwboundaries(bw,'noholes'); %원의 외부 경계선 찾기, 'noholes'로 내부 윤곽선 찾는 것 방지 
          
            for j=1:length(B)
                boundary=B{j};
            end

            stats=regionprops(L,'Area','Centroid');
            threshold=0.90;

            for j=1:length(B)
                 boundary=B{j};
                 delta_square=diff(boundary).^2; 
                 perimeter=sum(sqrt(sum(delta_square,2)));
                 area(j).Area; 
                 metric=4*pi*area/perimeter^2;
                 if metric>threshold %원 모양을 갖춘 경우(threshold 이상) 반복문 탈출 
                     circle_cnt=circle_cnt+1;
                     break;
                 end
            end
            
            if circle_cnt~=0 %원이 영상 안에 완전히 들어오면 반복문 탈출하고 원의 중점 찾는 코드로 이동
                circle_cnt=0; 
                cnt=0; %다음 단계에서 동일하게 원을 찾는 flag이므로 초기화함
                break;
            else
                cnt=cnt+1; %원이 영상 안에 완전히 담기지 못한 경우 시계 방향으로 움직이며 찾음
                continue;
            end            
            
          end
          
      end
        
 
    %원의 중점 찾기
   [center,radi]=imfindcircles(bw,[30 360],'Sensitivity',0.9); 

    
    xcenter=center(1,1);
    ycenter=center(1,2);
       

    %원의 중점과 드론 카메라가 보는 영상의 중점을 일치시키기 위한 과정
     while 1
           if frameCenter(1,2)-ycenter<-30
               movedown(d,'distance',0.2);
           elseif frameCenter(1,2)-ycenter>30
               moveup(d,'distance',0.2);
           elseif frameCenter(1,1)-xcenter<-30
               moveright(d,'distance',0.2);
           elseif frameCenter(1,1)-xcenter>30
               moveleft(d,'distance',0.2);
           else
               moveforward(d,'distance',1,'speed',1);
               break;
           end
     end       
       
       
    % 표식 판별 및 지시 사항 수행
    while 1
        f=snapshot(c);  
        hsv=rgb2hsv(f);

        h=hsv(:,:,1);
        s=hsv(:,:,2);
        v=hsv(:,:,3);

        red=(0<=h)&(h<0.05)&(0.95<h)&(h<1)&(0.8<s)&(s<=1); 
        purple=(0.7<=h)&(0.83>h)&(0.65<s)&(0.75>s); 

       if sum(red,'all')>400
           pause(1);
           turn(d,deg2rad(-90));
           pause(1);
           moveforward(d,'distance',1,'speed',1);
           break;
       elseif sum(purple,'all')>400
           land(d);
       else
           moveforward(d,'distance',0.2); % 표식과 충분히 가까워질 때까지 전진 
       end

    end
end



