%{
    EAD automatic HRIR capture, equalisation and sofa file production
    script

    NOTE: Can not use DIR() to load audio files, must use direct file path!

    This is the new down_sample_branch

%}
clc;
clear;

subjectName = 'subject_66';
fileLength = 256; % This can/should be changed accordingly
%%

%Convert seperatley recorded HRTFs into a stereo file
monoToStereoSweeps(subjectName);

% Deconvolve HRIR sweeps
rawHRIR = runSubjectDeconvolve(subjectName,fileLength);

% Apply Free Field Equalisation

FFHRIR = produceFreeField(subjectName,fileLength);

% Apply Diffuse Field Equalisation

% produceDiffuseField(subjectName,fileLength);
%%
createSOFA(subjectName,fileLength);
