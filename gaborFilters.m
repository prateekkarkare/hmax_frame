function filterMatrixCell = gaborFilters(orientations, filterScales, tuningFactors)
    
    %%% Defaults for testing the function
    %orientations = [0 45 90 135];
    %filterScales = 7:2:39;
    %tuningFactors = 4:-0.05:3.2;
    
    numFilters = length(filterScales)*length(orientations);
    filterMatrixReshaped = zeros(max(filterScales)^2, numFilters);
    filterMatrixCell = cell(4);

    for scale = filterScales
        scaleIndex = find(filterScales == scale);
        for orient = orientations
            orientationIndex = find(orientations == orient);
            center = ceil(scale/2);
            filterLeft = center - 1;            %To deal with even filter sizes this cant be center - filtersize
            filterRight = scale - filterLeft - 1;
            
            theta = orient;
            lambda = scale*2./tuningFactors(scaleIndex);
            sigma = lambda*0.8;
            gamma = 0.3;

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


    
