function [ c2 ] = C2( s2Map, patchesPerSize, numBands )
%C2 Summary of this function goes here
%   Detailed explanation goes here

    c2 = inf(1, patchesPerSize);
    for iPatch = 1:patchesPerSize
        for iBand = 1:length(numBands)
            %[nRows, nCols] = size(s2Map{iPatch}{iBand});
            [minValue, ~] = min(s2Map{iPatch}{iBand}(:));
            if minValue < c2(iPatch)
                c2(iPatch) = minValue;
            end
        end
    end


end

