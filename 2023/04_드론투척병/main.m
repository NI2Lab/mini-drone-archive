clear droneObj, clear cameraObj;
droneObj= ryze();
cameraObj = camera(droneObj);



takeoff(droneObj);
moveup(droneObj,'Distance',0.5);

% step one
aligncenter(droneObj,cameraObj,0)
move2(droneObj)
turnbycolor(droneObj,cameraObj)

% step two
aligncenter(droneObj,cameraObj,0)
move2(droneObj)
turnbycolor(droneObj,cameraObj)

% step three
aligncenter(droneObj,cameraObj,0.33)
move2(droneObj)
turnbycolor(droneObj,cameraObj)
alignangle(droneObj,cameraObj)

% step four
move2(droneObj)
land(droneObj)






function center=findcenter(cameraObj,hue)
    overred = 100;
    image = snapshot(cameraObj);
    %subplot(2,1,1), imshow(image); 
    hsv=rgb2hsv(image);
    h=hsv(:,:,1);
    s=hsv(:,:,2);
    v=hsv(:,:,3);
    
    hue_lo = hue-0.04;
    hue_hi = hue+0.04;
    if(hue_lo<0)
        red = (h>hue_lo+1)|(h<hue_hi);
    elseif(hue_hi>1)
        red = (h>hue_lo)|(h<hue_hi-1);
    else
        red = (h>hue_lo)&(h<hue_hi);
    end
    red = red&(s>0.3)&(v>0.2); 
    
    sumred = sum(red,'all');
    
    blue = (h<0.66)&(0.55<h)&(s>0.5);
    if(sumred >= overred)
        blue = ~blue;
    end
    
    stats = regionprops('table', blue,'Area', 'Centroid', ...
        'BoundingBox');
    stats = sortrows(stats,'Area', 'descend');
    
    firstArea = stats.BoundingBox(1,3)*stats.BoundingBox(1,4);
    imsize = size(image);
    imarea = imsize(1)*imsize(2);
    
    if height(stats)>=2
        if firstArea  > imarea*0.9
            center = stats.Centroid(2, :);
            box = stats.BoundingBox(2,:);
        else 
            center = stats.Centroid(1, :);
            box = stats.BoundingBox(1,:);
        end
    else
        center = stats.Centroid(1, :);
        box = stats.BoundingBox(1,:);
    end
    
    %subplot(2,1,2), imshow(blue); hold on;
    %rectangle('Position',box,'EdgeColor','r', 'LineWidth',3)
    %plot(center(1), center(2),'r*')
end




function aligncenter(droneObj,cameraObj,hue)
    DISTANCE = 0.2;
    
    isH= false;
    isW = false;
    prevH = 0;
    prevW = 0;
    curH = 0;
    curW = 0;
    
    while(1)
        prevH= curH;
        prevW= curW;
        center = findcenter(cameraObj,hue);

        if (isW==false)
            if(center(1)<=480) 
                moveleft(droneObj,'Distance',DISTANCE);
                curW = 1;
            else 
                moveright(droneObj,'Distance',DISTANCE);
                curW = -1;
            end
        end

        if (isH==false)
            if(center(2)<=360) 
                moveup(droneObj,'Distance',DISTANCE);
                curH = 1;
            else 
                movedown(droneObj,'Distance',DISTANCE);
                curH = -1;
            end
        end
        
        if(prevH*curH <0)
            isH = true;
        end
        
        if(prevW*curW <0)
            isW = true;
        end
        
        if(isH&&isW)
            break
        end
    end
end



function c=move2(droneObj)
    DISTANCE= 2;

    moveforward(droneObj,'Distance',DISTANCE);
end


function s = getcolorsum(hsv,hue)
        h=hsv(:,:,1);
        s=hsv(:,:,2);
        v=hsv(:,:,3);
        hue_lo = hue-0.04;
        hue_hi = hue+0.04;

        if(hue_lo<0)
            red = (h>hue_lo+1)|(h<hue_hi);
        elseif(hue_hi>1)
            red = (h>hue_lo)|(h<hue_hi-1);
        else
            red = (h>hue_lo)&(h<hue_hi);
        end
        red = red&(s>0.3)&(v>0.3);
        s = sum(red,'all');
end


function t = turnbycolor(droneObj, cameraObj)
    THRESHOLD = 1000;

    image = snapshot(cameraObj);
    hsv=rgb2hsv(image);
    sr=getcolorsum(hsv, 0);
    sg=getcolorsum(hsv, 0.33);
    if(sr>=THRESHOLD)
        turn(droneObj,deg2rad(-90));
    elseif(sg>=THRESHOLD)
        turn(droneObj,deg2rad(-45));
        alignangle(droneObj,cameraObj);
    end
end

function alignangle(droneObj,cameraObj)
    ANGLE = 5;

    isW = false;
    prevW = 0;
    curW = 0;

    while(1)
        prevW= curW;
        center = findcenter(cameraObj,0.78);
        
        if(center(1)<=480) 
            turn(droneObj,deg2rad(-ANGLE));
            curW = 1;
        else 
            turn(droneObj,deg2rad(ANGLE));
            curW = -1;
        end
        
        if(prevW*curW <0)
            isW = true;
        end
        
        if(isW)
            break
        end
    end
end
