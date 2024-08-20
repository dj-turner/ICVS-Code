function y = CurveNormalisation(y, type)

wvls = 400:5:700;

switch type
    case "none"
    case "height"
        y = y ./ max(y);
    case "area"
        y = y ./ trapz(wvls, y); 
    otherwise
        error("""normalisation"" parameter must be set to ""none"", ""height"", or ""area""!");
end

end