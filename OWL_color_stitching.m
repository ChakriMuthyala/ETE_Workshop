
clc;
clear all;
close all;

A = imread('1.jpg'); % Read first frame into imgA
B = imread('2.jpg'); % Read second frame into imgB
w1 = zeros(1944, 2592, 3, 'uint8');
for cnt=1:3
    %%Step 1: Load RGB color channels
    imgA = A(:,:,cnt);
    imgB = B(:,:,cnt);
    figure; imshowpair(imgA,imgB,'ColorChannels','red-cyan');
    title('Color composite (frame A = red, frame B = cyan)');
    
    %% Step 2: Collect SURF features in both images
    pointsA = detectSURFFeatures(imgA);
    pointsB = detectSURFFeatures(imgB);
    
    %% Step 3: Select Correspondences Between Points
    [featuresA, pointsA] = extractFeatures(imgA, pointsA);
    [featuresB, pointsB] = extractFeatures(imgB, pointsB);
    
    %% Step 4: Match features in both images by distance
    indexPairs = matchFeatures(featuresA, featuresB);
    pointsA = pointsA(indexPairs(:, 1), :);          %save matched features only
    pointsB = pointsB(indexPairs(:, 2), :);
    
    %% Step 4. Estimating Geometric Transform from different affine algorithms
    
    [tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA, 'affine');
    imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
    %pointsBmp = transformPointsForward(tform, pointsBm.Location);
    
    %% Step 5: Saving transformed color chanels
    %w1 = zeros(1:1944, 1:2592, 'uint8');
    for i=1:1944
        for j=1:2592
            b = imgA(i, j);
            c = imgBp(i, j);
            w1(i, j,cnt) = min(b,c);
        end
    end
end

figure, clf;
imshow(w1);
title('Stitched Image');

