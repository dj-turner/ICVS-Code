function MonitorPower(dir, dMode)
% dir = direction of power switch ('on' or 'off')
% dMode = debug mode (0 = off, 1 = on)
% if not in debug mode, turn the monitor on/off
if dMode == 0, WinPower('monitor', dir);
    % if monitor is being turned off, pause for 1 second
    if strcmpi(dir, 'off'), pause(1); end
end
end