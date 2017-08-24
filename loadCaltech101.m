function [ imds categoryMap ] = loadCaltech101( )
%LOADCALTECH101 Summary of this function goes here
%   Detailed explanation goes here
    rootFolder = 'C:\Users\Prateek Karkare\Desktop\Image Reco\101_ObjectCategories.tar\101_ObjectCategories';
    categories = {'airplanes', 'car_side', 'Faces', 'Motorbikes'};
    categoryMap = containers.Map;
    index = 1;
    for iCateg = categories
        categoryMap(char(iCateg)) = index;
        index = index + 1;
    end
    imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');
end

