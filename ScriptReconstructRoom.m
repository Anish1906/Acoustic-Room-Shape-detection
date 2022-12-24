%% reconstruct room geometry using scores output by echo matching
% Use this to plot the extracted echoes: https://www.mathworks.com/matlabcentral/answers/82901-how-to-plot-feasible-space-in-3d-after-subtracting-multiple-inequalities

clear all; close all;

addpath('utils');

%% experiment params

% maximum allowable average error from S-stress

% use for data collect
% scoreThresh = 5e-2;
% scoreThresh = 0.5e-2;

% use for simulation
scoreThresh = 0.2e-2;

% file containing echo matching results

% simulated
dataFile = 'C:\Users\Josh\Desktop\EE559\project\code\data\imgSrcs_simulated\12_4_2022_source_estimates_num_peaks_21_num_microphones_5_tx_1.50_ty_1.50_tz_0.00';

% data collect
% dataFile = 'C:\Users\Josh\Desktop\EE559\project\code\data\imgSrcs_dataCollect\12_11_2022_source_estimates_impulseResponseP1_oven.mat';

%% import data from echo match scoring stage

load(dataFile);

%% Acquire final set of image sources by removing candidates with low scores,
%  candidates that are higher order sources, and candidates that are redundant.

imgSrcsFinal = removeCandidateImageSources(img_srcs,scores,scoreThresh,src_est);

% % plot receiver coordinates on top of candidate image source plots
% figure(1); hold on; scatter3(receiverCoords(:,1),receiverCoords(:,2),receiverCoords(:,3),200,'r.');
% legend('Image Sources','Sound Source','Microphone');

% % check that true first order image sources are contained in the final list
% % (used for trouble shooting)
% 
% % room dimensions
% Lx = roomDimensions(1); Ly = roomDimensions(2); Lz = roomDimensions(3);
% % sound source X/Y/Z coordinates
% Xs = sourceCoord(1); Ys = sourceCoord(2); Zs = sourceCoord(3);
% 
% firstOrderImSources = [ -Xs,      Ys,      Zs; ...
%                          Xs,     -Ys,      Zs; ...
%                          Xs,      Ys,     -Zs; ...
%                          2*Lx-Xs, Ys,      Zs; ...
%                          Xs,      2*Ly-Ys, Zs; ...
%                          Xs,      Ys,      2*Lz-Zs ];
% 
% for n = 1:6
% 
%     imSrcDists = vecnorm(img_srcs - firstOrderImSources(n,:), 2, 2);
% 
%     [minVal, minIdx] = min(imSrcDists,[],'all');
%     minScore = scores(minIdx);
% 
%     fprintf('minimum distance (original candidates): %.04f, minimum index: %d, minimum score: %.04f \n',minVal,minIdx,minScore);
% 
% end
% 
% fprintf('\n');
% 
% for n = 1:6
% 
%     imSrcDists = vecnorm(imgSrcsFinal - firstOrderImSources(n,:), 2, 2);
% 
%     [minVal, minIdx] = min(imSrcDists,[],'all');
%     minScore = scores(minIdx);
% 
%     fprintf('minimum distance (filered candidates): %.04f, minimum index: %d, minimum score: %.04f \n',minVal,minIdx,minScore);
% 
% end


%% display estimated room

xRange = [min(imgSrcsFinal(:,1)) - 1,max(imgSrcsFinal(:,1))+1];
yRange = [min(imgSrcsFinal(:,2)) - 1,max(imgSrcsFinal(:,2))+1];
zRange = [min(imgSrcsFinal(:,3)) - 1,max(imgSrcsFinal(:,3))+1];

% plot room estimate and derive voxelized representation of room (a binary mask) 
[xx,yy,zz, roomVoxel] = plotRoomEstimate(src_est,imgSrcsFinal,0.05,xRange,yRange,zRange);

% convert voxelized room representation into a point cloud of walls
roomVoxelsWall = bwperim(roomVoxel);

% get X/Y/Z coordinates for each point in wall point cloud
wallsX = xx(roomVoxelsWall);
wallsY = yy(roomVoxelsWall);
wallsZ = zz(roomVoxelsWall);

% display wall point cloud, color coded according to the z-coordinate of
% each point
figure; scatter3(wallsX,wallsY,wallsZ,36,wallsZ,'.');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title('Wall Point Cloud'); axis equal;

% fit a cuboid to the wall point cloud
wallPtCloud = pointCloud([wallsX,wallsY,wallsZ]);
roomCuboid = pcfitcuboid(wallPtCloud);

% plot the fitted cuboid
figure; plot(roomCuboid); axis equal;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title(sprintf('Final Room Estimate\nWidth=%.02f, Length=%.02f, Height=%.02f \nCentroid= [%.02f,%.02f,%.02f]',...
              roomCuboid.Dimensions(1),roomCuboid.Dimensions(2),roomCuboid.Dimensions(3),roomCuboid.Center));
hold on;
% add microphone positions and estimated speaker location to room plot
scatter3(src_est(1),src_est(2),src_est(3),100,'bx');
scatter3(receiverCoords(:,1),receiverCoords(:,2),receiverCoords(:,3),100,'r.');
legend('','Estimated Speaker Location','Microphones','Location','southoutside');