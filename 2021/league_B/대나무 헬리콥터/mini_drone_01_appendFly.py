import numpy as np
import cv2
from time import sleep
from e_drone.drone import *
from e_drone.protocol import *
from picamera.array import PiRGBArray
from picamera import PiCamera

drone_moving_time = 2

def main():
    # TakeOff
    print("TakeOff")
    drone.sendTakeOff()
    for i in range(5, 0, -1):  # 5,4,3,2,1
        print("{0}".format(i))
        sleep(1)

    drone.sendControlPosition16(0, 0, 0, 0, 0, 0)  # 가가가
    sleep(10)

    print("Go Strate 1 meter")
    drone.sendControlPosition16(10, 0, 0, 5, 0, 0)  #가가가
    for i in range(3, 0, -1):
        print("{0}".format(i))
        sleep(1)

    # for camera -------------------------------------------------------------------------------------------------------
    camera = PiCamera()
    camera.resolution = (640, 480)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(camera.resolution))
    i = 1
    time.sleep(0.1)  # for ready camera

    for frame in camera.capture_continuous(rawCapture, format='bgr', use_video_port=True):

        key = cv2.waitKey(100) & 0xFF
        if key == ord("c"):
            print("Landing")
            drone.sendLanding()
            for i in range(5, 0, -1):
                print("{0}".format(i))
                sleep(1)

        img = frame.array

        img = cv2.flip(img, 0)  # up down
        img = cv2.flip(img, 1)  # left right

        rawCapture.truncate(0)  # for next capture, stream clear
        cv2.imwrite("capture_{}.jpg".format(i), img)
        i += 1

        # HSV ----------------------------------------------------------------------------------------------------------
        img_HSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_H = img_HSV[:, :, 0]
        img_S = img_HSV[:, :, 1]
        img_V = img_HSV[:, :, 2]

        # threshold ----------------------------------------------------------------------------------------------------
        _, bi_h1 = cv2.threshold(img_H, 100 - 6, 179, cv2.THRESH_BINARY)
        _, bi_h2 = cv2.threshold(img_H, 100 + 6, 179, cv2.THRESH_BINARY_INV)
        bi_h = cv2.bitwise_and(bi_h1, bi_h2)

        _, bi_s1 = cv2.threshold(img_S, 217 - 40, 255, cv2.THRESH_BINARY)
        _, bi_s2 = cv2.threshold(img_S, 217 + 40, 255, cv2.THRESH_BINARY_INV)
        bi_s = cv2.bitwise_and(bi_s1, bi_s2)

        _, bi_v1 = cv2.threshold(img_V, 180 - 76, 255, cv2.THRESH_BINARY)
        _, bi_v2 = cv2.threshold(img_V, 180 + 76, 255, cv2.THRESH_BINARY_INV)
        bi_v = cv2.bitwise_and(bi_v1, bi_v2)

        th_r = cv2.bitwise_and(bi_h, bi_s)
        th_r = cv2.bitwise_and(th_r, bi_v)

        # dilate, erode ------------------------------------------------------------------------------------------------
        kernel = np.ones((10, 10), np.uint8)
        th_r = cv2.dilate(th_r, kernel, iterations=4)
        th_r = cv2.erode(th_r, kernel, iterations=5)
        img_shape = th_r.shape

        # get center1 of blue ------------------------------------------------------------------------------------------
        where_white = np.where(th_r > 0)  # np.where is return y,x cordinates
        x_min = np.min(where_white[1])
        x_max = np.max(where_white[1])
        y_min = np.min(where_white[0])
        y_max = np.max(where_white[0])
        center1_x, center1_y = (x_min + x_max) // 2, (y_min + y_max) // 2  #
        print("center of blue : ", center1_x, center1_y)

        # find for perfect circle. ===============================================================================
        y_value_of_hori = th_r[center1_y, :]  # center1_y
        y_index_of_hori = np.where(y_value_of_hori > 0)
        flag_y_cut = 0
        flag_x_cut = 0
        flag_y_unblue = 0
        if len(y_index_of_hori[0]) == 0:
            flag_y_unblue = 1
            print("no blue with left2right")
            pass

        else:
            y_index_old = y_index_of_hori[0][0]
            for idx, y_index in enumerate(y_index_of_hori[0]):
                if abs(y_index - y_index_old) > 1:  # center1_y
                    flag_y_cut = 1
                    print("left2right circle checked")
                y_index_old = y_index
            if flag_y_cut == 0:
                pass


        x_value_of_hori = th_r[:, center1_x]  # center1_x
        x_index_of_hori = np.where(x_value_of_hori > 0)
        flag_x_unblue = 0
        if len(x_index_of_hori[0]) == 0:
            flag_x_unblue = 1
            print("no blue with up2down")

        else:
            x_index_old = x_index_of_hori[0][0]
            for x_index in x_index_of_hori[0]:
                if abs(x_index - x_index_old) > 1:  # center1_x
                    flag_x_cut = 1
                    print("up2down circle checked")
                x_index_old = x_index
            if flag_x_cut == 0:
                pass

        center_of_img = [img_shape[0] // 2, img_shape[1] // 2]  #
        #  ---------------------------------------------------------------------------------------------
        if flag_y_cut == 1 and flag_x_cut == 1:
            print("perfect circle")

            th_r_shape = th_r.shape  #
            print("img.shape : ", th_r.shape)
            mm = []

            #
            step_1 = 0
            step_result_x = 0  #
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_x = center1_x - step_1
                if step_result_x <= 0:  #
                    step_result_x = 0
                    break
                xx = th_r[center1_y, step_result_x]
                if xx > 0:
                    break
            mm.append(step_result_x)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_x = center1_x + step_1
                if step_result_x >= th_r_shape[1]:  #
                    step_result_x = th_r_shape[1]
                    break
                xx = th_r[center1_y, step_result_x]
                if xx > 0:
                    break
            mm.append(step_result_x)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_y = center1_y - step_1
                if step_result_y <= 0:  #
                    step_result_y = 0
                    break
                xx = th_r[step_result_y, center1_x]
                if xx > 0:
                    break
            mm.append(step_result_y)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_y = center1_y + step_1
                if step_result_y >= th_r_shape[0]:  #
                    step_result_y = th_r_shape[0]
                    break
                xx = th_r[step_result_y, center1_x]
                if xx > 0:
                    break
            mm.append(step_result_y) #

            # -------------------------------------------------------------------------------------------------
            #  -------------------------------------------------------------------------------------------------
            center_of_circle = [ (mm[2] + mm[3]) // 2, (mm[0] + mm[1]) // 2] #y, x
            print("center of circle : ", center_of_circle)
            print("center of image : ", center_of_img)

            #
            x_value_of_hori_cir = th_r[:, center_of_circle[1]]  # center1_x
            x_index_of_hori_cir = np.where(x_value_of_hori_cir > 0)
            if abs(center_of_circle[0] - center_of_img[0]) < img_shape[0]//6: #
                if len(x_index_of_hori_cir) <= 40: #
                    print("Go Strate Thru Circle")
                    drone.sendControlPosition16(0, 10, 0, 5, 0, 0)  #
                    for i in range(5, 0, -1):
                        print("{0}".format(i))
                        sleep(1)

                    print("Landing")
                    drone.sendLanding()
                    for i in range(5, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                    break


                elif len(x_index_of_hori_cir) > 40: #
                    print("Go Strate")
                    drone.sendControlPosition16(0, 1, 0, 5, 0, 0)  #
                    for i in range(drone_moving_time, 0, -1):
                        print("{0}".format(i))
                        sleep(1)

            else: #
                #
                if center_of_circle[0] > center_of_img[0]: #
                    print("Go Down")
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  #
                    for i in range(drone_moving_time, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                #
                elif center_of_circle[0] < center_of_img[0]: #
                    print("Go Up")
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  #
                    for i in range(2, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                #
                if center_of_circle[1] > center_of_img[1]:  #
                    print("Go Right")
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  # x
                    for i in range(5, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                #
                elif center_of_circle[1] < center_of_img[1]:  #
                    print("Go Left")
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  #
                    for i in range(5, 0, -1):
                        print("{0}".format(i))
                        sleep(1)

        #  ------------------------------------------------------------------------------
        #
        if flag_y_cut == 1 and flag_x_cut == 0:
            print("only left2right circle")
            # ===============================================================================================
            #
            th_r_shape = th_r.shape  #
            print("img.shape : ", th_r.shape)
            mm = []
            #
            step_1 = 0
            step_result_x = 0  #
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_x = center1_x - step_1
                if step_result_x <= 0:  #
                    step_result_x = 0
                    break
                xx = th_r[center1_y, step_result_x]
                if xx > 0:
                    break
            mm.append(step_result_x)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_x = center1_x + step_1
                if step_result_x >= th_r_shape[1]:  #
                    step_result_x = th_r_shape[1]
                    break
                xx = th_r[center1_y, step_result_x]
                if xx > 0:
                    break
            mm.append(step_result_x)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_y = center1_y - step_1
                if step_result_y <= 0:  #
                    step_result_y = 0
                    break
                xx = th_r[step_result_y, center1_x]
                if xx > 0:
                    break
            mm.append(step_result_y)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_y = center1_y + step_1
                if step_result_y >= th_r_shape[0]:  #
                    step_result_y = th_r_shape[0]
                    break
                xx = th_r[step_result_y, center1_x]
                if xx > 0:
                    break
            mm.append(step_result_y)

            #  -------------------------------------------------------------------------------------------------
            #  -------------------------------------------------------------------------------------------------
            center_of_circle = [(mm[2] + mm[3]) // 2, (mm[0] + mm[1]) // 2]  # y, x
            print("center of circle : ", center_of_circle)
            print("center of image : ", center_of_img)

            #
            if center_of_circle[0] > center_of_img[0]:  #
                print("Go Down")
                drone.sendControlPosition16(0, 0, -1, 5, 0, 0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            elif center_of_circle[0] < center_of_img[0]:  #
                print("Go Up")
                drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            if center_of_circle[1] > center_of_img[1]:  #
                print("Go Right")
                drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            elif center_of_circle[1] < center_of_img[1]:  #
                print("Go Left")
                drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)

        #  ------------------------------------------------------------------------------
        #
        if flag_y_cut == 0 and flag_x_cut == 1:
            print("only up2down circle")
            #  ===========================================================================================================
            #
            th_r_shape = th_r.shape  #
            print("img.shape : ", th_r.shape)
            mm = []
            #
            step_1 = 0
            step_result_x = 0  #
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_x = center1_x - step_1
                if step_result_x <= 0:  #
                    step_result_x = 0
                    break
                xx = th_r[center1_y, step_result_x]
                if xx > 0:
                    break
            mm.append(step_result_x)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_x = center1_x + step_1
                if step_result_x >= th_r_shape[1]:  #
                    step_result_x = th_r_shape[1]
                    break
                xx = th_r[center1_y, step_result_x]
                if xx > 0:
                    break
            mm.append(step_result_x)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_y = center1_y - step_1
                if step_result_y <= 0:  #
                    step_result_y = 0
                    break
                xx = th_r[step_result_y, center1_x]
                if xx > 0:
                    break
            mm.append(step_result_y)

            #
            step_1 = 0
            step_result_x = 0
            step_result_y = 0
            while (1):
                step_1 += 1
                step_result_y = center1_y + step_1
                if step_result_y >= th_r_shape[0]:  #
                    step_result_y = th_r_shape[0]
                    break
                xx = th_r[step_result_y, center1_x]
                if xx > 0:
                    break
            mm.append(step_result_y)

            #  -------------------------------------------------------------------------------------------------
            center_of_circle = [(mm[2] + mm[3]) // 2, (mm[0] + mm[1]) // 2]  # y, x
            print("center of circle : ", center_of_circle)
            print("center of image : ", center_of_img)

            if center_of_circle[0] > center_of_img[0]:  #
                print("Go Down")
                drone.sendControlPosition16(0, 0, -1, 5, 0,
                                            0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            elif center_of_circle[0] < center_of_img[0]:  #
                print("Go Up")
                drone.sendControlPosition16(0, 0, 1, 5, 0,
                                            0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            if center_of_circle[1] > center_of_img[1]:  #
                print("Go Right")
                drone.sendControlPosition16(0, 0, 1, 5, 0,
                                            0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            elif center_of_circle[1] < center_of_img[1]:  #
                print("Go Left")
                drone.sendControlPosition16(0, 0, 1, 5, 0,
                                            0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)


        #  ------------------------------------------------------------------------------------
        #
        if flag_y_cut == 0 and flag_x_cut == 0:
            print("no circle")
            #

            img_shape_div3 = [img_shape[0] // 3, img_shape[1] // 3]
            img_0_0 = th_r[(img_shape[0] // 3) * (0):(img_shape[0] // 3) * (0 + 1),
                      (img_shape[1] // 3) * (0):(img_shape[1] // 3) * (0 + 1)]
            img_0_1 = th_r[(img_shape[0] // 3) * (0):(img_shape[0] // 3) * (0 + 1),
                      (img_shape[1] // 3) * (1):(img_shape[1] // 3) * (1 + 1)]
            img_0_2 = th_r[(img_shape[0] // 3) * (0):(img_shape[0] // 3) * (0 + 1),
                      (img_shape[1] // 3) * (2):(img_shape[1] // 3) * (2 + 1)]

            img_1_0 = th_r[(img_shape[0] // 3) * (1):(img_shape[0] // 3) * (1 + 1),
                      (img_shape[1] // 3) * (0):(img_shape[1] // 3) * (0 + 1)]
            img_1_1 = th_r[(img_shape[0] // 3) * (1):(img_shape[0] // 3) * (1 + 1),
                      (img_shape[1] // 3) * (1):(img_shape[1] // 3) * (1 + 1)]
            img_1_2 = th_r[(img_shape[0] // 3) * (1):(img_shape[0] // 3) * (1 + 1),
                      (img_shape[1] // 3) * (2):(img_shape[1] // 3) * (2 + 1)]

            img_2_0 = th_r[(img_shape[0] // 3) * (2):(img_shape[0] // 3) * (2 + 1),
                      (img_shape[1] // 3) * (0):(img_shape[1] // 3) * (0 + 1)]
            img_2_1 = th_r[(img_shape[0] // 3) * (2):(img_shape[0] // 3) * (2 + 1),
                      (img_shape[1] // 3) * (1):(img_shape[1] // 3) * (1 + 1)]
            img_2_2 = th_r[(img_shape[0] // 3) * (2):(img_shape[0] // 3) * (2 + 1),
                      (img_shape[1] // 3) * (2):(img_shape[1] // 3) * (2 + 1)]

            # -------------------------------------------------------------------------------
            img_arr_of_9 = [img_0_0, img_0_1, img_0_2,
                            img_1_0, img_1_1, img_1_2,
                            img_2_0, img_2_1, img_2_2]
            dict_sum_of_9 = {}
            for idx, i in enumerate(img_arr_of_9):
                dict_sum_of_9[str(idx)] = np.sum(i)
            print(dict_sum_of_9)

            #  --------------------------------------------------------------------------------------------------
            #  --------------------------------------------------------------------------------------
            #
            if dict_sum_of_9['0'] > dict_sum_of_9['2']:
                print("Go Left")
                drone.sendControlPosition16(0, 5, 0, 5, 0, 0) #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            elif dict_sum_of_9['0'] < dict_sum_of_9['2']:
                print("Go Right")
                drone.sendControlPosition16(0, -5, 0, 5, 0, 0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            if dict_sum_of_9['2'] > dict_sum_of_9['8'] or dict_sum_of_9['0'] > dict_sum_of_9['6']:
                print("Go Up")
                drone.sendControlPosition16(0, 0, 5, 5, 0, 0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
            #
            elif dict_sum_of_9['2'] < dict_sum_of_9['8'] or dict_sum_of_9['0'] < dict_sum_of_9['6']:
                print("Go Down")
                drone.sendControlPosition16(0, 0, -5, 5, 0, 0)  #
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)

if __name__ == '__main__':
    drone = Drone()
    drone.open()

    main()

    drone.close()








