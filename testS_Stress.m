clear all; close all;

addpath('utils');

%% experiment params

% noise variance
noise_var = 1e-4;

% define a microphone position and source image position

microphone_pos = [ 1   1   1; ...
                   2   2   1; ...
                   3   3   1; ...
                   4   4   1 ];

source_im_pos = [5,5,1];

%% form the euclidean distance matrix and add noise

num_microphones = size(microphone_pos,1);

% get true EDM corresponding to microphone array and image source
D_true = squareform(pdist([microphone_pos; source_im_pos]));

% use to store EDM estimated from noisy estimates
D_hat = D_true;

% add position measurement noise to microphone positions
microphone_pos_measured = microphone_pos + normrnd(0,sqrt(noise_var),size(microphone_pos));
D_hat(1:num_microphones,1:num_microphones) = squareform(pdist(microphone_pos_measured));

% add ToF measurement noise for entries in D_hat relating to source position
ToF_noise = normrnd(0,sqrt(noise_var),[1,num_microphones ] );
D_hat(end,1:num_microphones) = D_hat(end,1:num_microphones) + ToF_noise;
D_hat(1:num_microphones,end) = D_hat(1:num_microphones,end) + ToF_noise';

%% run S-Stress test to get score

x_init = [ microphone_pos_measured; 0, 0, 0 ];
% x_init = [ microphone_pos_measured; 5.1, 5.2, 0.5 ];

[score,x_final] = S_Stress(D_hat,x_init);

fprintf('Estimated Image Source Position: [%.04f, %.04f, %.04f]\nScore for valid EDM: %.06f\n', x_final(end,:), score);

%% test S-Stress on euclidean distance matrix that is not valid

% add a random augmentation to euclidean distance matrix, that does not
% correspond to any image source
invalid_augmentation = unifrnd(0,4,[1, size(microphone_pos,1)]);

% change the augmentation row/column of D_hat
D_hat(end,1:size(D_hat,2)-1) = invalid_augmentation;
D_hat(1:size(D_hat,1)-1,end) = invalid_augmentation';

% determine the S-Stress score, and compare this to the score on the valid EDM
[score_bad, x_final_bad] = S_Stress(D_hat,x_init);

fprintf('Score for invalid EDM: %.04f\n', score_bad);