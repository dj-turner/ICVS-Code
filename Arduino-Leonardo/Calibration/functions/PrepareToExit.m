function PrepareToExit(a)   
% a = arduino device
% Reset all lights to off before closing
WriteLEDs(a,[0,0,0]);
% Clear everything before ending program
delete(instrfindall);
clear all; %#ok<CLALL>
warning('on', 'instrument:instrfindall:FunctionToBeRemoved');
end