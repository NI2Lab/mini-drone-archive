function a = go1(r,c)
    for i =  [0.88, 1.10, 1.70 ]
        a = updown(i,r);
        f1 = search(r,c);
        imwrite(f1,"g1_mid_"+i+".jpg");
        check = dircheck(f1)
        if check == 1
            [frame,~] = snapshot(c);
            updown(i-0.25,r);
            imwrite(frame,"fowardposition1.jpg");
           
            %adjust2(r,c,frame);
            adjust(r,c,frame);
            moveforward(r,'Distance',eval_Dist(frame)+0.5,'Speed',1,'WaitUntilDone',true);
       
            adjustRed(r,c);
          
            break;
        end
    end
end