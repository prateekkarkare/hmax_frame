function [ patches ] = extractRandomPatches( c1Map, patchSizesVector, patchesPerSize )
%EXTRACTRANDOMPATCHES Summary of this function goes here
%   Detailed explanation goes here

    patches = cell(length(patchSizesVector),1);
    c1Sizes = zeros(1, size(c1Map{1}, 1));
    
    for iSize = 1:size(c1Map{1}, 1)
        c1Sizes(iSize) = size(c1Map{1}{iSize}, 1);
    end
    
    patchSizeIndex = 1;
    for s = patchSizesVector
        randomImageIndex = randsample(size(c1Map, 1), patchesPerSize, 1);   %imageSet = size(c1ResponseMap, 1)
        patchIndex = 1;
        for imageIndex = randomImageIndex'
            randomSizeBand = randsample(find(c1Sizes >= s), 1);      %num bands = size(c1ResponseMap{1}, 1)
            patches{patchSizeIndex}{patchIndex} = randSubMatrix(c1Map{imageIndex}{randomSizeBand}, s);
            patchIndex = patchIndex + 1;
        end
        patchSizeIndex = patchSizeIndex + 1;
    end


end

