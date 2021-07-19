function a = go2(r,c)
    for i =   [ 1.70, 1.10, 0.88   ]
        a = updown(i,r)
        f1 = search(r,c);
        imwrite(f1,"g2_mid_"+i+".jpg");
        check = dircheck(f1)
        if check == 1
            [frame,~] = snapshot(c);
            updown(i-0.25,r);
            imwrite(frame,"fowardposition2.jpg");
            
            %adjust2(r,c,frame);
            adjust(r,c,frame);
            moveforward(r,'Distance',eval_Dist(frame)+0.6,'Speed',1,'WaitUntilDone',true);
            adjustRed(r,c);
            break;
        end
    end
end