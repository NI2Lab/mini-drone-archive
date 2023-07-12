# 2023 미니드론 대회 본선 - ARRF  
---
## Requirements  
* Image Processing Toolbox     
* MATLAB Support Package for Ryze Tello Drones   
#

#### 1. 대회 진행 전략

<img width="80%" src="https://github.com/HyeonjeongHeo0422/mini_drone_competition/assets/113971055/fb5991b0-f775-4148-82df-89db5bb5d0f5">

* ##### Step 1,2 : 통과해야 하는 원의 지름은 큰 반면, 제한 시간이 40초이기 때문에 정밀하게 원의 중심을 찾기보다는 빠른 시간에 원을 통과하는 것에 집중  
* ##### Step 3 :  정밀하게 원의 중심을 찾기 위해 두 번에 걸쳐 원의 중심을 찾아 이동
* ##### Step 4 :  보라색 마커로부터 2m 떨어진 거리에 착륙하기 위해 image의 보라색 픽셀 수를 체크하는 방식을 사용
#

#### 2. 단계별 세부 진행 전략
#### [Step 1,2] 
링이 상하좌우로 이동하기 때문에 처음 이륙시 카메라의 한정된 화각으로 인해 이미지에 링의 일부만 보여 원의 중심을 찾기 어렵거나 잘못된 위치 정보를 얻게 될 수 있습니다.
-> 이륙 시 후진 및 고도 상승 후 원의 중심을 찾는 알고리즘을 동작시킵니다.
-> 잘못된 정보를 얻는 경우(얻은 좌표 주변에 파란색이 감지되는 경우) 후진하여 원의 중심을 찾는 과정을 반복합니다.
아래 그림은 원의 중심 좌표를 찾은 예시입니다. 빨간색 '+' 마커가 원의 중심 좌표를 나타냅니다.

<img width="80%" src="https://github.com/HyeonjeongHeo0422/mini_drone_competition/assets/113971055/66c9d790-d96f-4429-b9e2-f0bb30c91de8">

상하좌우 이동 거리는 카메라 화각을 이용하였습니다. 다만, 정확한 depth 값을 모르기 때문에 오차가 있습니다.
TELLO의 화각은 82.6도로, 아래의 방법을 이용하여 이동 거리를 계산하였습니다. (TELLO 사양 : https://www.ryzerobotics.com/kr/tello/specs)

<img width="80%" src="https://github.com/HyeonjeongHeo0422/mini_drone_competition/assets/113971055/9ca3f2cb-88f5-4a41-abbf-7ba0e3d598df">

#### [Step 3] 
정밀하게 원의 중심을 찾기 위해 Step 1,2의 원의 중심을 찾는 과정을 두 번 반복하였습니다.

#### [Step 4] 
보라색 마커로부터 2m 떨어진 곳에 착륙하는 것이 목적이기 때문에 2m의 거리를 측정하기 위해 image의 보라색 픽셀 수를 체크하는 방식을 사용하였습니다.
줄자로 실제 드론과 보라색 마커 사이의 거리가 2m가 되도록 하여 pixel 수를 계산하여 코드에 반영하였습니다. 다만 이 또한 환경에 따라 보라색으로 인지된 픽셀의 개수가 다르기 때문에 오차가 있습니다.


