function [GreenCenterX,GreenCenterY,Novalue,centerD,centerU,centerR,centerL] = FindGreen(I,Round)

    % Case 1 : 일반적인 링의 외경과 내경이 검출되는 경우
    % Case 2 : 외경이 화면에 꽉 차는 경우 (ㅁ,ㄴ,ㄷ,ㄱ)
    % Case 3 : 외경 안에 내경이 존재하지 않는 경우 
    
    % 초기 선언 [Novalue=0 -> 링 검출 (Case1, Case2)]
    Novalue=0;
    %{
    channel1Min = 0.26;
    channel1Max = 0.38;
    channel2Min = 0.3;
    channel2Max = 1;
    channel3Min = 0.2;
    channel3Max = 1;
    %}
    channel1Min = 0.21;
    channel1Max = 0.38;
    channel2Min = 0.3;
    channel2Max = 1;
    channel3Min = 0.2;
    channel3Max = 1;
    % 이진화
    BWa = ( (I(:,:,1) >= channel1Min) & (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max); 

    BWb = medfilt2(BWa);  % 노이즈 제거를 위한 블러 적용 
    
    % 원본에 대한 영상처리 
    BW = bwlabel(BWb, 8);   % 라벨링 및 외경에 대한 정보 획득
    stats = regionprops('Table',BW, 'BoundingBox','Area');
    stats=table2array(stats);
    sizeb=size(stats);
    sizeb=sizeb(1);
    OutMaxArray=stats(1:sizeb)';
    [maxvalue,maxPosition]=max(OutMaxArray);
    if isempty(maxvalue)
        Novalue=1;
        GreenCenterX=0;
        GreenCenterY=0;
        % y축 중심 360을 기준으로 -120 (240), 범위 40
        centerD=280+(Round*15);
        centerU=200-(Round*15);
        % x축 중심 480을 기준으로 범위 100
        centerR=580+(Round*5);
        centerL=380-(Round*5);       
    else        
    OutR=stats(maxPosition,2)+stats(maxPosition,4)-0.5;
    OutL=stats(maxPosition,2)-0.5;
    OutD=stats(maxPosition,3)+stats(maxPosition,5)-0.5;
    OutU=stats(maxPosition,3)-0.5;    
    % 원본의 반전 된 이미지에 대한 영상처리
    BWIb= imcomplement(BWb);    
    BIW = bwlabel(BWIb, 8);    
    Istats = regionprops('Table',BIW, 'BoundingBox','Area');
    Istats=table2array(Istats);
    sizel=size(Istats);
    size2=sizel(1);
    InMaxValueArray=Istats(1:size2)';   
    
    % 노이즈 제거를 위해 픽셀의 크기가 500 이상의 물체 검출
    UnNoizeArray=[];
    k=1;
    for i=1:size2 
        if InMaxValueArray(i,1)>500
            UnNoizeArray(k,1)=Istats(i,2);
            UnNoizeArray(k,2)=Istats(i,3);
            UnNoizeArray(k,3)=Istats(i,4);
            UnNoizeArray(k,4)=Istats(i,5);
            k=k+1;
        end    
    end
  
     % 링의 외경이 화면에 접할때 
    if ((OutL==0)&&(OutR==960))&&((OutU==0)&&(OutD==720))
      [InMaxValue, po]=max(InMaxValueArray);
          if (isempty(InMaxValue)) % Case 3_1 : 화면에 외경이 접한 경우 중 모두 초록색인 경우
              Novalue=2;
              GreenCenterX=0;
              GreenCenterY=0;
              % y축 중심 360을 기준으로 -120 (240), 범위 40
              centerD=280+(Round*5);
              centerU=200-(Round*5);
              % x축 중심 480을 기준으로 범위 100
              centerR=580+(Round*5);
              centerL=380-(Round*5);
          else % Case 2 : 링의 외경이 ㅁ,ㄷ,ㄴ.ㄱ의 형태로 접할때
            UnNoizeArray(1)=Istats(po(1),2);
            UnNoizeArray(2)=Istats(po(1),3);
            UnNoizeArray(3)=Istats(po(1),4);
            UnNoizeArray(4)=Istats(po(1),5);
            testR=UnNoizeArray(1)+UnNoizeArray(3)-0.5;
            testL=UnNoizeArray(1)-0.5;
            testD=UnNoizeArray(2)+UnNoizeArray(4)-0.5;
            testU=UnNoizeArray(2)-0.5;
            GreenCenterX=(testR+testL)/2;
            GreenCenterY=(testU+testD)/2;
            centerD=(260+(testD-testU)/6)+Round*7;
            centerU=(260-(testD-testU)/6)-Round*8;
            centerR=(480+(testR-testL)/6)+Round*5;
            centerL=(480-(testR-testL)/6)-Round*5;
            Novalue=0;            
          end      
    else % Case 1 : 일반적인 링의 외경과 내경이 검출되는 경우   
        i=1;
        UnNoizeArraysize=size(UnNoizeArray);
        UnNoizeArraysize=UnNoizeArraysize(1);
        % 검출된 모든 사각형중 모든점이 외경안에 드는 사각형을 찾는다.
        while i<UnNoizeArraysize+1
                testR=UnNoizeArray(i,1)+UnNoizeArray(i,3)-0.5;
                testL=UnNoizeArray(i,1)-0.5;
                testD=UnNoizeArray(i,2)+UnNoizeArray(i,4)-0.5;
                testU=UnNoizeArray(i,2)-0.5;
                % Case 1 : 일반적인 링의 외경과 내경이 검출되는 경우 
                if (((OutL<=testR)&&(testR<=OutR)) && ((OutL<=testL)&&(testL<=OutR)))&&...
                        (((OutU<=testD)&&(testD<=OutD)) && ((OutU<=testU)&&(testU<=OutD)))
                    GreenCenterX=(testR+testL)/2;
                    GreenCenterY=(testU+testD)/2;
                    centerD=(260+(testD-testU)/6)+Round*5;
                    centerU=(260-(testD-testU)/6)-Round*5;
                    centerR=(480+(testR-testL)/6)+Round*5;
                    centerL=(480-(testR-testL)/6)-Round*5;
                    Novalue=0;                 
                    break
                else
                    Novalue=2;
                    GreenCenterX=0;
                    GreenCenterY=0;
                    % y축 중심 360을 기준으로 -120 (240), 범위 40
                    centerD=280+(Round*5);
                    centerU=200-(Round*5);
                    % x축 중심 480을 기준으로 범위 100
                    centerR=580+(Round*5);
                    centerL=380-(Round*5);
                end
                i=i+1;
        end 
    end
    end
end