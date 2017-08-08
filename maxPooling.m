function maxValues = maxPooling( image, poolingWindow, step )
%MAXPOOLING Summary of this function goes here
%   Detailed explanation goes here
    
    [imgRows, imgCols] = size(image);
    rowIterator = 1:step:imgRows;
    colIterator = 1:step:imgCols;
    maxValues = zeros(length(rowIterator), length(colIterator));
    
    rCount = 0;
    for rowIndex = rowIterator
        rCount = rCount + 1;
        cCount = 0;
        for colIndex = 1:step:imgCols
            cCount = cCount + 1;
            maxValues(rCount, cCount) = max(...
                                            max(...
                                                image(rowIndex:min((rowIndex+poolingWindow), imgRows), ...
                                                      colIndex:min((colIndex+poolingWindow), imgCols)) ...
                                                ) ...
                                            ); 
        end
    end

end

