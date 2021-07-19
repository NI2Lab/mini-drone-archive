import cv2
import numpy as np
from PIL import Image
from time import sleep
from e_drone.drone import*
from e_drone.protocol import*
from picamera.array import PiRGBArray
from picamera import PiCamera


height=0
def eventAltitude(altitude):
    global height
    height=int(altitude.rangeHeight*100)
    
class Autodrone:
    
    def __init__(self):
        self.drone=Drone()#
        self.camera=PiCamera()
        self.camera.resolution=(960,720)
        self.camera.framerate=32
        self.camera.start_preview()
        self.capture=PiRGBArray(self.camera,size=(960,720))
        self.idx=0
        sleep(0.1)
        self.drone.open()
        self.drone.setEventHandler(DataType.Altitude, eventAltitude)
        
    def start(self):
        self.takeOff()
        self.hovering()
        self.goFront(2.6)
        
    def forWhile(self,cmd,x):
        for i in range(x, 0, -1):
            print(cmd)
            sleep(1)    

    def takeOff(self):
        self.drone.sendTakeOff()
        sleep(0.1)
        #self.forWhile("TakeOff",3)
        
    def landing(self):
        self.drone.sendLanding()
        #self.forWhile("Landing",3)
        sleep(0.1)
        self.drone.close()
        
    def hovering(self):
        self.drone.sendControlWhile(0, 0, 0, 0, 3000)
        #self.forWhile("Hovering",3)
        time.sleep(3)
        
    def goFront(self,x):#m + front, - back
        self.drone.sendControlPosition(x,0,0,0.5,0,0)
        if(x<0):
            x*=-1
        time.sleep(x/0.5)
         
    def goUp(self,z):#m + up, - down 
        self.drone.sendControlPosition(0, 0, z, 0.5, 0, 0)
        if(z<0):
            z*=-1
        time.sleep(z/0.5)
    
    def go(self,x):#cm
        self.getHeight()
        global height
        print("past: ",height,"move: ",(x-height)/100)
        self.goUp((x-height)/100)
        self.getHeight()
        print("current: ",height)
    

    def goRight(self,y):#m
        self.drone.sendControlPosition(0, -y, 0, 0.5, 0, 0)
        if(y<0):
            y*=-1
        time.sleep(y/0.5)

    def spinLeft(self,a):#degree, + 반시계, - 시계
        self.drone.sendControlPosition(0, 0, 0, 0, a, 30)
        if(a<0):
            a*=-1
        time.sleep(a/30)
    
    def getHeight(self):
        self.drone.sendRequest(DeviceType.Drone, DataType.Altitude)
        time.sleep(0.1)

    def getMaxArea(self,contours,hierachy,img_internal):
        max = 0
        box = []
        maxIdx = 0
        for i in range(len(contours)):
            if hierachy[0][i][3] != -1:
                cv2.drawContours(img_internal, contours, i, 255, -1)
                area = cv2.contourArea(contours[i])
                if max < area:
                    max = area
                    maxIdx = i

        return max,maxIdx

    def getRate(self,max):
        if max!=0:
            rate=(max/(960*720))*100
        else:
            rate=max
        return rate

    def getColorRate(self,hsv):
        lower_blue = np.array([110, 20, 20])
        upper_blue = np.array([150, 255, 255])

        lower_green = np.array([22, 80, 22])
        upper_green = np.array([90, 170, 90])

        lower_red = np.array([-10, 100, 100])
        upper_red = np.array([10, 255, 255])

        blue_range = cv2.inRange(hsv, lower_blue, upper_blue)
        green_range = cv2.inRange(hsv, lower_green, upper_green)
        red_range = cv2.inRange(hsv, lower_red, upper_red)

        _, blue_result = cv2.threshold(blue_range, 125, 255, 0)
        _, red_result = cv2.threshold(red_range, 125, 255, 0)
        _, green_result = cv2.threshold(green_range, 125, 255, 0)
 
        _,contours, hierachy = cv2.findContours(blue_result, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
        max,_=self.getMaxArea(contours,hierachy,blue_result)
        bRate=self.getRate(max)#파란색 비율
        _, contours, hierachy = cv2.findContours(green_result, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
        max, _ = self.getMaxArea(contours, hierachy, green_result)
        gRate=self.getRate(max)#초록색 비율
        _, contours, hierachy = cv2.findContours(red_result, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
        max, _ = self.getMaxArea(contours, hierachy, red_result)
        rRate=self.getRate(max)#빨간색 비율

        return rRate,bRate,gRate
        
    
    def findInner(self,mode,cnt): 
        self.camera.capture("./{}_{}.jpg".format(mode,cnt))
        img = cv2.imread("./{}_{}.jpg".format(mode,cnt), cv2.COLOR_BGR2HSV)
        img=cv2.flip(img,0)
        img = cv2.resize(img, dsize=(960, 720), interpolation=cv2.INTER_AREA)
        print(img.shape)
        
        lowerBound = np.array([22, 80, 22])
        upperBound = np.array([90, 170, 90])
        
        img = cv2.inRange(img, lowerBound, upperBound)

        ret1, img = cv2.threshold(img, 125, 255, 0)

        _,contours, hierachy = cv2.findContours(img, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
        img_internal = np.zeros(img.shape, img.dtype)

        max,maxIdx=self.getMaxArea(contours,hierachy,img_internal)
        cv2.imwrite("./img_interal.png",img_internal)
        print(max)

        #초록 내부 찾음
        if max>5000:
            #초록 외부 좌표 찾기
            #_,contours, hierachy = cv2.findContours(img, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
            #img_internal = np.zeros(img.shape, img.dtype)
            box=[]
            max,maxIdx=self.getMaxArea(contours,hierachy,img_internal)
            cv2.drawContours(img_internal, contours, maxIdx, 255, -1)
            rect = cv2.minAreaRect(contours[maxIdx])
            box = cv2.boxPoints(rect)
            box = np.int0(box)
            #cv2.drawContours(img_internal,[box], 0, (0,0,255), 2)
            mmt=cv2.moments(contours[maxIdx])
            print(box)#box[0]내부 가장 왼쪽 아래, box[3]내부 가장 오른쪽 아래 좌표
            cX=int(mmt['m10']/mmt['m00'])
            cY=int(mmt['m01']/mmt['m00'])
            print(cX,cY,"Move: ",(cX-480)*0.026)
            #self.goRight((cX-480)*0.026)
            return True

        #초록 내부 찾지 못함
        else:
            print("Find Green Inner")
            return False

            
    def takePicture(self,mode):
        self.idx+=1
        self.camera.capture("./{}_{}.jpg".format(mode,self.idx))
        img = cv2.imread("./{}_{}.jpg".format(mode,self.idx), cv2.COLOR_BGR2HSV)
        img = cv2.resize(img, dsize=(960, 720), interpolation=cv2.INTER_AREA)
        r,b,g=self.getColorRate(img)
        return r,b,g,self.idx
    
    def checkColor(self, color, r,b,g,cnt,mode):
        if(color==1 and r>g):
            self.spinLeft(90)
            self.goFront(2.0)
            return True
            
        if(color==2 and b>g):
            self.landing()
            return True
            
        if(color==3 and (g>r or g>b)):
            if(self.findInner(mode,cnt)==True):
                takePicture("FIND RING")
                self.goUp(-0.25)
                self.goFront(1.6)
                return True
            
        return False
    
    def findColor(self,mode,color):
        hlist=[88,119,170]
        alist=[-30,30,30]
        wlist=[0.5,0,-0.5]
        
        for h in hlist:
            self.go(h)
            time.sleep(0.1)
            r,b,g,cnt=self.takePicture(mode)
            print("R: ",r," B: ",b,"G: ",g)
            
            if(self.checkColor(color,r,b,g,cnt,mode)==True):
                break
                
            for a in range(3):
                self.spinLeft(alist[a])
                time.sleep(0.1)
                r,b,g,cnt=self.takePicture(mode)
                print("R: ",r," B: ",b,"G: ",g)
                
                if(self.checkColor(color,r,b,g,cnt,mode)==True):
                    self.spinLeft(alist[a])
                    self.goRight(wlist[a])
                    break
                
        return False
  
                
    def driving(self):
        self.start()
        orders=["Red Point", "Second Ring", "Red Point","Third Ring","Blue Point"]
        colors=[1,3,1,3,2]#1 Red, 2 Blue, 3 Green
        
        for i in range(5):
            if(self.findColor(orders[i],colors[i])==False):
                if(self.findColor(orders[i],colors[i])==False):
                    self.landing()
                    break


myDrone=Autodrone()
myDrone.driving()
