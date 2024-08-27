function y = CurveNormalisation(y,type,val)

switch type
    case "height"
        y = y ./ max(y);
    case "area"
        y = y ./ trapz(y);        
    otherwise
        error('"type" parameter must be set to "height" or "area"!');
end
if exist("val",'var'), y = y .* val; end

end