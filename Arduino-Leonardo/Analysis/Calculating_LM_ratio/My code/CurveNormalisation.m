function y = CurveNormalisation(y,type,val,x)

switch type
    case "none"
    case "height"
        y = y ./ max(y);
        if exist("val",'var'), y = y .* val; end
    case "area"
        if ~exist("x",'var'), x = 1:numel(y); end
        y = y ./ trapz(x,y);
        if exist("val",'var'), y = y .* val; end
    otherwise
        error('"normalisation" parameter must be set to "none", "height", or "area"!');
end

end