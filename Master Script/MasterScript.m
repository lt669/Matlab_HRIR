%{
    EAD automatic HRIR capture, equalisation and sofa file production
    script

    NOTE: Can not use DIR() to load audio files, must use direct file path!


    NOTE: Top file should no longer be Documents/MATLAB. To avoid conflict
    with other scripts, have all required scripts in your personal top
    folder.

    All audio is recorded at 48000. Change fs to output all files at the
    desired sample rate. They will be converted at the deconvole stage
    (after deconvolution).
    

%}
clc;
clear;

% Change for output format
fs = 44100;
bitDepth = 16;

projectName = 'EAD_HRIR';
subjectName = 'subject_66';

% OPTIONS -- 1 = Yes -- 0 = No



sofaFile = 1;

% IIR Filter Options
FilterType = 'IIR';
Order = 24;


% HRIR_SCRIPT(projectName, subjectName, FS, bitDepth,)

fileLength = 256; % This can/should be changed accordingly
%%

%Convert seperatley recorded HRTFs into a stereo file
monoToStereoSweeps(subjectName);

% Deconvolve HRIR sweeps
rawHRIR = runSubjectDeconvolve(projectName,subjectName,fileLength,fs,bitDepth);

% Apply Free Field Equalisation

FFHRIR = produceFreeField(subjectName,fileLength);

% Apply Diffuse Field Equalisation

% produceDiffuseField(subjectName,fileLength);
%%
createSOFA(subjectName,fileLength);
