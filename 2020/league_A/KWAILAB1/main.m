clear;
clc;

r = ryze()
c = camera(r);
preview(c);
takeoff(r);
go1(r,c);
turnleft(r,c);
go2(r,c);
turnleft(r,c);
go3(r,c);
fin(r,c);
