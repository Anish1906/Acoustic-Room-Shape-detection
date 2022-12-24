clear all; close all;

addpath('utils');

%% input audio

[audioIn,fs] = audioread('data\test_audio.m4a');

%% room parameters

useHRTF = false;

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
noise_var = 0.001;
% noise_var = 0;

%% plot room setup

plotRoom(roomDimensions,receiverCoords,sourceCoord);

%% calculate impulse responses

microphone_impulse_responses = cell(1,size(receiverCoords,1));

% calculate room impulse response for each microphone
for n = 1:size(receiverCoords,1)
    h = HelperImageSource(roomDimensions,receiverCoords(n,:),sourceCoord,A,FVect,fs,useHRTF);
    % not using hrtf, only need one column
    h = h(:,2);
    microphone_impulse_responses{n} = h;
end

% note that each impulse response is the same length
microphone_impulse_responses = cell2mat(microphone_impulse_responses);

%% plot impulse response for first microphone

figure; 
t= (1/fs)*(0:size(microphone_impulse_responses,1)-1);
plot(t,microphone_impulse_responses(:,1));
grid on
xlabel("Time (s)")
ylabel("Impulse Response")

%% test on audio

% pass audio through each microphone
for n = 1:size(receiverCoords,1)

    % get impulse response for current microphone
    h = microphone_impulse_responses(:,n);

    audioOutLeft = conv(audioIn(:,1),h,'full');
    audioOutRight = conv(audioIn(:,2),h,'full');  
    audioOut = [audioOutLeft, audioOutRight];
    
    % add white noise to audio
    audioOut = audioOut + normrnd(0, sqrt(noise_var), size(audioOut,1), size(audioOut,2));
    
    % rescale audio to avoid clipping
    audioOut = rescale(audioOut,-1,1);
    
    % write audio output
    audiowrite(fullfile('data',sprintf('audio_out_%d.m4a',n)),audioOut,fs);

end