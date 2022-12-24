clear all; close all;

addpath('utils');

%% experiment parameters

% sample rate
fs = 44100;
% number of signal averages to use for noise suppression
numAverages = 10;

%% room parameters

roomDimensions = [4 4 2.5];

receiverCoords = [ 2,   1,   1.8; ...
                   3,   2,   1.8; ...
                   3.5, 1.5, 1.8 ];
sourceCoord = [3, 1, 1.8];

% absorption coefficients. Each row corresponds to a frequency band in FVect, and each column
% corresponds to a wall
% reference: https://www.acoustic.ua/st/web_absorption_data_eng.pdf
FVect = [125 250 500 1000 2000 4000];
A = [0.10 0.20 0.40 0.60 0.50 0.60;...
     0.10 0.20 0.40 0.60 0.50 0.60;...
     0.10 0.20 0.40 0.60 0.50 0.60;...
     0.10 0.20 0.40 0.60 0.50 0.60;...
     0.02 0.03 0.03 0.03 0.04 0.07;...
     0.02 0.03 0.03 0.03 0.04 0.07].';

% additive noise variance
noiseVar = 0.1;
% noiseVar = 0;

%% plot room setup

plotRoom(roomDimensions,receiverCoords,sourceCoord);

%% calculate impulse responses

microphone_impulse_responses = getMicrophoneImpulseResponses(roomDimensions,receiverCoords,sourceCoord,A,FVect,fs);

imp_length = size(microphone_impulse_responses,1);

%% run impulse response recovery experiment

% generate excitation signal (also try MLS)
input = sweeptone(4,2,fs,'SweepFrequencyRange',[1,22050]);

% store output signals
output_length = length(input) + imp_length - 1;
outputs = zeros(output_length,size(receiverCoords,1));

% send input through each microphone response
for n = 1:size(receiverCoords,1)

    % get impulse response for current microphone
    h = microphone_impulse_responses(:,n);

    % pass input through room channel
    audioOut = conv(input,h,'full');

    % simulate multiple recordings by adding noise signals
    for m = 1:numAverages        
        % add white noise to audio
        trialOutput = audioOut + normrnd(0, sqrt(noiseVar), length(audioOut), 1);
        % store trial results
        outputs(:,n) = outputs(:,n) + trialOutput;
    end

    % get average of each trial
    outputs(:,n) = outputs(:,n)/numAverages;

end

% estimate impulse responses
impulse_response_estimates = impzest(input,outputs);

%% plot the estimated and true impulse responses

t = (1/fs)*(0:imp_length-1);

figure;
plot(t,microphone_impulse_responses(:,1),t,impulse_response_estimates(1:imp_length,1));
xlabel('Time (s)');
ylabel('Amplitude');
title('Estimated and Groundtruth Impulse Responses, Microphone 1');
legend('true impulse response','estimated impulse response');