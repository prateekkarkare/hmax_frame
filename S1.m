function [ s1ResponseMap ] = S1( filterMatrixCell, image )
%S1 Summary of this function goes here
%   Detailed explanation goes here
    s1ResponseMap = cell(size(filterMatrixCell));
    
    for scale = 1:size(filterMatrixCell, 1)
        for orientation = 1:size(filterMatrixCell, 2)
            filter = filterMatrixCell{scale,orientation};
            s1ResponseMap{scale, orientation} = abs(conv2(image,filter, 'same'));
        end
    end
end

