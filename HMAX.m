% Change the filenames if you've saved the files under different names
% On some platforms, the files might be saved as 
% train-images.idx3-ubyte / train-labels.idx1-ubyte
%images = loadMNISTImages('./train-images-idx3-ubyte/train-images.idx3-ubyte');
%labels = loadMNISTLabels('train-labels-idx1-ubyte');
%I = reshape(images(:,1), 28, 28);

%%%%%%%%%%%% EXAMPLE %%%%%%%%%%%%%%%%%
%load('exampleImages.mat');
%for iImg = 1:size(exampleImages,2)
%    exampleImages{iImg} = double(rgb2gray(imread(exampleImages{iImg})));
%end
%I = exampleImages{1};

%filterScales = 7:2:37;
%lambdaVector = [7:2:37]*2 ./ [4:-0.05:3.25];
%sigmaVector = lambdaVector .* 0.8;

%%%%%%%%%%%%% CALTECH101 %%%%%%%%%%%%%%%
image = loadCaltech101();
I = image;

%%%%%%%% MNIST
%filterScales = 3:2:9;               
%lambdaVector = [1.5 2.5 3.5 4.6];   
%sigmaVector =  [1.2 2.0 2.8 3.6];   

%%%%%%%% CALTECH101
filterScales = 7:2:37;
lambdaVector = [3.9 5.0 6.2 7.4 8.7 10.0 11.3 12.7 14.1 15.5 17.0 18.5 20.1 21.7 23.3 25.0];
sigmaVector = [1.3 1.7 2.1 2.5 2.9 3.3 3.8 4.2 4.7 5.2 5.7 6.2 6.7 7.2 7.8 8.3];

gammaVector = repmat(0.3,[1 length(filterScales)]);
orientations = [0 45 90 135];
filterMatrixCell = gaborFilters(orientations, filterScales, lambdaVector, sigmaVector, gammaVector, 1);

s1ResponseMap = S1( filterMatrixCell, I );
numBands = 1:1:8;
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

%%%%% Convert c1Map cell to matrix %%
c1MapCell = cell(1,length(numBands));
for s = 1:length(numBands)
    for o = 1:length(orientations)
        tempC = zeros([size(c1Map{s,o}) length(orientations)]);
        tempC(:,:,o) = c1Map{s,o};
        c1MapCell{s} = tempC;
    end
end

%%%%%% Load patches %%%%%%%%%%
load('../hmaxMatlab/universal_patch_set.mat','patches','patchSizes');

nPatchSizes = size(patchSizes,2);
nPatchesPerSize = size(patches{1},2);

for iPatchSize = 1:nPatchSizes
    iPatchSize % outputs the variable to track the progress.
    patchIndices = 1:nPatchesPerSize;

    patchSize = patchSizes(:,iPatchSize);
    nOrientations = patchSize(3);
    nPatchRows = patchSize(1);
    nPatchCols = patchSize(2);
    nPatches = size(patches{1},2);
    
    linearPatch = patches{iPatchSize};

    s2 = cell(nPatches,1);
    for iPatch = 1:nPatches
        squarePatch = reshape(linearPatch(:,iPatch), patchSize(1:3)');
        s2{iPatch} = cell(length(numBands),1);
        for iBand = 1:length(numBands)
            s2{iPatch}{iBand} = windowedPatchDistance(c1MapCell{iBand},squarePatch);  
        end
    end
end


%clear s1ResponseMap

