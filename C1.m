function [ c1Map ] = C1( s1ResponseMap, numBandsVector, poolingWindowVector, filterScalesVector, orientationsVector )
%C1 Summary of this function goes here
%   Detailed explanation goes here

% c1Map is a cell of responses of each image with rows equal to number of bands
% each element of this cell is a 3D matrix the third dimension is equal to response of each orientation
% Cell | Band 1 |
%      | Band 2 |

% Band 1 | response x response x orientations |  

% For every orientation need to find max for each size band; Rows contain
% different filter scales. Columns have different orientations

% Row 1 | .  .  .  .  .  .  . | } 
% Row 2 | .  .  .  .  .  .  . | } Band 1  --> Max[7]
% Row 3 | .  .  .  .  .  .  . | }
% Row 4 | .  .  .  .  .  .  . | } Band 2  --> Max[7]
% Row 5 | .  .  .  .  .  .  . | }
% Row 6 | .  .  .  .  .  .  . | } Band 3  --> Max[7]
% Row 7 | .  .  .  .  .  .  . | }
% Row 8 | .  .  .  .  .  .  . | } Band 4  --> Max[7]

    responsesInBand = length(filterScalesVector)/length(numBandsVector);
    c1PreLocalMax = cell(length(numBandsVector), length(orientationsVector));
    %c1Map = cell(length(numBandsVector),length(orientationsVector));
    c1Map = cell(length(numBandsVector),1);

    for orientation = 1:length(orientationsVector)
        for band = 1:length(numBandsVector)
            scaleGroupMax = zeros(size(s1ResponseMap{1,1}));
            for response = 1:responsesInBand
                scaleGroupMax = max(scaleGroupMax, s1ResponseMap{(band*responsesInBand - (response - 1)), orientation});
            end
        c1PreLocalMax{band, orientation} = scaleGroupMax;
        end
    end
    
    %%% MAX Pooling across scales%%%
    for sizeBand = 1:length(numBandsVector)
        poolingWindow = poolingWindowVector(sizeBand);
        for orientation = 1:length(orientationsVector)
            c1Map{sizeBand}(:,:,orientation) = maxPooling(c1PreLocalMax{sizeBand,orientation}, poolingWindow, poolingWindow/2);
        end
    end

end

