function [ s1ResponseMap ] = S1( filterMatrixCell, image )
%S1 Summary of this function goes here
%   Detailed explanation goes here
    s1ResponseMap = cell(size(filterMatrixCell));
    
    imageSquared = image.^2;
    l2Norm = cell(size(filterMatrixCell, 1), 1);
    for scale = 1:size(filterMatrixCell, 1)
        l2Norm{scale} = conv2(imageSquared, ones(size(filterMatrixCell{scale})), 'same').^0.5;
        l2Norm{scale} = l2Norm{scale} + ~l2Norm{scale};     %Making 0 elements in norm to 1 to avoid div by 0
    end
    
    for scale = 1:size(filterMatrixCell, 1)
        for orientation = 1:size(filterMatrixCell, 2)
            filter = filterMatrixCell{scale,orientation};
            s1ResponseMap{scale, orientation} = abs(conv2(image, filter, 'same')) ./ l2Norm{scale};
        end
    end
end

