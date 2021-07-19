function a = dircheck(frame)
   b = findLine(frame);
   x = b(1)
   y = b(2)
   if ( 200 < x ) && ( x < 500) && ( 200 < y ) && ( y < 700 )
        a = 1;
   else
        a = 0;
   end 
end