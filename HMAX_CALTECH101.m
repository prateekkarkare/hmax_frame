clear all

EXTRACT_PATCHES_ONLY = 0
USE_EXISTING_PATCHES = 1
TRAINING = 0

%%%%%%%%%%%%% CALTECH101 %%%%%%%%%%%%%%%
[imgDatabase labelMap] = loadCaltech101();

tbl = countEachLabel(imgDatabase);
minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category

% Use splitEachLabel method to trim the set.
imgDatabase = splitEachLabel(imgDatabase, minSetCount, 'randomize');

% Notice that each set now has exactly the same number of images.
countEachLabel(imgDatabase);

[trainingSet, validationSet] = splitEachLabel(imgDatabase, 0.7, 'randomize');

if TRAINING
    imageDB = trainingSet
else
    imageDB = validationSet
end

imageSet = length(imageDB.Labels)

imageX = 128;
imageY = 128;

images = cell(imageSet, 1);
labelVector = zeros(1, imageSet);
for iImg = 1:imageSet
    if numel(size(readimage(imageDB, iImg))) == 3               % if Image is RGB
       images{iImg} = imresize(double(rgb2gray(readimage(imageDB, iImg))), [imageX imageY]);
    else
       images{iImg} = imresize(double(readimage(imageDB, iImg)), [imageX imageY]);
    end
    
    labelVector(iImg) = labelMap(char(imageDB.Labels(iImg)));
end

clear imgDatabase iImg imageX imageY minSetCount tbl

filterScales = 7:2:37;
lambdaVector = [3.9 5.0 6.2 7.4 8.7 10.0 11.3 12.7 14.1 15.5 17.0 18.5 20.1 21.7 23.3 25.0];
sigmaVector = [1.3 1.7 2.1 2.5 2.9 3.3 3.8 4.2 4.7 5.2 5.7 6.2 6.7 7.2 7.8 8.3];

gammaVector = repmat(0.3,[1 length(filterScales)]);
orientations = [0 45 90 135];
filterMatrixCell = gaborFilters(orientations, filterScales, lambdaVector, sigmaVector, gammaVector, 0);

s1ResponseMap = cell(length(filterScales), length(orientations), imageSet);

numBands = [ 1 2 3 4 5 6 7 8 ];
poolingWindowVector = [ 8 10 12 14 16 18 20 22 ];

assert(length(numBands) == length(poolingWindowVector), 'Pooling windows must be equal to number of bands')

c1ResponseMap = cell(imageSet,1);

fprintf('Computing S1 and C1 responses...\n')

for i = 1:imageSet
    s1ResponseMap(:,:,i) = S1( filterMatrixCell, images{i} );
    c1ResponseMap{i} = C1( s1ResponseMap(:,:,i), numBands, poolingWindowVector, filterScales, orientations );
end

fprintf('S1 & C1 computation done, cleaning up memory and extracting patches\n')

clear s1ResponseMap
clear filterMatrixCell gammaVector i imageMatrix imageX imageY lambdaVector sigmaVector

if USE_EXISTING_PATCHES
    fprintf('Loading existing patches.\n')
    load('caltech101Patches.mat', 'patches');
    patchesPerSize = size(patches{1}, 2);
    patchSizes = zeros(1, length(patches));
    for p = 1:length(patches)
        patchSizes(p) = size(patches{p}{1}, 1);
    end
else 
    patchesPerSize = 400;
    patchSizes = [ 2 4 6 8 10 12 14 16 ];
    patches = extractRandomPatches( c1ResponseMap, patchSizes, patchesPerSize );
    fprintf('Patch extraction done, saving patches.\n')
    save('caltech101Patches.mat', 'patches');
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
inputToClassifier = [inputToClassifier labelVector'];

clear s2ResponseMap patches
clear c1ResponseMap i

