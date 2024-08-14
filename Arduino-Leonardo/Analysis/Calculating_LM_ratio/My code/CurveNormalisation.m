function coneFuns = CurveNormalisation(coneFuns, type)

wvls = 400:5:700;

switch type
    case "none"
    case "height"
        coneFuns = coneFuns ./ max(coneFuns);
    case "area"
        coneFuns = coneFuns ./ trapz(wvls, coneFuns); 
    otherwise
        error("""normalisation"" parameter must be set to ""none"", ""height"", or ""area""!");
end

end