from e_drone.protocol import *
from e_drone.drone import *
from time import sleep
'''
드론 제어 시 다음 명령 수행전 안정화를 위해 sleep()사용
'''

'''
http://dev.byrobot.co.kr/documents/kr/products/e_drone/library/python/e_drone/
'''


'''
드론 객체 선언
'''
if __name__ == '__main__':
    drone = Drone()

    '''
    드론 serial port open
    '''
    drone.open()

    '''
    드론 이륙 명령
    '''
    print("TakeOff")
    drone.sendTakeOff()
    for i in range(5, 0, -1):
        print("{0}".format(i))
        sleep(1)

    '''
    드론 이동 제어 함수
    def sendControlWhile(self, roll, pitch, yaw, throttle, timeMs)

    '''
    print("Hovering")
    drone.sendControlWhile(0, 0, 0, 0, 5000)  # 5000ms = 5초 동안 hovering
    for i in range(3, 0, -1):
        print("{0}".format(i))
        sleep(1)


    '''
    드론 이동 제어 함수
    def sendControlPosition16(self, positionX, positionY, positionZ, velocity, heading, ratationalvelocity)

        변수 이름           형식        범위                  단위        설명
        ----------------------------------------------------------------------------------
        positionX          int16    -100~100(-10.0~10.0)    meter*10    앞(+), 뒤(-)
        positionY          int16    -100~100(-10.0~10.0)    meter*10    좌(+), 우(-)
        positionZ          int16    -100~100(-10.0~10.0)    meter*10    위(+), 아래(-)
        velocity           int16     5~20(0.5~2.0)          m/s*10      위치 이동 속도
        heading            int16    -360~360                degree      좌회전(+), 우회전(-)
        rotationalVelocity int16     10~360                 degree/s    좌우 회전 속도

    '''
    print("Go Front 1 meter")
    drone.sendControlPosition16(10, 0, 0, 5, 0, 0)  # 앞으로 1미터 0.5m/s의 속도로 이동
    for i in range(5, 0, -1):
        print("{0}".format(i))
        sleep(1)

    print("Go Right 1 meter")
    drone.sendControlPosition16(0, -10, 0, 5, 0, 0)  # 우측으로 1미터 0.5m/s의 속도로 이동
    for i in range(5, 0, -1):
        print("{0}".format(i))
        sleep(1)

    '''
    드론 착륙 명령
    '''
    print("Landing")
    drone.sendLanding()
    for i in range(5, 0, -1):
        print("{0}".format(i))
        sleep(1)

    '''
    드론 serial port close
    '''
    drone.close()
