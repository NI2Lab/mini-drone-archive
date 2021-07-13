# DrongDrong_team (A리그)
## 1. 대회 진행 전략
- **회귀분석**을 사용해 만든 함수로 *장애물과 드론 사이의 거리 판별 가능*
  - 회귀분석 방법:
    1. 거리에 따른 장애물 원의 지름 픽셀 수 측정
    2. x = '원의 지름 픽셀 수', y = '거리'로 두고 matlab을 이용하여 회귀분석 실행
    3. 1차~5차 함수일 경우의 계수 각각 계산
    4. 전체 다 plot하고 결정계수를 얻어내어 결정계수가 1에 가장 가까운 함수를 찾음
    5. 원의 지름 픽셀수로 드론과 원 사이의 거리 계산 함수 얻음
  - 회귀분석 결과(1~5차 함수의 형태):
    1. 1차(장애물의 지름이 78cm)
    ![이미지1](https://postfiles.pstatic.net/MjAyMTA3MTJfMzAg/MDAxNjI2MDkyMTEwNzUx.UlVScx3Gp9yX6-1n4JZhzx-VLBMjCoLOR3WXfx0Mxzcg.HFwDizavejkLOyhTAuEng-3Vo_fa4pvdkHUXK98gwhMg.PNG.0403jiwon/%EA%B7%B8%EB%A6%BC3.png?type=w773 "회귀분석1")
    2. 2차(장애물의 지름이 57cm)
    ![이미지2](https://postfiles.pstatic.net/MjAyMTA3MTJfMjM0/MDAxNjI2MDkyMTIzNjIy.QEFZC68T3QU2PUGzgG2p0alXjCnmYMLD3SoJ-s54LuEg.TlnzYYVNHCuZsFFjVS5qTjaol85B5QZl_L0BDBmQTKog.PNG.0403jiwon/%EA%B7%B8%EB%A6%BC2.png?type=w773 "회귀분석2")
    3. 3차(장애물의 지름이 50cm)
    ![이미지3](https://postfiles.pstatic.net/MjAyMTA3MTJfMjQw/MDAxNjI2MDkyMTM2Mjc3.6eAt5kBb_LTMYBYnycSHuWqcuG7DtObmQXQi2iVxF9Eg.r0FpUgU_JRMSdkvgG121nXLtvLV_-26y4ZaANbiEcCsg.PNG.0403jiwon/%EA%B7%B8%EB%A6%BC1.png?type=w773 "회귀분석3")
 - 회귀분석결과, 5차 함수가 가장 적절하다고 판단하여 모든 거리 계산 함수를 5차 함수 식으로 입력

- **중심점 지령**을 정하고 이를 이용해 드론이 원의 중심을 향하게 제어
   - x = 480, y = 220정도로 정하여 드론이 중심을 향하게 제어
   - 장애물 원의 픽셀과 거리의 비 = 드론의 시야에서 픽셀의 x값 차이(현재 드론의 중심과 지령으로 정한값의 차이)와 이동해야하는 수평 거리의 비
   - 장애물 원의 픽셀과 거리의 비 = 드론의 시야에서 픽셀의 y값 차이와 이동해야하는 수직 거리의 비

- **Closed Loop**로 코드 제작
   - 중심점 지령을 정한 뒤, 지령으로 움직이게 코드 제작
   - 회귀분석 결과값을 기반으로 좌우/상하 이동거리 계산
   - 영상 속 원형 지름 픽셀을 이용하여 전진거리 계산


- ***최종목표: 상황에 따라 드론이 움직여야할 거리를 회귀분석 및 수식적인 방법으로 불필요한 이동과 연산을 줄임***



***
## 2. 알고리즘 설명
- block diagram

![block_diagram](https://postfiles.pstatic.net/MjAyMTA3MTNfMjEz/MDAxNjI2MTQzMDcyNzU3.AgSrn1jNgYADVPQOioNqa5qQggVxT297HjzBd9oNUgsg.BUfILU75PLD8RNq-BpqrXdvCqRJvHP2VH3QX6MkoSWQg.PNG.0403jiwon/block_diagram.png?type=w773)

*노란 박스->drone 동작제어, 파란 박스->제작한 함수 코드*
  1. take off후, 단계(1~3)를 설정. 
  2. 장애물의 색(`find_blue`), 경계, 중심의 원 인식.
  3. 원의 중심점 지령에 드론이 위치하도록 제어(`Diameter_chase`).
  4. 장애물 중심에 있는 원의 지름 픽셀 갯수(Diameter) 계산.
  5. 만약 Diameter이 없으면 경계선 추적(`line_chase`).
  6. centroid 결정 후, x 중심점과 y 중심점을 비교하여 좌우, 상하로 계산한 거리만큼 이동.
  7. x = 0, y = 0이면 Diameter을 이용하여 장애물과 드론 사이의 거리 계산(d), d > meter(단계별로 지정해준 값), (d-meter) > 0.2이면 d-meter만큼 전진(아니라면 d+add 만큼 전진, add = 장애물 통과후 추가로 이동할 거리. 약 0.4m).
  8. 단계를 거쳐 색깔점 앞까지 전진 후, 빨간색(level 1&2) 점 찾기(`find_red`). red의 픽셀 수 > 2000이 될 때 까지 0.2m씩 전진 후, turn(-90).<level 3는 보라색 점 찾기(`find_purple`). purple의 픽셀 수 > 2000이 될 때 까지 전진 후, land.>



***
## 3. 소스 코드 설명
- diameter_chase  
```matlab
[Diameter,Centroid] = diameter_chase(BWa,remove,max)
% BWa = 넣어줄 snapshot한 사진
% remove = 제거할 노이즈의 최대 지름 픽셀 갯수(지름이 'n'픽셀 이하면 제거)  %% remove = n
% max = 최대 지름 픽셀 수
```
   1. 지름의 픽셀 수의 최댓값과 최솟값의 평균값 계산(타원으로 인식하기 때문)
   2. n픽셀 이하인 지름들 제거
   3. 남은 지름 픽셀들 중 최솟값만 사용(그 이상의 나머지 지름은 노이즈로 취급)


- line_chase  
```matlab
[Boundary,Point] = line_chase(BWa,remove)
% BWa = 넣어줄 snapshot한 사진
% remove = 제거할 노이즈의 최대 픽셀 갯수  %% remove = n
```
   1. snapshot한 BWa의 경계선 추적
   2. 이어지는 픽셀의 수가 n픽셀 이하인 것을 노이즈로 판단하고 제거
   3. 노이즈가 제거된 사진의 중심점 계산


- find_color  
```matlab
color = find_color(cam,remove,min,max,s_value)
% cam = 드론의 카메라
% remove = 제거할 노이즈의 최대 픽셀 갯수
% min = 해당하는 색에서 h의 최솟값
% max = 해당하는 색에서 h의 최댓값   %% min~max: 해당 색의 h값 범위
% s_value = 해당하는 색의 s값
```
  1. snapshot한 사진의 rgb 데이터를 hsv데이터로 변환
  2. 특정 색에 대한 h, s값에 해당되는 부분만 추출
  3. 크기가 작은 객체들은 노이즈로 취급하고 제거
