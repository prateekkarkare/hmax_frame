function filterMatrixCell = gaborFilters(orientations, filterScales, lambdaVector, sigmaVector, gammaVector, CIRCULAR_RF)
    
    %numFilters = length(filterScales)*length(orientations);
    %filterMatrixReshaped = zeros(max(filterScales)^2, numFilters);
    filterMatrixCell = cell(length(filterScales),length(orientations));

    for scale = filterScales
        scaleIndex = (filterScales == scale);
        for orient = orientations
            orientationIndex = (orientations == orient);
            center = ceil(scale/2);
            filterLeft = center - 1;            %To deal with even filter sizes this cant be center - filtersize
            filterRight = scale - filterLeft - 1;
            
            theta = orient*pi/180;
            lambda = lambdaVector(scaleIndex);
            sigma = sigmaVector(scaleIndex);
            gamma = gammaVector(scaleIndex);

            filter = zeros(scale, scale);
            for x = -filterLeft:filterRight
                for y = -filterLeft:filterRight
                    if (CIRCULAR_RF && sqrt(x^2 + y^2)>scale/2)
                        filter(x+center, y+center) = 0;
                    else
                        X0 = x*cos(theta) + y*sin(theta);
                        Y0 = y*cos(theta) - x*sin(theta);
                        filter(x+center, y+center) = exp(-(X0^2 + (gamma*Y0)^2)/((2*sigma)^2)) * cos(2*pi*X0/lambda);
                    end
                end
            end
            filter = filter - mean(mean(filter));
            filter = filter ./ sqrt(sum(sum(filter.^2)));
            %filterMatrixCell{scaleIndex, orientationIndex} = filter(end:-1:1,end:-1:1);
            filterMatrixCell{scaleIndex, orientationIndex} = filter;
        end
    end
end


    
