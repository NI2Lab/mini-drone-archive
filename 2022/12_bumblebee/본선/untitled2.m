im = imread("13.jpg");

     [center_blue,radii_blue] = imfindcircles(bwblue,[6 20],'ObjectPolarity','bright', ...
    'Sensitivity',0.9,'Method','twostage');   
        if ~isempty (center_blue) 
                  disp(radii_blue);
                  viscircles(center_blue,radii_blue,'Color','b');
                  
                  if blue_close<=radii_blue(1) &&mode==3
                     blue_close=radii_blue(1);
                  else
                     blue_close=radii_blue(1);
                  end
                  center_blue_save=center_blue;
                  plot(center_blue(1),center_blue(2),'-b+');
        end