classdef YakDrone < handle
    properties
        %assosiated image
        cMin_blue_th=0.595;
        cMax_blue_th=0.670;
        cMin_blue_number = 500;
        cFitler_S_weight=0.35;
        cFitler_V_weight=0.15;   
        
        %assosiated circle
        cCircle_th = 0.45;
        cCircle_rad_th = 50;
        cCircle_Min_ecc_th = 0.50; %ecc 지웟음 
        cOptimized_ratio_th = 0.7; 
        cTotal_Circle = 3;
        cCircle_size = [0.39,0.28,0.25];
        cRange_th = 50; 
        cTargetY_weight=165;

        %assosiated move and distance
        
        cSpeed_set = 1;
        cMax_move_dist=0.5;
        cShoot_distance = 1.3;
        cFinder_Y_distance = 0.35;
        cFinder_X_distance = 0.5;

        %etc
        cWait_time=0.0;
        

        mDrone;
        mCam;
        
        nStep=0;
        nFailCount=0;
        nSize_x=0;
        nSize_y=0;
        nDetected_pixels=0;
        nCircle_r=0;
        nCount=0;
        nEccentricity=0;
        nFinder=0;
        nMoveWeight=0;
        nRatio = 0; %단축/장축
        
        is_last_we_had_positioned = 0;


        aConverted_HSV=[];
        aFiltered_blue=[];
        aBestCircle=[];
        aCentroid=[];
        
    end

    methods 
        function obj = YakDrone()
            obj.mDrone = ryze();
            obj.mCam = camera(obj.mDrone,"FPV");
        end
        [nCenter_X,nCenter_Y]=BluePixelFocusMove(obj);
        is_Complete = ImageProcessing(obj);
        is_Complete = NewFindingCircle(obj);
        is_Center = DetectCircle(obj);
        is_Center = CenterFinder(obj);
        is_Circle = OnlyDetectCircle(obj);
        is_Complete = MovetoLocation(obj,x,y);
        is_Complete = TurnAngle(obj);
        is_Complete = TrunStepFinal(obj);
        nErr_code = Run(obj);

        Finish(obj);
    end
end

