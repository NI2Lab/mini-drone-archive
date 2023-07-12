# 원천관 316호 기술 워크샵

해당 repository의 구현 관련 내용은 [Github](https://github.com/JinHeeuk/woncheonhall_316_drone)에 있습니다.

## Getting started

사용한 MATLAB 버전은 MATLAB R2022b이며, 아래 ToolBox를 사용하였습니다.
```
Control System Toolbox ver 10.12
Image Processing Toolbox ver 11.6
MATLAB Support for MinGW-w64 C/C++ Compiler ver 22.2.0
MATLAB Support for Package for Ryze Tello Drones ver 22.2.1
pdollar/edges ver 1.0.0.0
```

## Problem Solving Strategies (대회 진행 전략)

우리는 이번 대회를 수행하기에 앞서 다른 방식들에 차별적인 몇가지 전략을 설정하였고 이를 코드에 반영하였습니다. 이러한 전략은 대회 수행 과정에 있어서 다른 방식들에 비해 안정적이고, 좋은 성능을 낼 수 있었습니다.

### 범용적인 코드 작성
1에서 4단계가 각 단계별로 수행해야 하는 동작이 비슷하므로, 모든 단계를 범용적으로 수행할 수 있는 코드를 작성하였습니다. 우선 이번 대회의 기본이 되는 두가지 동작이 '링 통과'와 '표식 인식'이므로 두가지 기본 코드를 작성하였습니다.
  
|동작|코드|설명|
|----|-----|-----|
|링 통과|`detectCircle`|링을 인식하고, 이상적인 위치까지 이동하는 코드|
|표적 인식|`analyzePaper`|표적이 그려진 A4용지를 인식하고, A4용지의 색을 인식하는 코드|
  
이렇게 두가지 기본 코드를 작성하였고, 수차례 테스트를 진행하며 안정적이고, 좋은성능을 낼 수 있는 코드가 되었으며, Drone의 제어와 내장된 CAM의 SPAC에 관련된 데이터를 획득하였습니다. 이렇게 획득한 정보는 두번째 전략에서 사용하였습니다. 위의 기본코드들 각 단계별 조건에 맞게 수정을 진행하였으며, 코드는 아래와 같습니다.
  

|동작|코드|설명|
|----|-----|-----|
|지름이 78cm원 통과|`detectCircle78`|`detectCircle`을 기반으로 작성, 지름이 78cm인 링을 인식하고, 이상적인 위치까지 이동 후 통과|
|지름이 57cm원 통과|`detectCircle57`|`detectCircle`을 기반으로 작성, 지름이 57cm인 링을 인식하고, 이상적인 위치까지 이동 후 통과|
|지름이 50cm원 통과|`detectCircle50`|`detectCircle`을 기반으로 작성, 지름이 50cm인 링을 인식하고, 이상적인 위치까지 이동|
|4단계 표적 인식|`findPurple`&`lookforPurple`|`analyzePaper`를 기반으로 작성. 표적을 인식하고, 중점 좌표 출력|
|4단계 링 인식|`findCircle`|`detectCircle50`을 기반으로 작성. 링을 인식하고, 중점 좌표 출력|

이렇게 이번 대회에서 수행하여야 하는 동작 중 4단계 각도 정렬하는 `calibrationR`를 제외한 모든 코드를 기본 코드인 `detectCircle`과 `analyzePaper`를 기반으로 작성하였습니다. 이러한 과정을 통해서 코드의 복잡도를 낮추고, 이해도를 높일 수 있었으며, Error가 발생하였을 때 대처하기가 수월하며, 전체적인 코드의 구현에 걸리는 시간을 단축하여 코드의 완성도와 정확도를 높일 수 있는 결과를 가져 올 수 있었습니다.

### 수학적인 접근
Drone의 SPAC과 대회 환경의 주어진 변수를 Drone을 통해 획득한 data를 이용하여, 최적의 조건과 변수를 수학적으로 계산하였습니다.

![untitled](https://github.com/JinHeeuk/woncheonhall_316_drone/assets/123629921/de7a5e2b-3e10-41a6-ac2b-b0392eba1b5f)


a) 위의 사진은 100cm 거리의 지금 57cm짜리 원의 중점을 측정한 사진입니다. 해당 사진의 원의 중심점 좌표는 (484, 347)이고, 원의 반지름은 297입니다. 즉, 반지름인 28.5cm를 297픽셀로 인식한다는 것이며, 이를 역으로 계산해보면 드론은 1m거리에서 폭 92cm를 촬영할 수 있습니다. 이때 드론의 화각은 2 * arctan(0.46) = 2 * 0.4311 rad = 2 * 24.7° = 49.4° 으로 매우 좁은 것을 알 수 있습니다.

b) 드론의 위치를 수차례 수정해가며 원을 가장 잘 검출할 수 있는 위치를 찾았습니다. 위의 사진을 기준으로 이상적인 원의 중심은 (480,300) 에서 (480, 360) 이었습니다. 따라서 이상적인 원의 중심을 (480, 330)으로 설정하고 해당위치에 원의 중심이 위치하도록 드론의 높이를 수정하였습니다. 100cm 거리에서 실제 원점보다 30cm를 높이게 된다면 이상적인 원의 중심에 맞게 되었습니다. 해당 각도를 계산해보면 arctan(0.3) = 0.29rad = 16.7°가 나왔습니다.

따라서 드론의 시야각은 아래 이미지와 같은 결과가 나오게 되었습니다. 이 외에도 링의 상하좌우 변동에 따른 드론의 시야각을 통해 원 검출이 가능한 지점, 각도 보정에서 발생하는 오차 및 보라색 미 검출지역에 도달할 가능성과 대처방안, 원근법을 이용한 원 크기를 통해 계산한 거리정보등을 수학적으로 계산하였고, 이를 통해 안정적이고, 좋은 성능의 제어를 수행하는 코드를 작성하였습니다.

