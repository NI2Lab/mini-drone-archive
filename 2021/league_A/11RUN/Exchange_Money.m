while 1
  %% 입력값
    prompt = "변환할 금액(원)을 입력해 주세요." ;
    won = input(prompt);
    if won == 0
        disp("중지되었습니다.")
        break
    elseif won < 0
        disp("자연수를 입력해 주세요.")
        continue
    end
  %% 각 화폐의 변환
    [Dollar_Array,Dcount] = Dollar_Change(won);    
    Dsz = size(Dollar_Array);
    [Euro_Array,Ucount] = Euro_Change(won);
    Usz = size(Euro_Array);
    [Yen_Array,Ecount] = Yen_Change(won);
    Esz = size(Yen_Array);
    [Yuan_Array,Ycount] = Yuan_Change(won);
    Ysz = size(Yuan_Array);
  %% 행렬 합치기    
    sz = [Dsz, Usz, Esz, Ysz];
    M = max(sz);
   %% 달러 행렬변환
    while 1
        if Dsz < M
            Dollar_Array = [Dollar_Array;""];
            Dsz = Dsz + 1 ;
        else
            break
        end
    end
    
    if Dcount == 0
         ans = "달러로 변환할 수 없습니다.";
         Dollar_Array = [Dollar_Array; ans];
    else
        ans = sprintf("총 %d 개의 화폐가 필요합니다", Dcount);
        Dollar_Array = [Dollar_Array; ans];
    end
    %% 유로 행렬변환
    while 1
        if Usz < M
            Euro_Array = [Euro_Array;""];
            Usz = Usz + 1 ;
        else
            break
        end
    end
    
    if Ucount == 0
         ans = "유로로 변환할 수 없습니다.";
         Euro_Array = [Euro_Array; ans];
    else
        ans = sprintf("총 %d 개의 화폐가 필요합니다", Ucount);
        Euro_Array = [Euro_Array; ans];
    end
    %% 엔 행렬변환
     while 1
        if Esz < M
            Yen_Array = [Yen_Array;""];
            Esz = Esz + 1 ;
        else
            break
        end
    end
    
    if Ecount == 0
         ans = "엔으로 변환할 수 없습니다.";
         Yen_Array = [Yen_Array; ans];
    else
        ans = sprintf("총 %d 개의 화폐가 필요합니다", Ecount);
        Yen_Array = [Yen_Array; ans];
    end
    
    
    %% 위안 행렬변환
     while 1
        if Ysz < M
            Yuan_Array = [Yuan_Array;""];
            Ysz = Ysz + 1;
        else
            break
        end
     end
     
    if Ycount == 0
         ans = "위안으로 변환할 수 없습니다.";
         Yuan_Array = [Yuan_Array; ans];
    else
        ans = sprintf("총 %d 개의 화폐가 필요합니다", Ycount);
        Yuan_Array = [Yuan_Array; ans];
    end
  
    %% 마무리
    Change_Array = [Dollar_Array, Euro_Array, Yen_Array, Yuan_Array];
    disp(Change_Array)
    
    
    disp("----중지하려면 0을 입력해 주세요----") 
end
