% Change the filenames if you've saved the files under different names
% On some platforms, the files might be saved as 
% train-images.idx3-ubyte / train-labels.idx1-ubyte
images = loadMNISTImages('./train-images-idx3-ubyte/train-images.idx3-ubyte');
%labels = loadMNISTLabels('train-labels-idx1-ubyte');

%Other images
%load('exampleImages.mat');
%for iImg = 1:size(exampleImages,2)
%    exampleImages{iImg} = double(rgb2gray(imread(exampleImages{iImg})));
%end

%I = exampleImages{1};
%imshow(double(rgb2gray(imread(exampleImages{1}))),[])

I = reshape(images(:,1), 28, 28);

tuningFactors = 4:-.05:3.25;
%MNIST
filterScales = 3:2:9;               
lambdaVector = [1.5 2.5 3.5 4.6];   
sigmaVector =  [1.2 2.0 2.8 3.6];   
%Example
%filterScales = 7:2:37;
%lambdaVector = filterScales.*2./tuningFactors;
%sigmaVector =  lambdaVector.*0.8;

gammaVector = repmat(0.3,[1 length(filterScales)]);
orientations = [0 45 90 135];
filterMatrixCell = gaborFilters(orientations, filterScales, lambdaVector, sigmaVector, gammaVector);

s1ResponseMap = S1( filterMatrixCell, I );

numBands = 1:1:4;
scaleGroupIndex = length(filterScales)/length(numBands);
s1ResponseGroup = cell(length(numBands), scaleGroupIndex, length(orientations));

filterIndex = 0;
for sizeBand = 1:length(numBands)
    for scaleGroup = 1:scaleGroupIndex
        filterIndex = filterIndex + 1;
        for orientation = 1:length(orientations)
            s1ResponseGroup(sizeBand,scaleGroup,orientation) = s1ResponseMap(filterIndex, orientation);
        end
    end
end

%PRE-MAX
c1PreLocalMax = cell(length(numBands),length(orientations));
scaleGroupMax = zeros(size(s1ResponseGroup{1,1,1}));

for sizeBand = 1:length(numBands)
    for orientation = 1:length(orientations)
        for scaleGroup = 1:scaleGroupIndex
            scaleGroupMax = max(scaleGroupMax, s1ResponseGroup{sizeBand,scaleGroup,orientation});
        end
        c1PreLocalMax{sizeBand,orientation} = scaleGroupMax;
    end
end

poolingWindowVector = 8:2:22;
%Local MAX
c1Map = cell(length(numBands),length(orientations));
for sizeBand = 1:length(numBands)
    poolingWindow = poolingWindowVector(sizeBand);
    for orientation = 1:length(orientations)
        c1Map{sizeBand,orientation} = maxPooling(c1PreLocalMax{sizeBand,orientation}, poolingWindow, poolingWindow/2);
    end
end
%clear s1ResponseMap

