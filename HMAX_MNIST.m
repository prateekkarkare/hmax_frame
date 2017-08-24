clear all 

EXTRACT_PATCHES_ONLY = 0
USE_EXISTING_PATCHES = 1

TRAINING_IMAGES = 0

% Change the filenames if you've saved the files under different names
% On some platforms, the files might be saved as 
% train-images.idx3-ubyte / train-labels.idx1-ubyte
if TRAINING_IMAGES
    images = loadMNISTImages('./MNIST/train-images.idx3-ubyte');
    labels = loadMNISTLabels('./MNIST/train-labels.idx1-ubyte');
else
    images = loadMNISTImages('./MNIST/t10k-images.idx3-ubyte');
    labels = loadMNISTLabels('./MNIST/t10k-labels.idx1-ubyte');
end

imageX = 28;
imageY = 28;
imageSet = 1000;
assert(imageSet <= size(images,2), 'Choose lesser number of images');
labels = labels(1:imageSet);
imageMatrix = zeros(imageX, imageY, imageSet);
for i = 1:size(imageMatrix, 3)
    imageMatrix(:,:,i) = reshape(images(:,i), imageX, imageY);
end

clear images

%%%%%%%% MNIST
filterScales = 3:2:9;               
lambdaVector = [1.5 2.5 3.5 4.6];   
sigmaVector =  [1.2 2.0 2.8 3.6];   

gammaVector = repmat(0.3, [1 length(filterScales)]);
orientations = [0 45 90 135];
filterMatrixCell = gaborFilters(orientations, filterScales, lambdaVector, sigmaVector, gammaVector, 0);

s1ResponseMap = cell(length(filterScales), length(orientations), imageSet);

numBands = [1 2];
poolingWindowVector = [6 8];

assert(length(numBands) == length(poolingWindowVector), 'Pooling windows must be equal to number of bands')

c1ResponseMap = cell(imageSet,1);

fprintf('Computing S1 and C1 responses...\n')

for i = 1:imageSet
    s1ResponseMap(:,:,i) = S1( filterMatrixCell, imageMatrix(:,:,i) );
    c1ResponseMap{i} = C1( s1ResponseMap(:,:,i), numBands, poolingWindowVector, filterScales, orientations );
end

fprintf('S1 & C1 computation done, cleaning up memory and extracting patches\n')

clear s1ResponseMap
clear filterMatrixCell gammaVector i imageMatrix imageX imageY lambdaVector sigmaVector

if USE_EXISTING_PATCHES
    fprintf('Loading existing patches.\n')
    load('mnistpatches.mat', 'patches');
    patchesPerSize = size(patches{1}, 2);
    patchSizes = zeros(1, length(patches));
    for p = 1:length(patches)
        patchSizes(p) = size(patches{p}{1}, 1);
    end
else 
    patchesPerSize = 500;
    patchSizes = [ 2 4 ];
    patches = extractRandomPatches( c1ResponseMap, patchSizes, patchesPerSize );
    fprintf('Patch extraction done, saving patches.\n')
    save('mnistPatches.mat', 'patches');
end
    
if EXTRACT_PATCHES_ONLY
    return
end

s2ResponseMap = cell(imageSet, 1);
c2ResponseMap = cell(imageSet, 1);
for i = 1:imageSet
    fprintf('S2 & C2 for image %i\n', i)
    s2ResponseMap{i} = S2 ( patches, c1ResponseMap{i}, patchSizes, numBands);
    c2ResponseMap{i} = C2 ( s2ResponseMap{i}, patchesPerSize, numBands );
end

inputToClassifier = cell2mat(c2ResponseMap);
inputToClassifier = [inputToClassifier labels];

clear c1ResponseMap i
