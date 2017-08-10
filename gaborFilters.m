function filterMatrixCell = gaborFilters(orientations, filterScales, lambdaVector, sigmaVector, gammaVector)
    
    %%% Defaults for testing the function
    %orientations = [0 45 90 135];
    %filterScales = 7:2:39;
    %tuningFactors = 4:-0.05:3.2;
    
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
                    X0 = x*cos(theta) + y*sin(theta);
                    Y0 = y*cos(theta) - x*sin(theta);
                    filter(x+center, y+center) = exp(-(X0^2 + (gamma*Y0)^2)/((2*sigma)^2)) * cos(2*pi*X0/lambda);
                end
            end
            filter = filter - mean(mean(filter));
            filter = filter ./ sqrt(sum(sum(filter.^2)));
            filterMatrixCell{scaleIndex, orientationIndex} = filter;
        end
    end
end


    
