clear all; close all;

addpath('utils');

dataFile = 'C:\Users\Josh\Desktop\EE559\project\code\data\11_6_2022_source_estimates_num_peaks_15_num_microphones_4';

load(dataFile);

srcDistThresh = 0.3;

%%

% room dimensions
Lx = roomDimensions(1); Ly = roomDimensions(2); Lz = roomDimensions(3);
% sound source X/Y/Z coordinates
Xs = sourceCoord(1); Ys = sourceCoord(2); Zs = sourceCoord(3);

firstOrderImSources = [ -Xs,      Ys,      Zs; ...
                         Xs,     -Ys,      Zs; ...
                         Xs,      Ys,     -Zs; ...
                         2*Lx-Xs, Ys,      Zs; ...
                         Xs,      2*Ly-Ys, Zs; ...
                         Xs,      Ys,      2*Lz-Zs ];

for n = 1:6

    imSrcDists = vecnorm(img_srcs - firstOrderImSources(n,:), 2, 2);

    distThreshIdx = find(imSrcDists <= srcDistThresh);

%     disp('x');

    [minVal, minIdx] = min(imSrcDists,[],'all');
    minScore = scores(minIdx);

    fprintf('minimum distance: %.04f, minimum index: %d, minimum score: %.04f \n',minVal,minIdx,minScore);

end