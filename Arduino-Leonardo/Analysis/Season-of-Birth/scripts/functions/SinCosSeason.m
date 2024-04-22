function [sinSeasons,cosSeasons] = SinCosSeason(inputSeasons)

seasons = ["spring", "summer", "autumn", "winter"];
seasonNums = NaN(height(inputSeasons),1);

for row = 1:height(inputSeasons)
    if ~strcmp(inputSeasons(row), "")
        seasonNums(row) = find(strcmp(seasons, inputSeasons(row)));
    end
end

sinSeasons = sin(2*pi*((seasonNums)/4));
cosSeasons = cos(2*pi*((seasonNums)/4));

end