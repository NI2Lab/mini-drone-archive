#  드론 투척병
2023 미니드론 경진대회

Tello 미니드론이 장애물을 피하고 표식을 인식하여 동작하도록 하는 프로그램입니다.

#
## Feature

모든 코드는 MATLAB으로 만들어졌으며, 다음의 Toolbox들을 사용합니다.
 - Image Processing Toolbox
 - Ryze Tello Drone Support from MATLAB

## Strategy

드론의 카메라를 이용해 색을 탐색하고 이를통해 장애물의 중심을 찾아서 드론의 위치를 조정합니다. 또한 색 탐색을 통해 표식을 인식하고 추출된 hsv 값에 따라 다음 드론의 행동을 결정합니다.

## Algorithms



### 링 통과 알고리즘

드론의 카메라를 통해 이미지를 받아와 HSV로 변환합니다. hue값을 기준으로 이미지에서 파란색 영역을 파악하여 장애물이 드론의 카메라의 중앙에 오도록 하고, 장애물 건너편의 표식이 보이기 시작하면 링의 위치를 파악하여 드론을 이동시킵니다.


### 표식 인식 알고리즘

이미지의 hue값을 기준으로 이미지에 가장 많이 포함된 색상(빨강, 초록, 보라)를 알아냅니다. 이후 표식에 해당하는 명령을 수행합니다.


### 적정 각도 회전 알고리즘

드론이 초록 표식을 만나게 되면 현재 각도로부터 30도에서 60도에 위치한 다음 목표를 찾습니다. 우선 45도만큼 회전한 후 카메라의 중심에서 목표가 떨어진 만큼 회전하여 드론이 다음 목표를 향하도록 합니다.

## Functions

드론 비행과 이미지 처리에 사용된 함수들

### findcenter(cameraObj,hue)

```
function center=findcenter(cameraObj,hue)
```

camera object와 표식의 색깔에 해당하는 hue를 입력받아서, 카메라의 이미지에서 장애물을 찾아 해당 장애물의 중심좌표를 출력합니다.


### aligncenter(droneObj,cameraObj,hue)

```
function aligncenter(droneObj,cameraObj,hue)
```

```findcenter()``` 함수를 호출하여 장애물의 중심좌표를 받아와서, 드론이 장애물의 중심과 일직선 상에 놓이도록 드론을 움직입니다.


### getcolorsum(hsv,hue)
```
function s = getcolorsum(hsv,hue)
```
HSV 이미지에서 주어진 hue ± 0.04 범위의 색이 포함된 픽셀의 수를 반환합니다.



### trunbycolor(droneObj, cameraObj)
```
function trunbycolor(droneObj, cameraObj)
```
```getcolorsum()``` 함수를 통해 이미지에서 가장 많이 포함된 색깔에 해당하는 명령을 실행합니다.


### alignangle(droneObj,cameraObj)
```
function alignangle(droneObj,cameraObj)
```
드론이 시계방향으로 30도에서 60도 범위 내에 있는 장애물을 찾아 정면을 향하도록 회전합니다.


