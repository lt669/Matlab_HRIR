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
fs = 48000;
bitDepth = 16;

projectName = 'LewisTestFolder';
subjectName = 'TestSubject';

% Which microphones were used {'Left','Right'}
microphones = {'Yellow','Green'};

% OPTIONS -- 1 = Yes -- 0 = No

sofaFile = 1;

% FIR Filter Options
FIR_compression = 9;


    ApplicationName = 'EAD Measurements';
    Organization = 'University of York';
    AuthorContact = 'lewis.thresh@york.ac.uk';
    Comment = '50 source positions. Human subject. Microphones used were sennheiser in-ear microphones via an MOTU 24IO interface (x3). Free Field and Diffuse field compensated minimum phase HRIRs.';

    


% IIR Filter Options
FilterType = 'IIR';
order = 24;
compression_IIR = 0;


% HRIR_SCRIPT(projectName, subjectName, FS, bitDepth,)

fileLength = 256; % This can/should be changed accordingly
%%

%Convert seperatley recorded HRTFs into a stereo file
monoToStereoSweeps(subjectName);
%%
% Deconvolve HRIR sweeps
rawHRIR = runSubjectDeconvolve(projectName,subjectName,fileLength,fs,bitDepth);
%%
% Apply Free Field Equalisation

FFHRIR = produceFreeField(projectName,subjectName,fileLength,fs,bitDepth,microphones);

% Apply Diffuse Field Equalisation
% produceDiffuseField(subjectName,fileLength);
%% Produce IIR Lookup Table
ITD_Lookup_Table_Generation(projectName,subjectName,fs);

%%
createSOFA(projectName,subjectName,fileLength,fs,bitDepth,FIR_compression,ApplicationName,Organization,AuthorContact,Comment);
%%
clc;
FIRtoIIR(projectName,subjectName,fileLength,fs,bitDepth,order,compression_IIR);
