function [haveCircle, center] = getCircle(img)
haveCircle = 0;

bimg = separateBlue(img);

shape = strel('disk',10); %대회 돌려보며 조정 필요할 듯 함
nnoiseimg = imopen(bimg, shape);
nnoiseimg = ~nnoiseimg;


[B,L] = bwboundaries(nnoiseimg,'noholes');

% 연결성분의 중심을 계산
% regionprops 함수는 중심을 구조체형 배열로 반환
stats = regionprops(L,'Area','Centroid');

roundness_threshold = 0.8; %원형률을 통해 원임을 파악. 타원 색출.
nMax_metric = 0.0;

for k = 1:length(B)
  boundary = B{k};
  
  % 인접요소 차분 계산
  delta_sq = diff(boundary).^2;
  % 둘레
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % 추적한 도형의 면적
  area = stats(k).Area;
  
  % 원형률 계산
  metric = 4*pi*area/perimeter^2;
  
  % display the results
  disp(metric);


  if metric > roundness_threshold
      haveCircle = 1;
      if metric > nMax_metric 
          center = stats(k).Centroid;
          center = [round(center(1)) round(center(2))];
          nMax_metric = metric;
%             aBestCircle = boundary; %예외처리로 못찾은 경우 처리하기
      end
  end
end

end