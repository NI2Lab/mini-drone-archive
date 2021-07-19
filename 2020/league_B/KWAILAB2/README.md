# 미니 드론 자율주행 Bleague_KWAILAB2

대회 진행 전략
---
![주행 맵](https://user-images.githubusercontent.com/53847442/85099358-295b8d80-b238-11ea-8c8e-e6c365aa9adf.png)
 - 첫 번째 링의 모든 단계에서 동일하기 때문에 직진한다. 
 - 드론은 박스 값에 따른 지정된 위치들로 아래에서 부터 위로 이동하고 고도가 변할 때마다 좌, 정면, 우 방향으로 탐색한다.
 - 드론이 탐색하면서 카메라로 링의 내부가 탐지될 때 드론의 카메라의 위치를 고려하여 특정 위치 아래로 내려가고 직진한다.
 - 대회의 맵의 구성에 따라 탐지해야할 색을 순서를 지정한다. 



알고리즘 설명
---
1. **시작**
    1. 모든 단계에서 출발점과 첫번째 링의 변화는 없음으로 드론의 아무런 탐색 없이 직진한다. 
2. **탐색**
    1. 첫번째 링을 통과한 드론은 색을 위, 아래, 좌, 우 방향으로 이동하면서 빨간, 파란, 초록 색을 모두 감지한다.
3. **행동**: 
    1.  감지해야할 순서의 색이 빨간색이거나 파란일때 둘의 색이 초록색 보다 큰 경우
        1. 빨간색은 좌회전을 하고 직진을 한다.
        2. 파란색은 착지한다.
    2. 감지해야할 순서의 색이 초록색일 때 빨간과 파란의 색 보다 크고 링의 내부가 잡힐 경우 
        1. 아래로 이동하고 직진한다. 
        
       
       
소스 코드 설명
---
```python
myDrone=Autodrone()
myDrone.driving()
```
main함수로 Autodrone객체를 생성하고 driving 함수를 실행시킨다.

```python
def driving(self):
    self.start()
    orders=["Red Point", "Second Ring", "Red Point","Third Ring","Blue Point"]
    colors=[1,3,1,3,2]#1 Red, 2 Blue, 3 Green
        
    for i in range(5):
        if(self.findColor(orders[i],colors[i])==False):
            break
```
driving함수는 주행 순서에 따른 감지해야할 색을 알려준다. 

```python
    def findColor(self,mode,color):
        hlist=[88,119,156]
        alist=[-30,30,30]
        wlist=[0.2,0,-0.2]
        
        for h in hlist:
            self.go(h)
            r,b,g,cnt=self.takePicture(mode)
            
            if(self.checkColor(color,r,b,g,cnt,mode)==True):
                break
                
            for a in range(3):
                self.spinLeft(alist[a])
                r,b,g,cnt=self.takePicture(mode)
                
                if(self.checkColor(color,r,b,g,cnt,mode)==True):
                    self.spinLeft(alist[a])
                    self.goRight(wlist[a])
                    break
                
        return False
```
findColor 함수는 지정한 고도와 방향으로 이동하여 탐색하게 하는 함수이고 checkColor는 해당 위치에서 다음 행동이 가능한지 확인하는 함수이다.

이 함수들 이외에 드론을 상,하,좌,우,회전하는 함수와 색의 비율을 검출하는 함수, 초록색 내부를 찾는 함수들이 AutoDrone에 내장되어 있다.
