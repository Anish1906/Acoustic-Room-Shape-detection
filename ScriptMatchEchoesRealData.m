%% Get candidate image sources from measured impulse responses

clear all; close all;

addpath('utils');

%% input parameters

% sample rate of recorded data
fs = 44100;

% number of peaks to use for echo matching
numPeaks = 20;

% % directory of recorded impulse responses
% dataDir = 'data\dataCollect_12_4_2022';
% 
% % parameters for data collect with microphones at the same height
% 
% % files of recorded impulse responses at each microphone
% inFiles = {'impulseResponseP1.mat', 'impulseResponseP2.mat',...
%            'impulseResponseP3.mat', 'impulseResponseP4.mat',...
%            'impulseResponseP5.mat'};
% 
% % microphone array coordinates (using microphone 1 as the coordinate origin)
% % units: inches
% receiverCoords = [ 0, 0, 0; ...
%                    8, 0, 0; ...
%                    8, 8, 0; ...
%                    0, 8, 0; ...
%                   -4, 4, 0 ];
% 
% % measured distances from speaker to each microphone (units: inches)
% src2ReceiverDists = [ 25+(1/8), 25.5, 17.5, 17+(1/8), 22+(5/8) ];

% parameters for data collect with microphones at varying heights

% % files of recorded impulse responses at each microphone
% inFiles = {'impulseResponseP1_elevated.mat', 'impulseResponseP2_elevated.mat',...
%            'impulseResponseP3_elevated.mat', 'impulseResponseP4_elevated.mat',...
%            'impulseResponseP5_elevated.mat'};
% 
% % microphone array coordinates (using microphone 1 as the coordinate origin)
% % units: inches
% receiverCoords = [ 0, 0, 0; ...
%                    8, 0, 8+(7/8); ...
%                    8, 8, 0; ...
%                    0, 8, 0; ...
%                   -4, 4, 8+(3/4) ];
% 
% % measured distances from speaker to each microphone (units: inches)
% src2ReceiverDists = [ 27+(1/4), 25+(5/8), 20+(7/8), 20, 22 ];

% parameters for oven data collect

% directory of recorded impulse responses
dataDir = 'data\dataCollect_12_11_2022';

% parameters for data collect with microphones at the same height

% files of recorded impulse responses at each microphone
inFiles = {'impulseResponseP1_oven.mat', 'impulseResponseP2_oven.mat',...
           'impulseResponseP3_oven.mat', 'impulseResponseP4_oven.mat',...
           'impulseResponseP5_oven.mat'};

% microphone array coordinates (using microphone 1 as the coordinate origin)
% units: inches
receiverCoords = [ 0,    0,     0; ...
                   6.25, 0,     0; ...
                   6.25, 5.125, 0; ...
                   0,    5.125, 0; ...
                  -6.25, 0,     0 ];

% measured distances from speaker to each microphone (units: inches)
src2ReceiverDists = [ 8.5, 12.5, 10.5, 4.75, 7.75 ];

%% convert measurements from inches to meters

receiverCoords = receiverCoords.*0.0254;
src2ReceiverDists = src2ReceiverDists.*0.0254;

%% load impulse responses

numMics = size(receiverCoords,1);

% read and store all recorded impulse responses

impResponses = cell(1,numMics);

for n = 1:numMics
    load(fullfile(dataDir,inFiles{n}));
    impResponses{n} = impResponse;
end

impResponses = cell2mat(impResponses);

%% get candidate image sources and their scores

[src_est, img_srcs, scores] = scoreEchoMatchesAcrossMicrophonesDataCollect(receiverCoords, impResponses, numPeaks, fs, src2ReceiverDists);

%% save out data

date_curr = datevec(datetime('now'));
save(fullfile('data/imgSrcs_dataCollect',sprintf('%d_%d_%d_source_estimates_%s',date_curr(2),date_curr(3),date_curr(1),inFiles{1})),'src_est','img_srcs','scores','receiverCoords');