function a = go3(r,c)
    moveforward(r,'Distance',1,'Speed',0.6,'WaitUntilDone',true);
    for i =   [0.88, 1.10, 1.70 ]
        a = updown(i,r)
        [f1,f2,f3] = shake(r,c);
        imwrite(f1,"g3_mid_"+i+".jpg");
        imwrite(f2,"g3_right_"+i+".jpg");
        imwrite(f3,"g3_left_"+i+".jpg");
        check = dircheck(f1)
        if check == 1
            moveforward(r,'Distance',2.3,'Speed',0.6,'WaitUntilDone',true);
        end
        check = dircheck(f2);
        if check == 1
            moveright(r,'Distance',1.5,'WaitUntilDone',false);
        end
        check = dircheck(f3);
        if check == 1
            moveleft(r,'Distance',1.5,'WaitUntilDone',false);
        end  
        [frame,~] = snapshot(c);
        updown(i-0.25,r);     
        imwrite(frame,"fowardposition3.jpg");
             
        %adjust2(r,c,frame);
        adjust(r,c,frame);
        moveforward(r,'Distance',eval_Dist(frame)+0.5,'Speed',1,'WaitUntilDone',true);
        adjustRed(r,c);
        break;
    end
end