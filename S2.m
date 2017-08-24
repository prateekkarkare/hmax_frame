function [ s2 ] = S2( patches, c1Map, patchSizes, numBands )
%S2 Summary of this function goes here
%   Detailed explanation goes here

    nPatchSizes = length(patchSizes);
    for iPatchSize = 1:nPatchSizes
        %iPatchSize % outputs the variable to track the progress.

        nPatches = size(patches{iPatchSize},2);

        s2 = cell(nPatches,1);
        for iPatch = 1:nPatches
            squarePatch = patches{iPatchSize}{iPatch};
            s2{iPatch} = cell(length(numBands),1);
            for iBand = 1:length(numBands)
                s2{iPatch}{iBand} = windowedPatchDistance(c1Map{iBand},squarePatch);  
            end
        end
    end


end

