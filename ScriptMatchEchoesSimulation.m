% try modifying S_Stress to only modify the source image distance estimate
% see what happens if you give a decent initial guess for the true source

clear all; close all;

addpath('utils');

%% experiment parameters

% sample rate (it seems that extracting peaks only to the nearest sample is problematic)
fs = 44100;
% fs = 96000;
% number of signal averages to use for noise suppression
numAverages = 10;
% maximum number of peaks to extract from each estimated RIR
% numPeaks = 15;
% numPeaks = 17;
numPeaks = 21;

%% room parameters

% roomDimensions = [4 4 2.5];
roomDimensions = [8 8 3];

% microphone array
receiverCoords = [ 3.9, 3.9, 1.0; ...
                   3.9, 4.1, 1.2; ...
                   4.1, 3.9, 1.0; ...
                   4.1, 4.1, 1.2; ...
                   4.2, 4.1, 1.4];

% translation applied to microphone array
microphoneTranslation = [-0.1,-0.1,0];

% speaker location
sourceCoord = [4, 4, 1.2];


% absorption coefficients. Each row corresponds to a frequency band in FVect, and each column
% corresponds to a wall
% reference: https://www.acoustic.ua/st/web_absorption_data_eng.pdf
FVect = [125 250 500 1000 2000 4000];

A = [0.01 0.01 0.01 0.02 0.02 0.02;...
     0.01 0.01 0.01 0.02 0.02 0.02;...
     0.01 0.01 0.01 0.02 0.02 0.02;...
     0.01 0.01 0.01 0.02 0.02 0.02;...
     0.01 0.01 0.01 0.02 0.02 0.02;...
     0.01 0.01 0.01 0.02 0.02 0.02].';

% additive noise variance
noiseVar = 0.01;

%% plot room setup

% translate the microphone array
receiverCoords = receiverCoords+microphoneTranslation;

plotRoom(roomDimensions,receiverCoords,sourceCoord);

%% calculate impulse responses

microphone_impulse_responses = getMicrophoneImpulseResponses(roomDimensions,receiverCoords,sourceCoord,A,FVect,fs);

% note that each impulse response is the same length
imp_length = size(microphone_impulse_responses,1);

%% run impulse response recovery experiment

num_microphones = size(receiverCoords,1);

% generate excitation signal (also try MLS)
input = sweeptone(10,4,fs,'SweepFrequencyRange',[5,22050]);

% store output signals
output_length = length(input) + imp_length - 1;
outputs = zeros(output_length,size(receiverCoords,1));

% send input through each microphone response
for n = 1:num_microphones

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
impulseResponseEstimates = impzest(input,outputs);

%% plot the estimated and true impulse responses

t = (1/fs)*(0:imp_length-1);

for n = 1:num_microphones
    impulse_response_est_curr = impulseResponseEstimates(:,n);
    t_est = (1/fs)*(0:length(impulse_response_est_curr)-1);
    
    figure; 
    plot(t_est,microphone_impulse_responses(1:length(impulse_response_est_curr),n));
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('True Impulse Response, Microphone %d',n));    

    figure;
    plot(t_est,impulse_response_est_curr);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Estimated Impulse Response, Microphone %d',n));    

    figure;
    differenceRIR = microphone_impulse_responses(1:length(impulse_response_est_curr),n)-impulse_response_est_curr;
    % plot difference between impulse responses
    plot(t_est,differenceRIR);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Impulse Response Estimation Error, Microphone %d',n));
end

%% score potential echo matches across different microphones and estimate image source locations

[src_est,img_srcs,scores] = scoreEchoMatchesAcrossMicrophones(receiverCoords,impulseResponseEstimates,numPeaks,fs);

date_curr = datevec(datetime('now'));
save(fullfile('data/imgSrcs_simulated',sprintf('%d_%d_%d_source_estimates_num_peaks_%d_num_microphones_%d_tx_%.02f_ty_%.02f_tz_%.02f.mat',date_curr(2),date_curr(3),date_curr(1),numPeaks,num_microphones,microphoneTranslation(1),microphoneTranslation(2),microphoneTranslation(3))),'src_est','img_srcs','scores','receiverCoords','sourceCoord','roomDimensions');
