function output = SinFit(y,x)

if istable(y), y = table2array(y); end

if ~exist("x", 'var'), x = 1:length(y);
elseif istable(x), x = table2array(x);
end

idx = ~isnan(y) & ~isnan(x);
y = y(idx); x = x(idx);

yu = max(y);
yl = min(y);
yr = (yu-yl);                               % Range of ‘y’
yz = y-yu+(yr/2);
zx = x(yz .* circshift(yz,[0 1]) <= 0);     % Find zero-crossings
per = 2*mean(diff(zx));                     % Estimate period
ym = mean(y);                               % Estimate offset
fit = @(b,x)  b(1).*(sin(2*pi*x./b(2) + 2*pi/b(3))) + b(4);    % Function to fit
fcn = @(b) sum((fit(b,x) - y).^2);                              % Least-Squares cost function
s = fminsearch(fcn, [yr;  per;  -1;  ym]);                      % Minimise Least-Squares
xp = linspace(min(x),max(x));
figure(1)
plot(x,y,'bx-',  xp,fit(s,xp), 'r')
xlim([min(x) max(x)])
grid

output = struct("amp", s(1), "period", s(2), "phase", s(3), "offset", s(4));
end
