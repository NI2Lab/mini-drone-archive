# Our_drone_revolution 

## 목차
1. Tool에 대해서
2. 대회 내용을 보고 생각한 전략
3. 알고리즘화
4. 소스코드 설명
- - -

# 1. Tool에 대해서
먼저 MATLAB을 이번에 처음 사용하기에 어떤 Tool이 있는지 잘 몰랐습니다.
기존에 설치되는 기본 Tool과 과제에 필요한 Tool 두가지만을 사용하였습니다.
1. MATLAB Support Package for Ryze Tello Drones
2. Image Processing Toolbox

# 2. 대회에 대해 생각한 전략
먼저 대회에 필수적인 언어인 매트랩에 대해 공부하는 것을 우선순위로 두었습니다.
그리고서 1, 2, 3차 과제에 대해 다시한번 공부하고 이를 기반하여 대회를 준비하였습니다.
2차 과제를 통한 드론 움직임의 기초, 3차 과제를 통한 표적의 중심점을 찾는 부분을 기반하였습니다.
하지만 이런 기반을 쌓았음에도 불구하고 본선 대회 준비가 처음에는 막막했습니다.
그러나 단계별로 하나씩 해결해나감으로써 목표에 가까워졌습니다. 저희는 아래와 같은 단계를 거쳤습니다.
1. 드론띄우기 
2. 드론 사진을 통한 중심점 찾기 
3. 중심점을 토대로 드론 움직이기 
4. 색 인식후 색에 따른 움직임 부여
이렇게 큰 틀을 잡고서 알고리즘에 대해 생각해보았습니다.

# 3. 알고리즘화

처음 드론 띄우기와 중심점 찾기는 앞서 얘기한대로 과제를 기반으로 하였기에 어려움이 없었습니다.
3번째 단계는 중심점 x가 사진의 중심점보다 작을 때 왼쪽으로 이동하고, 크다면 오른쪽으로 이동하였으며,
중심점 y도 이와 같은 방식으로 진행하였습니다.
4단계는 먼저 빨간색을 인식하게 되면 90도를 돈 후에 중심찾기를 다시 진행하여 움직였고,
초록색을 인식하면 60도로 먼저 회전하고 원을 못찾았다면 왼쪽으로 조금씩 돌면서 중심을 잡고 진행하였습니다.
보라색을 인식하면 그대로 착륙하여 마쳤습니다.

여기서 색을 탐지하는 타이밍은 원을 통과하기 전에 색을 탐지하여 각 색에 맞는 행동을 취했습니다.

# 4. 소스코드 설명
![image](https://github.com/hyeongseokgo/our_drone_revolution/assets/102367212/42c37444-813b-4c5a-ba1b-2237caf4d27f)

드론을 띄우고 카메라 객체를 먼저 선언해줍니다.

![image](https://github.com/hyeongseokgo/our_drone_revolution/assets/102367212/d24cbf0a-bc9f-4150-a532-c473915f6154)

![image](https://github.com/hyeongseokgo/our_drone_revolution/assets/102367212/32e8fef0-9910-400e-9669-cf2306e32867)

![image](https://github.com/hyeongseokgo/our_drone_revolution/assets/102367212/187fc62d-2776-40b6-bd2a-949f544cf0fb)

detect_center를 통해 중심점을 찾고 이동하는 코드 Move를 만들었습니다.

![image](https://github.com/hyeongseokgo/our_drone_revolution/assets/102367212/a50f748d-4126-49e3-8880-77b4696e7439)

![image](https://github.com/hyeongseokgo/our_drone_revolution/assets/102367212/bfc50a88-c08a-459c-afa9-cec31f580022)

![image](https://github.com/hyeongseokgo/our_drone_revolution/assets/102367212/0e7dd294-7802-4842-a256-300ae467e08d)


nzz를 통해 원이 적정 크기라면 색 탐지를 시작하고, 아니라면 조금씩 앞으로 가면서 원에 근접합니다.
이렇게 반복하게 되면서 보라색이 탐지가 된다면 착륙하여 비행을 중단합니다.
