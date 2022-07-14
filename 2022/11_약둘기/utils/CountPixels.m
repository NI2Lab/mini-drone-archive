function is_flag = CountPixels(aHSVimage)

cMin_blue_th = 0.527;
cMax_blue_th = 0.638;
cBlue_numbers_th = 100;

aH = aHSVimage(:,:,1);


nPixels = nnz(aH>cMin_blue_th & aH < cMax_blue_th);

is_flag = cBlue_numbers_th > nPixels;

end