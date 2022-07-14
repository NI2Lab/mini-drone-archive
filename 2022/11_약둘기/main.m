%%
fprintf("Starting...\n");
myDrone = YakDrone()
err_code = myDrone.Run();

if ~err_code 
    disp("Done!!");
    clear myDrone;
else
    disp("Exit with Error: ",err_code);
end