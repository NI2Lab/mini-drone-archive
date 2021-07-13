function out = myFunction_0414(x)
D = fix(x/1115.50);
x_100 = floor(D/100)
D_100 = D - 100*floor(D/100);
x_50 = floor(D_100/50)
D_50 = D_100 - 50*floor(D_100/50);
x_20 = floor(D_50/20)
D_20 = D_50 - 20*floor(D_50/20);
x_10 = floor(D_20/10)
D_10 = D_20 - 10*floor(D_20/10);
x_5 = floor(D_10/5)
D_5 = D_10 - 5*floor(D_10/5);
x_1 = floor(D_5/1)
D_1 = D_5 - 1*floor(D_5/1);
["100$",(x_100);"50$",(x_50);"20$",(x_20);"10$",(x_10);"5$",(x_5);"1$",(x_1)]
end
