function lCone = GeneOpsinConeFunShift(lCone,opsin)

% A180 = L(A180), S180 = L(S180), Both = Both present (XX ptpts only)
if ~strcmp(opsin,"")
    % set constants
    wvls = 400:5:700;

    % extract 1st letter and capitalise it
    opsin = char(opsin); opsin = upper(opsin(1));
    
    % save shift values in a structure
    shift = struct;
    shift.A = -1.76; 
    shift.S = 2.40;
    shift.B = 0;
    
    % shift standard observer l cone according to opsin type
    lCone = pchip(wvls+shift.(opsin),lCone,wvls);
end

end