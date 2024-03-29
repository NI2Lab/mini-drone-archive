# Project_Tello
--------------------
2021 미니 드론 대회를 위한 공용 저장소


## 대회 진행 전략
1. 단순화된 코드로 수정이 용이하고 연산 시간을 최소화할 수 있는 방향으로 설계하고자 하였다.
2. image processing toolbox의 user guide에 기재된 내장 함수를 이용하여 코드를 간소화하였다.


## 알고리즘 설명
+ 원(=구멍)을 찾는 과정
  + metric=4 x pi x area/perimeter^2의 식으로 원형률을 판별하여 원이 드론 카메라에 잡히는지 확인한다.
  + 일정 기준값(threshold=0.9)을 원형의 기준으로 삼는다.
  + 만약 원형에 가까운 경우 반복문을 탈출하여 원의 중심을 찾는 순서로 이동한다.
  + 일정 원형률 이상을 만족시키지 못하는 경우, 상하좌우로 이동한 크로마키 천의 위치를 고려하여, 드론을 시계 방향으로 이동시키며 원을 다시 찾는다. 
+ 원의 중점 방향으로 드론을 이동시키는 과정
  + imfindcircles 함수를 이용하여 원의 중점을 찾고, 드론 카메라 영상의 중심과 비교하여 그 차이가 최대한 줄어들도록 드론을 이동하여 원의 중심과 일직선 상에 드론이 위치하도록 한다.
  
  
## 소스 코드 설명
1. 드론의 초기 설정과 변수 값을 지정한다.
2. 3단계로 진행하므로 3번의 반복문을 수행하고 크로마키 천의 앞뒤 이동만 있는 1단계와 상하좌우앞뒤 이동이 모두 있는 2,3단계로 나누어 원(구멍)을 찾는다.
3. 원을 인식하기에 앞서, 이미지를 찍고(snapshot), hsv 이미지로 변환 후 이진화(binarize)한 뒤, 원에 해당되는 영역을 1(=true)로 만든다.
4. 1단계의 경우, 이륙 후 바로 원의 중점을 찾고, 2단계의 경우, 이륙 후 원의 위치부터 찾은 후(알고리즘 설명의 "원을 찾는 과정 참조"), 원의 중점을 찾는다.
5. 원의 중점을 찾은 후 표식(붉은색,보라색 사각형 지시사항)을 향해 이동하고 지시 사항(회전, 착지)등을 이행한다.

+ 코드 각 줄에 대한 부가 설명은 소스 코드 주석 참조
