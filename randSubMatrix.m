function [ subMatrix ] = randSubMatrix( inputMatrix, npart )
%RANDSUBMATRIX Summary of this function goes here
%   Detailed explanation goes here

    [m,n,~] = size(inputMatrix) ;
    ind = randi( (n-npart+1)*(m-npart+1) ) ;
    [ix,iy] = ind2sub([m-npart+1,n-npart+1],ind) ;
    subMatrix = inputMatrix(ix:ix+npart-1,iy:iy+npart-1,:) ;

end

