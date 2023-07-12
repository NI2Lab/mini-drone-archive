function move_based_error(x, y, x_d, y_d, mytello)
    x_error = (x_d-x)*0.001; 
    if abs(x_error) <0.2 
        x_error = 0.2*sign(x_error); 
    end

    y_error = (y_d-y)*0.001;
    if abs(y_error) <0.2 
        y_error = 0.2*sign(y_error); 
    end

    if  x_error > 0 
        moveright(mytello, 'Distance', abs(x_error), 'Speed', 0.5);
    elseif x_error < 0 
        moveleft(mytello, 'Distance', abs(x_error), 'Speed', 0.5);
    end

    if  y_error > 0  
        moveup(mytello, 'Distance', abs(y_error), 'Speed', 0.5);
    elseif y_error < 0 
        movedown(mytello, 'Distance', abs(y_error), 'Speed', 0.5);
    end
    
end