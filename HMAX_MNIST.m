clear all 

% Change the filenames if you've saved the files under different names
% On some platforms, the files might be saved as 
% train-images.idx3-ubyte / train-labels.idx1-ubyte
images = loadMNISTImages('./train-images-idx3-ubyte/train-images.idx3-ubyte');
%labels = loadMNISTLabels('train-labels-idx1-ubyte');
imageX = 28;
imageY = 28;
imageSet = size(images,2);
imageSet = 2000;
imageMatrix = zeros(28, 28, imageSet);
for i = 1:size(imageMatrix, 3)
    imageMatrix(:,:,i) = reshape(images(:,i), 28, 28);
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

for i = 1:imageSet
    s1ResponseMap(:,:,i) = S1( filterMatrixCell, imageMatrix(:,:,i) );
    c1ResponseMap{i} = C1( s1ResponseMap(:,:,i), numBands, poolingWindowVector, filterScales, orientations );
end

clear s1ResponseMap
clear filterMatrixCell gammaVector i imageMatrix imageX imageY lambdaVector sigmaVector

patchesPerSize = 500;
patchSizes = [ 2 4 ];

patches = extractRandomPatches( c1ResponseMap, patchSizes, patchesPerSize );
