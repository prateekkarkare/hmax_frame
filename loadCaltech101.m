function [ image ] = loadCaltech101( )
%LOADCALTECH101 Summary of this function goes here
%   Detailed explanation goes here
    outputFolder = 'C:\Users\Prateek Karkare\Desktop\Image Reco\101_ObjectCategories.tar\101_ObjectCategories';
    categories = {'airplanes'};
    categoryFolder = fullfile(outputFolder, categories);
    imagePath = fullfile(categoryFolder, 'image_0002.jpg');
    image = double(rgb2gray(imread(imagePath{1})));
end