![image](https://github.com/JinHeeuk/woncheonhall_316_drone/assets/123629921/ae590229-dc14-4c98-a4da-c8b303846cb6)


### 최적의 이동거리 계산
위에서 구한 수학적인 접근을 이용하여 드론이 실제로 움직여야하는 최적 이동 거리를 한번에 계산하도록 구현하였습니다. 해당 구현은 `dronePosition` 함수 내에서 이루어집니다. 원래는 드론 이동에 관련된 구현을 이동이 필요한 방향으로 최소 제어 거리인 0.2m씩 움직이도록 구현하였습니다.

그러나 드론이 이동 및 안정화를 하고 snapshoot 촬영 후 이미지 처리를 해서 다음 명령을 출력하는 과정이 5s에서 10s 정도가 걸린다는 사실을 발견하였습니다. 이렇게 계속해서 수정 비행을 하게된다면 Cut-off Time을 지키기가 빠듯하였습니다. 그래서 앞선 '수학적인 접근' 과정에서 계산한 실제 거리와 픽셀에 관련된 수식을 구현하였고, 이를 바탕으로 드론이 1~2회 정도만 수정비행을 하도록 구현하였습니다.

![image](https://github.com/JinHeeuk/woncheonhall_316_drone/assets/123629921/a54bb3ac-a114-43c0-9e0d-f0180f04ad71)

위 사진과 같이 드론의 현재 중점(초록색 점)과 원의 중점 사이의 픽셀 차이를 계산하고, 이를 앞에서 구한 수식에 대입에 이동에 필요한 distance를 출력하면 해당 거리만큼만 이동하는 과정으로 드론을 제어하였습니다.

해당 방식을 사용하기 전에는 1단계 통과에 40에서 60초가 걸리던 과정이 15에서 20초 정도로 통과하게 되면서 뛰어난 수준의 성능개선을 이루어 내었습니다.

### 최적의 각도 계산

4단계의 경우에는 30에서 60도 사이에 위치한 노란색 표식에 착륙하는 단계입니다. 이 과정에서 보라색 표식 - 원의 중점 - 노란색 표식에 드론을 일자로 정렬하는 과정이 필요하였습니다. 해당 과정에서 아래와 같은 수학적 계산을 통해 이동에 필요한 각도와 거리를 계산하였습니다.

![image](https://github.com/JinHeeuk/woncheonhall_316_drone/assets/123629921/cadab0bb-8624-4eaf-a9a3-025b95ab20b4)

먼저 원의 중점과 보라색의 중점을 이미지에 표시합니다. 그리고 두 지점의 X값 차이만큼에 해당하는 반대편에 표시합니다. 위 계산에 따라 해당 지점에 드론의 중점이 위치한다면, 오차범위 내에서 보라색 표식 - 원의 중점 - 노란색 표식에 드론을 일자로 정렬할 수 있을 것이라는 계산결과가 나오게 되었습니다. 아래 이미지는 실제 드론에서 취득한 이미지입니다. 

![landing2jpg](https://github.com/JinHeeuk/woncheonhall_316_drone/assets/123629921/4873c422-faa0-4678-abe2-16df715f60fa)


## Algorithm Explain (알고리즘 설명)

### 지점 통과를 위한 위치 보정 알고리즘

원을 통과하기 위해서는, 우선 원의 중심과 드론의 위치를 정렬할 필요가 있습니다. 이를 위해서는 원의 중심을 인식하고 이에 맞춰 드론의 위치를 이동하는 알고리즘이 필수적입니다. 원의 중심과 그 반지름울 구하는 데 있어서는 전술한 `detectCircle` 함수를 사용하였습니다. 이 정보를 바탕으로 현재 위치를 계산하기 위해서는 추가적인 계산이 필요하며, 새로이 정의한 `dronePosition` 함수가 이 역할을 수행합니다.
  
`dronePosition`함수의 동작을 설명하기 위해서는 우선 해당 함수를 작성하는 데 있어 수립한 몇 가지 가정에 대한 이해가 필요합니다. 가정들은 다음과 같습니다.

>1. 드론의 현재 위치과 원의 중심점 사이의 거리를 측정할 때 있어, 두 점이 통과면의 법선 위에  있다고 가정하였습니다. 따라서 계산된 두 지점 사이의 유클리드 거리는 고저차, 좌우 거리를 반영하지 못합니다.
>2. 드론과 원 사이의 거리와 측정한 원의 반지름은 서로 반비례합니다. 이는 실험적 측정을 통한 근사치이며, 기준값과 멀어질수록 더 큰 오차가 발생하지만 드론을 제어하는 데 있어 충분히 유효함이 확인되었습니다.
>3. 카메라를 통해 측정한, 멀리 떨어진 두 지점의 픽셀거리는 실제 두 지점의 거리에 비례합니다. 즉, 각각의 지점과 드론 사이의 거리를 두 지점 사이 거리를 측정함에 있어 반영하지 않습니다.

  
`dronePosition`함수는 입력으로 원의 실제 직경, 측정한 원의 픽셀 반지름, 원의 중심 x, y 좌표를 받습니다. 우선 드론의 현재 위치와 원의 중심간의 거리를 파악하기 위해 가정 1을 사용합니다. 가정 1에 의해, 드론이 원을 마주보는 위치에 있다고 간주합니다.
  
우리는 실험을 통해 기준거리(1.5m)에서 원의 실제 반지름과 원의 픽셀 반지름 사이의 관계를 확인했습니다. 이 과정에서 가정 3이 사용됩니다. 결과 원의 실제 반지름(m) / 원의 픽셀 반지름(pix) 는 다양한 반지름의 원에서 측정했을 때 거의 일정한 값(상수)을 보였습니다. 따라서 측정한 원의 픽셀 반지름에 이 상수를 곱하면 원의 실제 반지름을 구할 수 있을 것입니다.
  
그러나 이는 원과 드론 사이의 거리가 기준거리(1.5m)에 있을 때만 유효합니다. 하지만 반대로 이미 원의 실제 직경을 알고 있는 상황에서, 위의 관계식과 가정 2을 이용한다면 원과 드론 사이의 거리를 역산할 수 있을 것입니다. 이를 위해 다음의 비례식이 사용됩니다 : 
  
원의 실제 반지름(m) : 1.5m 에서의 원의 픽셀 반지름(pix) = 1.5m / 원과 드론 사이의 거리(m) * 원의 실제 반지름(m) : 측정한 원의 픽셀 반지름(pix)
  
위의 관계를 통해 원과 드론 사이의 거리를 구했다면, 화면에서 보이는 1픽셀이 원 위에서 실제 몇 m를 의미하는 지 알 수 있습니다. 우리는 원의 중심과 드론의 진행방향(드론의 카메라가 아래를 보고 있으므로, 실제 구현에서는 [480, 300] 지점을 사용하였습니다)을 이미 알고 있으며, 두 차이 또한 계산할 수 있습니다. 남은 것은 향하고자 하는 기준점(원의 중심)과 현재 위치(드론의 진행방향) 사이의 픽셀 차이와 앞서 구한 비례상수를 곱하여 상하좌우로 보정해야 할 실제 거리를 구하는 것 뿐입니다.
  
### 표식지 검출 및 표식 색상 확인 알고리즘

원을 통과한 후 다음 동작으로 이행하기 위해서는 표식의 색상 확인이 필요합니다. 이 때, 주위 환경에 의한 오검출을 최소화하기 위해 색상을 검출하는 범위를 제한하였습니다. 이를 위해 가장 유효한 방법읜 표식이 출력된 종이를 우선 검출하는 것이라고 판단하였습니다. 이에 착안하여 작성한 알고리즘을 간단히 설명하자면, 전체 이미지에서 흰색 부분을 추출하고, 그 중 A4와 종횡비가 유사한 사각형 객체를 특정하여, 그 안에서 표식 색상 추출을 시도하는 방식입니다.
  
`whiteMasking` 함수는 입력된 이미지에서 '종이'에 해당하는 흰색 부분을 검출한 이진 이미지를 반환하는 함수입니다. 조명, 음영 등의 다양한 조건 하에서 시행착오를 통해 가장 유효한 마스킹 필터를 고안하였으며, 최종 `whiteMasking` 함수는 1. 픽셀의 RGB가 모두 특정 값 이상이고, 2. R, G, B 값이 서로 큰 차이가 없으며, 3. 세 값 중 B가 가장 클 때 해당 픽셀을 종이로 인식하고 픽셀의 논리값을 1로 반환합니다. 
  
상위 함수 `analyzePaper`는 Computer Vision Toolbox 에서 제공하는 함수인 `regionprops`를 사용하여 `whiteMasking`의 결과로부터 사각형을 검출합니다. 이 때 검출되는 다양한 사각형들 중 '유효한' 사각형을 필터링하는데, 이 때 사각형의 픽셀 크기, 중앙과의 상대 위치를 종합적으로 고려하여 가장 유력한 몇 개의 객체만을 남깁니다.
  
유력한 객체들만이 남았다면 각각의 내부에서 색상을 검출합니다. 흰색 픽셀 대비 적색, 녹색, 자색 픽셀의 비율을 각각 계산하여, 가장 큰 비율값이 존재하는 객체의 색상값을 결과로 반환합니다.
  
가능성은 낮지만, 이 과정에서 단 하나의 유효한 객체도 검출하지 못했다면 범위를 넓혀 이미지 전체에서 각각의 색상에 해당하는 픽셀을 추출합니다. 이 중 가장 큰 비중을 차지하는 색상을 결과로 반환합니다. 주변 환경이 색상 검출 결과에 영향을 미칠 가능성이 존재하게 되지만, 완전 검출 실패로 이어지는 경우를 최소화하기 위한 보완 방책입니다.

### 표식의 중점을 파악하는 알고리즘

마지막 단계에서 정확한 착륙 지점을 찾기 위해, 원의 중점과 보라색 표식의 중점이 같은 y축상에 있도록 두 중점의 x값을 일치시켜야 합니다. 이를 위해서는 보라색 표식의 중점을 찾는 알고리즘이 필요합니다. 여기서 앞선 표식지 검출 알고리즘과 같이 `regionprops` 함수를 사용하여 사각형을 검출하고, 그 사각형의 네 꼭지점의 평균을 구하는 방식으로 보라색 표식의 중심을 파악하였습니다.

## Code (소스 코드 설명)

### detectCircles
원 크기와 목적에 따라서 detectCircles78, detectCircles57, detectCircles50, findCircle 로 코드를 일부 수정하였습니다.
```
function pass = detectCircles78(frame, droneObj)
    % 기본 변수
    variable = 4;
    radiiRange = [100 1000];
    sensitivityValue = 0.96;

    hueMean = 0.6170;
    hueVariance = 5.1249e-04;
    saturationMean = 0.2507;
    saturationVariance = 0.0020;

    image = frame;
    hsvImage = rgb2hsv(image);

    hueRange = [hueMean - variable * sqrt(hueVariance), hueMean + variable * sqrt(hueVariance)];
    saturationRange = [saturationMean - variable * sqrt(saturationVariance), saturationMean + variable * sqrt(saturationVariance)];
    hueMask = (hsvImage(:,:,1) >= hueRange(1)) & (hsvImage(:,:,1) <= hueRange(2));
    saturationMask = (hsvImage(:,:,2) >= saturationRange(1)) & (hsvImage(:,:,2) <= saturationRange(2));

    outputImage = zeros(size(image));
    outputImage(hueMask & saturationMask) = 255;
    grayImage = rgb2gray(outputImage);
```
위의 코드는 크로마키의 파란색 부분만 crop해서 측정한 hueMean, hueVariance, saturationMean, saturationVariance으로 mask를 생성하는 코드입니다. 먼저 파란색 부분만을 드론으로 촬영 후 HSV로 바꾼후 hueMean, hueVariance, saturationMean, saturationVariance을 구하였습니다. Empirical Rule은 양쪽으로 3시그마에 해당하는 부분은 약 99.7%의 범위에 속한다는 정리입니다. 그러나 hue와 saturation이 정규 분포를 따르지는 않는데, 중심극한정리(central limit theorem, CLT)에 따라 n이 크다면 정규 분포에 가까워지게 됩니다.

하지만 3시그마로 범위를 구하니 잘 mask 검출이 되지 않았습니다. 그 이유는 파란색 부분만 crop한 이미지의 색상이 비슷해 standard deviation이 작기 때문으로 판단하여 4시그마 범위로 설정하였습니다.

```
    blurred_image = imgaussfilt(grayImage, 5); 
    edges = edge(blurred_image, 'Canny');
    imshow(edges);
```
mask를 구한후 해당 이미지를 gaussian filter를 처리하였습니다. Canny edge를 처리하기전에 노이즈 제거 차원에서 gaussian filter를 처리하여 smooth 이미지를 취득하면 노이즈를 최소화 할 수 있습니다. 따라서 gaussian filter 처리후 canny edge를 구하였습니다.

```
    hold on;
    [centers, radii, ~] = imfindcircles(edges, radiiRange, 'Sensitivity', sensitivityValue);
    pass = 0;
```
이후에 infindcircles를 이용해 원을 검출하였습니다. 수차례 테스트를 진행한 결과 Sensitivity를 0.96으로 설정하였을때가 가장 잘 검출되었습니다. Sensitivity를 너무 키우면 너무 많은 원이 검출되고, 너무 낮추면 원의 일부가 잘리는 경우에는 원을 제대로 검출하지 못하였습니다. 해당 값은 촬영한 이미지의 노이즈를 분석후 변동할 수 있는 부분입니다.


```
    fprintf('원이 %f 개\n', size(centers, 1));
    if size(centers, 1) > 0
        [~, maxIndex] = max(radii);
        maxCenter = centers(maxIndex, :);
        maxRadius = radii(maxIndex);
        maxArea = pi * maxRadius * maxRadius;

        viscircles(maxCenter, maxRadius, 'EdgeColor', 'b');
        fprintf('최대 원의 중심점 X = %f, Y = %f, 반지름 = %f\n', maxCenter(1), maxCenter(2), maxRadius);
        plot(maxCenter(1), maxCenter(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        % fprintf('최대 원의 넓이 = %f\n', maxArea);
        % fprintf('최대 원의 거리 = %f\n', maxDistance);

        xcenter = maxCenter(1);
        ycenter = maxCenter(2);
        radii = maxRadius;
```
infindcircles로 원을 검출하면 경우에 따라 원이 1개 이상 검출되는 일이 발생하기도 합니다. 이러한 경우에는 원의 넓이가 가장 큰 원을 검출하도록 작성하였습니다. 이 과정에서 원으로 부터 거리를 측정하기 위해서 반지름(Radius) 정보도 사용하여 원과의 거리를 검출하는데 사용하였습니다.


```
        circleDiameter = 78;
        [xpos, ypos] = dronePosition(circleDiameter, radii, xcenter, ycenter);

        if xpos > 0
            moveright(droneObj, distance = xpos)
        elseif xpos < 0
            moveleft(droneObj, distance = -xpos)
        else
            fprintf('X 오차 없음 ');
        end
        if ypos > 0
            movedown(droneObj, distance = ypos)
        elseif ypos < 0
            moveup(droneObj, distance = -ypos)
        else
            fprintf('Y 오차 없음\n');
        end
```
infindcircles로 검출한 원의 중점과 반지름을 이용해서 dronePosition 함수를 통해 필요한 이동거리를 출력하고 실제 이동을 수행하는 과정입니다. dronePosition에 관한 설명은 뒷 부분에 작성되어 있습니다.

```
        if  maxArea < 100000
            moveforward(droneObj, 'Distance', 0.4);
        elseif (maxArea >= 100000) && (maxArea < 140000)
            pass = 1;
            fprintf('중앙 인식 step 1,2(so far)\n');
            movedown(droneObj, distance = 0.3);
            moveforward(droneObj, 'Distance', 2.5);
        elseif (maxArea >= 140000) && (maxArea < 170000)
            pass = 1;
            fprintf('중앙 인식 step 1,2(far)\n');
            movedown(droneObj, distance = 0.3);
            moveforward(droneObj, 'Distance', 2.3);
        else
            pass = 1;
            fprintf('중앙 인식 step 1,2(near)\n');
            movedown(droneObj, distance = 0.2);
            moveforward(droneObj, 'Distance', 2.1);
        end
```
원과 드론 사이의 거리를 Area로 확인하였습니다. 78cm의 원에서는 10만 보다 작은 경우에는 2.4m 보다 먼 거리에 있다고 판단하여, 0.4m를 전진한 후 재 검출을 하도록 작성하였습니다. 14만 보다 작은 경우에는 드론이 2m 정도의 거리에 위치해 있다고 가정하여 2.5m를 전진하도록 구현하였으며, 나머지 넓이 역시 드론을 통해 촬영하고 측정한 데이터를 기반으로 이동거리를 계산하여 원을 통과하도록 구현하였습니다.

드론이 원을 검출하는 이상적인 위치가 실제 원점보다 30cm 정도 위의 위치이므로 원 통과 과정에서는 안정적으로 통과하게 하기위해서 20~30cm 정도를 낮춰서 실제 원의 중심으로 통과하게 하였으며, 원을 통과하면 pass를 1로 설정하였습니다.

```
    else
        moveup(droneObj, 'Distance', 0.3);
        moveback(droneObj, 'Distance', 0.6);
    end
end
```
만일 원을 검출하지 못한다면 드론을 30cm 띄우고, 60cm를 뒤로가도록 구현하였습니다. 이는 드론의 시야각과 링의 상하 좌우 이동을 수학적으로 계산하였을때, 최적의 이동 위치로 판단하고 이동하도록 구현하였습니다.

나머지 detectCircles57, detectCircles50 함수 역시 이와 동일하며 findCircle 함수는 드론의 제어 부분을 제거하고, 원의 중점을 출력하도록 구현하였습니다.

### calibrationR
calibrationR 함수는 4단계 통과를 위해서 보라색 표식 - 원의 중점 - 노란색 표식을 일자로 각도 보정하는 과정입니다. 해당 코드의 수학적 계산에 대한 설명은 위해서 작성하였으므로, 코드에 대한 설명만 작성하였습니다.
```
function sw = calibrationR(frame, xc, yc, xp, yp, droneObj)
    image = frame;
    imshow(image);
    hold on;
    plot(xc, yc, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    plot(xp, yp, 'b+', 'MarkerSize', 10, 'LineWidth', 2);
```
xc, yc는 findcircle에서 출력한 원의 중점에 대한 좌표이며, xp, yp는 findpurple에서 출력한 보라색 표식의 중점에 대한 좌표입니다.

```
    xi = xp + (xp - xc);
    x_distance = xi - xc;
    xline(xi, 'g', LineWidth=2);
```
앞서 설명한 바와같이 원의 중점의 x좌표와 보라색 중점의 x좌표의 차이를 계산하였습니다. 그리고 해당 차이에 해당하는 반대 부분에 선을 그어주는 부분입니다.

```
    theta = fix(x_distance/16.7); %16.7은 변수
```
계산한 각도 차이를 가지고 실제 이동 각도를 계산하는 부분입니다. 16.7은 드론이 촬영한 이미지 (H*W)에서 W와 드론의 시야각을 나누어 구한 값입니다.

```
    if abs(theta) > 5
        turn(droneObj, deg2rad(theta))
        if theta > 0
            moveleft(droneObj, distance = 0.2)
        else
            moveright(droneObj, distance = 0.2)
        end
        sw = 4;
```
이렇게 구한 theta가 5도보다 클 경우에는 드론이 각도 보정을 수행하도록 구현하였습니다. 이후에는 sw=4로 변경하여 다시 detectCircles50을 수행해 제대로된 곳에 위치한 것인지 검증하도록 구현하였습니다.

![image](https://github.com/JinHeeuk/woncheonhall_316_drone/assets/123629921/23d65fe3-3ab6-4f22-b94f-e1504dda5ae8)

```
    else
        sw = 9;
    end
end
```
theta가 5도 보다 작을 경우에는 sw=9로 설정하여 while루프를 벗어나 착륙을 수행하도록 구현하였습니다.


### analyzePaper
알고리즘 설명 부분에서 언급한, 표식지 탐색과 표식 색상 검출 기능을 구현하는 함수 `analyzePaper`입니다.
  
마스킹 구현에 있어 RGB format과 HSV format의 이미지를 동시에 사용하였습니다. 흰색을 검출하는 데 있어서는 RGB 이미지 처리가 비교적 용이하고, 색상 검출에 있어서는 HSV 이미지가 더 유리하다고 판단하였기 때문입니다. 그 이유에 대해서는 `whiteMasking` 함수 설명에서 더 상세하게 다루도록 합니다. 아래 코드는 함수의 시작과 함께, 드론이 찍은 프레임을 HSV 색공간으로 변환하는 과정을 명시합니다.
```
function result = analyzePaper(frame)
% 흰 종이를 감지하여 그 안의 색을 읽는다.
%   자세한 설명 위치
    result = 0;
    
    % 프레임을 HSV 색 공간으로 변환
    frame_hsv = rgb2hsv(frame);
```
다음은 프레임으로부터 흰색 이미지를 얻는 과정입니다. 함수 `whiteMasking`은 프레임을 RGB format으로 읽어, 그 중에서 흰색(정확히는 종이)에 해당하는 영역의 정보를 담은 이진 이미지를 반환합니다.
```
    binImage = whiteMasking(frame);
```
반환받은 이진 이미지로부터 사각형 성분을 검출합니다. `bwconncomp` 함수는 이진 이미지에서 연결된 성분(Connected Components)를 탐지하고 이 정보를 반환하는 Image Processing Toolbox 라이브러리 함수입니다. 바로 이어서 `regionprops` 함수를 이용해 이 성분들의 사각형 boundary와 중점을 추출합니다.
```    
    %흰색 검출 이미지에서 사각형을 탐색
    cc = bwconncomp(binImage);
    regions = regionprops(cc, 'BoundingBox', 'Centroid');
```
결과 실제 표식지에 해당하는 성분은 물론, 여러가지 Noise 또한 검출될 가능성이 있습니다. 따라서 이 성분들 중 유효한 성분만을 검출할 필요가 있습니다. 변수 `validRegions`는 추출한 성분 `regions` 중 1. 그 픽셀 크기가 기준 이상일 것이며,  2. 객체의 중심이 중앙에 충분히 가까운 객체를 선정한 것입니다. 이 객체는 잠재적으로 '유효한' 성분으로 간주합니다. 아래 코드는 모든 객체에 이 필터링을 적용하고, 결과를 plot하기까지의 과정을 나타냅니다.
```
    %검출 결과를 plot
    imshow(binImage)
    hold on
    validRegions = [];
    for i = 1 : numel(regions)
        if (regions(i).BoundingBox(3) * regions(i).BoundingBox(4) >= 2000) && ...                       %객체의 최소 크기를 만족하고
                (norm([(480 - regions(i).Centroid(1)), (360 -regions(i).Centroid(2))]) <= 480)   %객체의 중심이 중앙에 충분히 가까우면 Valid
            validRegions = [validRegions, regions(i)];
        end
    end
    
    for i = 1 : numel(validRegions)
        viscircles([480 360], 480, 'Color' ,'b', 'LineWidth', 1);
        rectangle('Position', validRegions(i).BoundingBox, 'EdgeColor' ,'y', 'LineWidth', 2);
        plot(validRegions(i).Centroid(1), validRegions(i).Centroid(2), 'y+', 'MarkerSize', 10);
    end
```
이제 앞서 구한 유효한 표식지들로부터 색상을 검출해야 합니다. 색상 검출에는 HSV 색공간이 활용되며, 다음은 실험적으로 추출한 적색, 녹색, 자색의 HSV 값과 그 샘플링 분산을 나타냅니다.
```
        % RED mask
        red_hue_mean = 0.035006836738102;
        red_hue_variance = 8.451444823239685e-04;
        red_saturation_mean = 0.801194701249392;
        red_saturation_variance = 8.123921822952889e-04;
        
        % GREEN mask
        green_hue_mean = 0.393943679607893;
        green_hue_variance = 4.467153016099294e-05;
        green_saturation_mean = 0.449360673941893;
        green_saturation_variance = 3.579265733187384e-04;
        
        % PURPLE mask
        purple_hue_mean = 0.724754819881663;
        purple_hue_variance = 8.608107141373810e-05;
        purple_saturation_mean = 0.496633620639431;
        purple_saturation_variance = 0.003079431542493;
```
이 값들은 다음과 같은 과정을 통해 추출하였습니다.
> 1. 실제 표식지를 드론 카메라를 통해 인식하여 프레임을 얻는다.
> 2. 프레임으로부터 표식(색상)에 해당하는 부분만을 추출한다.
> 3. 이 부분을 HSV 색공간으로 변환한다.
> 4. 변환된 공간의 모든 픽셀로부터 H, S의 평균 및 분산을 획득한다. `norm` 함수와 `mean` 함수를 이용한다.
음영의 영향을 반영하기 위하여, Value(명도)는 색상 추출 시 고려하지 않았습니다.
  
유효한 표식지가 '있을 법 한' 모든 영역에 해당하는 프레임 부분을 잘라냅니다. `imcrop` 함수를 사용하였으며, 결과 반환된 프레임을 HSV 색공간으로 변환하고 범위에 맞는 픽셀을 추출합니다. 범위는 표준분포상 평균으로부터 6 * 표준편차 만큼 떨어진 색상까지로 제한하였습니다.
```    
    %모든 유효한 영역에서 이미지를 검출
    for i = 1 : numel(validRegions)
        croppedFrame = imcrop(frame, [validRegions(i).BoundingBox(1), validRegions(i).BoundingBox(2) ...
            validRegions(i).BoundingBox(3) , validRegions(i).BoundingBox(4)]);
        % 잘려진 프레임을 HSV 색 공간으로 변환
        cr_frame_hsv = rgb2hsv(croppedFrame);
        % 잘려진 프레임의 도형 색상 분류 (HSV 색 공간)
        cr_hue = cr_frame_hsv(:, :, 1);
        cr_saturation = cr_frame_hsv(:, :, 2);
        variable = 6;

        % 흰색 영역 검출
        cr_white_mask = whiteMasking(croppedFrame);
        % 적색 영역 검출
        red_mask = (abs(cr_hue - red_hue_mean) <= variable * sqrt(red_hue_variance)) & ...
            (abs(cr_saturation - red_saturation_mean) <= variable * sqrt(red_saturation_variance));
        % 녹색 영역 검출
        green_mask = (abs(cr_hue - green_hue_mean) <= variable * sqrt(green_hue_variance)) & ...
            (abs(cr_saturation - green_saturation_mean) <= variable * sqrt(green_saturation_variance));
        % 자색 영역 검출
        purple_mask = (abs(cr_hue - purple_hue_mean) <= variable * sqrt(purple_hue_variance)) & ...
            (abs(cr_saturation - purple_saturation_mean) <= variable * sqrt(purple_saturation_variance));
```
이제 색상에 해당하는 픽셀의 개수와 종이(흰색)에 해당하는 픽셀의 개수를 파악하였으므로, 종이의 면적에 대한 색상의 면적을 구할 수 있습니다. 이 비율을 계산하여 2차원 행렬 probability에 저장합니다.
```     
        %각각의 색이 종이에서 차지하는 비율 검출
        red_probability = sum(red_mask(:)) / sum(cr_white_mask(:));
        green_probability = sum(green_mask(:)) / sum(cr_white_mask(:));
        purple_probability = sum(purple_mask(:)) / sum(cr_white_mask(:));
        
        probability(i, :) = [red_probability, green_probability, purple_probability];
    end
```
이제 모든 유효한 영역에서의 면적비가 계산되었습니다. 가장 큰 면적비를 갖는 객체가 색상지일 가능성이 제일 높으므로, 이를 추출하여 적색일 때는 1, 녹색일 때는 2, 자색일 때는 3을 반환합니다. 만약 유효한 영역이 없을 경우 return하지 않고 다음 단계로 넘어갑니다.
``` 
    if numel(validRegions) ~= 0
        if any(probability(:))
             [~, idx] = max(max(probability, [], 2));
             [~, result] = max(probability(idx, :));
             fprintf("총 %d개의 유효한 객체를 확인. 결과 : %d\n", numel(validRegions), result);
             if result == 1
                 rectangle('Position', validRegions(idx).BoundingBox, 'EdgeColor' ,'r', 'LineWidth', 2);
                 plot(validRegions(idx).Centroid(1), validRegions(idx).Centroid(2), 'r+', 'MarkerSize', 10);
             elseif result == 2
                 rectangle('Position', validRegions(idx).BoundingBox, 'EdgeColor' ,'g', 'LineWidth', 2);
                 plot(validRegions(idx).Centroid(1), validRegions(idx).Centroid(2), 'g+', 'MarkerSize', 10);
             else
                 rectangle('Position', validRegions(idx).BoundingBox, 'EdgeColor' ,'m', 'LineWidth', 2);
                 plot(validRegions(idx).Centroid(1), validRegions(idx).Centroid(2), 'm+', 'MarkerSize', 10);
             end
             hold off
             return;
        end
```
유효한 영역이 판별되지 않은 경우, 불가피하게 전체 frame에서 색상 인식을 시작합니다. 간단히 이전에 구한 마스크를 자르지 않고 전체 frame에 적용한 후, 가장 많은 픽셀을 차지하는 색상을 검출합니다. 디버깅을 위해 해당 프레임을 파일로 저장하는 기능도 포함되어 있습니다.
```
    else
        variable = 5;
        hue = frame_hsv(:, :, 1);
        saturation = frame_hsv(:, :, 2);
        red_mask = (abs(hue - red_hue_mean) <= variable * sqrt(red_hue_variance)) & ...
            (abs(saturation - red_saturation_mean) <= variable * sqrt(red_saturation_variance));
        green_mask = (abs(hue - green_hue_mean) <= variable * sqrt(green_hue_variance)) & ...
            (abs(saturation - green_saturation_mean) <= variable * sqrt(green_saturation_variance));
        purple_mask = (abs(hue - purple_hue_mean) <= variable * sqrt(purple_hue_variance)) & ...
            (abs(saturation - purple_saturation_mean) <= variable * sqrt(purple_saturation_variance));
        [~, result] = max([sum(red_mask(:)), sum(green_mask(:)), sum(purple_mask(:))]);
        fprintf("유효한 표식지를 탐색하지 못하였습니다. 모든 사진 영역에서의 색 검출을 시도합니다. 결과 : %d\n", result);
        imwrite(frame, 'error_mask.png');
        hold off
    end

end
```
  
### whiteMasking
RGB format 이미지로부터 흰색 픽셀을 추출하여 이진 이미지로 반환하는 함수입니다.
  
흰색은 다른 색상들과 달리 명도와 채도에 의해 결정됩니다. 여기에 HSV format을 적용할 경우 단순한 흰색 뿐 아니라 조명으로 인해 밝은 부분까지 검출하는 문제가 지속적으로 발생하였습니다. 따라서 조명과 종이를 구별하는 기준이 필요했습니다. 지속적인 측정 결과, RGB의 분포가 서로 너무 멀리 떨어지지 않으면서, 청색의 값이 높을 경우 종이일 가능성이 높다는 것을 파악하고 이를 Masking에 적용하였습니다. 해당 조건에 만족하는 픽셀의 값은 1, 그렇지 않은 픽셀은 0이 되어 출력의 format은 이진 이미지가 됩니다.
```
function result = whiteMasking(frame)
% 입력한 이미지(RGB)로부터 흰색 부분을 추출한 이미지를 출력하는 함수
%   자세한 설명 위치
    
   for i = 1 : size(frame, 1)
       for j = 1 : size(frame, 2)
           rgbPixel = [frame(i, j, 1), frame(i, j, 2), frame(i, j, 3)];
           if min(rgbPixel) >= 140 && ...                           %픽셀의 R, G B가 모두 140 이상이고
                   max(rgbPixel) - min(rgbPixel) <= 40 && ...   %그 범위가 40 이하이며
                   rgbPixel(3) > rgbPixel(1) && ...                  
                   rgbPixel(3) > rgbPixel(2)                            %B 값이 가장 클 경우
               result(i, j) = 1;
           else
               result(i, j) = 0;
           end
       end
   end
end
```

### findPurple
착륙 시 전체 frame으로부터 자색 표식을 찾아 그 중점을 반환하는 함수입니다. 착륙지점은 보라색 표식의 중점과 원의 중점이 정렬되는 지점에 위치하므로, 두 중점이 이미지 상에서 정렬되도록 제어하는 것이 중요하다. 그 전에는 우선 자색 표식을 확인하고 중점을 파악하는 것이 선행되어야 합니다.
  
`analyzePaper` 함수에서 사용한 HSV 색공간 Masking을 프레임 전체에서 진행합니다. 결과적으로 전체 프레임에서 보라색 부분만을 추출하게 됩니다.
```
function [found, xp, yp] = findPurple(frame)
    found = 0;
    xp = 0;
    yp = 0;

    %보라 사각형 검출
    hueMean = 0.724754819881663;
    hueVariance = 8.608107141373810e-05;
    saturationMean = 0.496633620639431;
    saturationVariance = 0.003079431542493;
    variable = 4;
    
    hsvImage = rgb2hsv(frame);
    hueRange = [hueMean - variable * sqrt(hueVariance), hueMean + variable * sqrt(hueVariance)];
    saturationRange = [saturationMean - variable * sqrt(saturationVariance), saturationMean + variable * sqrt(saturationVariance)];
    hueMask = (hsvImage(:,:,1) >= hueRange(1)) & (hsvImage(:,:,1) <= hueRange(2));
    saturationMask = (hsvImage(:,:,2) >= saturationRange(1)) & (hsvImage(:,:,2) <= saturationRange(2));

    outputImage = zeros(size(frame));
    outputImage(hueMask & saturationMask) = 255;
    outputImage = im2gray(outputImage);
    binImage = imbinarize(outputImage);
```
마찬가지로 `regionprops` 함수를 이용하여 사각형 성분을 검출하는데, 크로마키 천에 의해 보라색 표식이 일부 가려졌을 때도 인식이 용이하도록 사각형 성분의 가로와 세로의 최소길이조건을 서로 다르게 주었습니다.
```
    regions = regionprops(binImage, 'BoundingBox', 'Area');

    minWidth = 5; 
    minHeight = 20; 
    
    %invPurple = numel(regions)
    if ~isempty(regions)
        validRegions = [];
        for i = 1:numel(regions)
            if regions(i).BoundingBox(3) >= minWidth && regions(i).BoundingBox(4) >= minHeight
                validRegions = [validRegions, regions(i)];
            end
        end
    end
```
조건에 해당하는 보라색 표식이 유일하다면, 사각형 성분의 꼭짓점 성분의 평균을 구함으로써 중점의 좌표를 구합니다.
```
    %valPurple = numel(validRegions)
    if numel(validRegions) == 1
        found = 1;
        xp = validRegions(1).BoundingBox(1) + validRegions(1).BoundingBox(3) / 2;
        yp = validRegions(1).BoundingBox(2) + validRegions(1).BoundingBox(4) / 2;
        imshow(frame);
        hold on;
        plot(xp, yp, 'r+', 'MarkerSize', 10);
        hold off;
        return;
    end
end
```
  
### lookforPurple
![image](https://github.com/JinHeeuk/woncheonhall_316_drone/assets/123629921/67639c2a-fe30-4544-9d8a-a5dc9e56e7e9)
착륙지점 근처에서 자색 표시를 찾지 못하였을 때, 이를 검출하기 위해 좌우로 이동하며 각도를 조절하여 자색 표식을 탐색하는 데 사용된 함수입니다.
  
첫 시도에서는 오른쪽으로 0.2m 이동 후 반시계 방향으로 5도 회전하여 표식이 드론보다 좌측에 있을 때를 대비하였습니다. 이후에도 자색 표식을 검출하지 못했다면, 다음 시도에서는 왼쪽으로 0.4m 이동 후 시계 방향으로 10도 회전, 그 뒤에도 실패하였다면 다음 시도에서는 다시 오른쪽으로 0.6m 이동 후 반시계 방향으로 15도 회전을 계속하여 자색 표식을 계속하여 탐색합니다. 이 과정은 자색 표식을 탐지하거나, 시도 횟수 `trial` 입력이 main 함수에서 정의된 최대치를 넘을 경우 종료됩니다.
```
function sw = lookforPurple(frame, trial, droneObj)
    sw = 5;
    [found, ~, ~] = findPurple(frame);
    if found == 1
        sw = 6;
        return;
    else
        if mod(trial, 2) == 1
            moveright(droneObj, 'Distance', 0.2 * trial);
            turn(droneObj, deg2rad(-5 * trial));
        else
            moveleft(droneObj, 'Distance', 0.2 * trial);
            turn(droneObj, deg2rad(5 * trial));
        end
    end
end
```

### dronePosition
드론이 링을 직진하여 통과하기 이전 최적의 위치에 도달하기 위한 이동거리를 계산하는 함수입니다. 앞선 알고리즘 설명에서 언급하였던 사항이 그대로 적용되어있습니다.
  
`circleDiameter`는 실제 링의 직경(cm)을 의미합니다. 예를 들어 통과해야 할 링의 직경이 78cm라면, 이 입력에 78을 대입합니다.
  
`radii`는 `imfindcircle` 함수 실행 결과가 반환한 원의 픽셀 반지름을 입력받습니다. 마찬가지 방법으로 반환받은 원의 중점은 `xcenter`, `ycenter` 변수에 입력받습니다.
```
function [xpos, ypos] = dronePosition(circleDiameter, radii, xcenter, ycenter)
% 거리별 드론의 이동 제어
%  
```
`pixMeterConstant`는 1.5m 거리에서 실험으로 측정한, 실제 반지름(m)와 측정된 픽셀 반지름(pix)의 비율로, 모든 원에서 측정하였을 때 그 값이 유사함을 확인하였습니다. 단위는 [m/pix]이며, 그 결과는 0.0016이었습니다.
  
풀어서 설명하자면, 영상에서의 하나의 픽셀이 실제 공간에서 몇 m를 의미하는지를 나타내는 상수라고 생각하시면 되겠습니다.
```
    pixMeterConstant = 0.0016;
```
이를 이용하여 드론과 원 사이의 실제 거리를 역산하는 과정은 알고리즘에서 설명한 내용과 같습니다. 단, 단위환산을 위해(cm -> m) 추가적으로 100을 나누었습니다. 
```
    %드론과 원의 실제 거리를 비례식으로 계산
    droneDistance = circleDiameter / 200 / pixMeterConstant / radii * 1.5;
```
드론과 원 사이의 거리를 알았다면, 현재 영상에서 하나의 픽셀이 몇 m를 의미하는지를 계산할 수 있습니다. 단순한 비례식으로 계산합니다. 정량적인 비례식에 의하면 1.3 대신 1.5를 곱하는 것이 타당하나, 실제 운용을 통해 확인한 결과 미세한 보정(0.2 ~ 0.3m)이 필요한 부분에서 함수의 출력이 0이 되는 상황이 빈번하게 발생하여, 이 상수를 조정하여 드론이 조금 더 긴 거리를 이동하도록 설정하였습니다.
```
    %1pix당 실제 횡이동하는 거리를 계산
    movePerPixel = pixMeterConstant * droneDistance / 1.3;
```
원의 중점의 드론의 진행 방향인 [480, 300](이는 실험으로 측정된 값입니다) 지점에 대한 위치벡터를 구하여, 실제 보정을 위해 이동해야 할 거리를 구합니다. 0.1m 단위로 나타내기 위해 결과를 반올림합니다.
```
    %드론 카메라 중점을 기준으로 한 원 중점의 위치벡터 계산
    xpos = round(movePerPixel * (xcenter - 480), 1);
    ypos = round(movePerPixel * (ycenter - 300), 1);
```
드론 제어 함수는 0.2m 미만의 이동거리 입력을 받을 수 없으므로, 이하의 출력이 확인될 경우 0으로 만들어 출력합니다.
```
    if abs(xpos) < 0.2
        xpos = 0;
    end
    if abs(ypos) < 0.2
        ypos = 0;
    end
    fprintf("위치 보정 진행, 원으로부터 %.1fm만큼의 거리에서 우측으로 %.1fm만큼, 아래로 %.1fm만큼 이동합니다\n",droneDistance, xpos, ypos);
end
```
