function colArray = FindColours(nameList)

colArray = NaN(length(nameList), 3);
for name = 1:length(nameList)
    n = char(nameList(name));
    n = n(1);
    switch n
        case "A", rgbCode = [0 0 1];
        case "D", rgbCode = [1 0 1];
        case "J", rgbCode = [1 0 0];
        case "M", rgbCode = [0 1 0];
        otherwise, rgbCode = [0 0 0];
    end
    colArray(name,:) = rgbCode;
end

end