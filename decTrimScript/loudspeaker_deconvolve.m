%{
Script to run deconvolution algorithm for loudspeaker IRs
Author: Lewis Thresh
Created: 12/12/2016
%}

clear;
clc;

microphone = 'Yellow';

% For stereo IR files
irPath = strcat('Audio/Loudspeaker_Audio/Sweeps/',microphone);
irDir = dir(strcat('Audio/Loudspeaker_Audio/Sweeps/',microphone,'/*.wav'));

%Load inverse sweep
inv = audioread('Audio/Sweeps/InvSweep_20to22050_48000_startPad0s_endPad0s.wav');

for k = 1:50
    
    irFile = sprintf('%s/%s',irPath,irDir(k).name);
    [sweep,fs] = audioread(irFile);
    
    sweep = sweep(:,1); %Sweeps recorded in stereo in left channel only
    
    dec = deconvolve(inv,sweep);
    
    % Trim to exactly 3 seconds
    dec = dec(1:(3*fs));
    
    mkdir(strcat('Audio/Loudspeaker_Audio/IR_untrimmed/',microphone));
    
    name = sprintf('Audio/Loudspeaker_Audio/IR_untrimmed/%s/ir_%s',microphone,irDir(k).name);
    audiowrite(name,dec,fs);
end
