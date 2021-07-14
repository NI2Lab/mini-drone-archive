# UOS_Robot 자율비행

> ## 1. 대회 진행 전략
>
> > * ### 영상처리
> >
> >   카메라를 통해 얻은 640 X 480 크기의 이미지를 BGR 색공간에서 HSV 색공간으로 변환
> >
> >   ->  B, G, R의 3가지 색상 변수로 색을 구분하는 것이 아니라 HSV 색공간에서 H(Hue, 색상)의 단일 변수를 통해 색을 구분
> >
> >   ->  HSV 색공간에서 S(Saturation, 채도), V(Value, 명도)의 변화를 고려하지 않는 것으로 빛의 간섭에 의한 색상 변화를 보정
> >
> >   **BGR  ->  HSV**
> >   <p align="center"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/RGB_Cube_Show_lowgamma_cutout_a.png/1024px-RGB_Cube_Show_lowgamma_cutout_a.png" width="400px" height="300px" title="BGR_cube"></img>    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/HSV_color_solid_cylinder_saturation_gray.png/1280px-HSV_color_solid_cylinder_saturation_gray.png" width="400px" height="300px" title="HSV_cylinder"></img></p>
> >
> >
> > * ### 영상처리 방법
> >   for문을 사용한 이미지의 가공을 사용하지 않고 OpenCV의 라이브러리를 통한 영상처리 단순화
> >   
> >   ->  RaspberryPi Zero에서 for문을 통해 620 X 480 크기의 이진화 이미지를 처리해 본 결과, OpenCV 라이브러리를 통한 영상처리가 더 빠른 속도를 보임
> > 
> >   ->  OpenCV 라이브러리를 최대한 활용하여 RaspberryPi Zero에서도 실시간 제어가 가능하도록 최대한 단순화
> >
> >   |  | RaspberryPi 3 | RaspberryPi Zero|
> >   | --- | --- | --- |
> >   | Core | 64-bit Quad-Core | 32-bit Single-Core |
> >   | CPU | 1.2 GHz | 1 GHz |
> >   | Memory | 1 GB | 512 MB |
> >
> > * ### Ring 추적
> >    통과할 Ring과 표적을 찾는 방법으로 단순히 색의 중심을 찾는 것이 아니라 객체의 윤곽을 확인하고 모멘트를 통해 중심 좌표를 추적
> >
> >   ->  이진화한 이미지에서 OpenCV 라이브러리를 통해 원과 사각형에 대한 윤곽선을 추출
> >
> >   ->  추출된 도형에서 Ring 추적은 원형률을, 표적 추적은 사각형의 면적과 면적 점유율을 비교하여 비율이 가장 큰 도형을 각각 Ring, 표적으로 인식
> >
> > * ### 드론 이동
> >   Ring 추적과 표적 추적을 번갈아가며 드론을 이동하여 통과 확률을 높임
> >
> >   ->  Ring의 중심점과 드론의 위치를 맞추어가며 Ring의 앞까지 이동
> >
> >   ->  표적이 일정 크기 이상으로 보이면 표적의 중심점과 드론의 위치를 맞추어가며 Ring을 통과하고 표적에 맞는 동작 실행
>
>
> ## 2. 제어 알고리즘
>
> > * ### 전체 제어 알고리즘
> >
> >
> >
> > * ### 영상처리 알고리즘
> >
> >
