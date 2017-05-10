%{
    Deconvoles and trims the HRIRs of each of the test subjects
%}

function [decStereoOut] = runSubjectDeconvolve(projectName,subjectName,fileLength,fs,bits)

    disp('--- Running Subject Deconvolve Script ---');

    % Variables
    if fs==48
        samples = 144000;
        trimStart = 2414;
    elseif fs==44
        samples = 132300;
        trimStart = 2218;
    end
    
    % Paths to audio files
    subjectSweepsPath = sprintf('Audio/%s/SubjectSweeps_Raw/%s/%i',projectName,subjectName,fs); % Used to load files
    subjectDir = dir(sprintf('%s/*.wav',subjectSweepsPath)); % Used to find names of files

    % Check file exists
    if 0==exist(subjectSweepsPath,'file')
        error(sprintf('The Folder... \n\n %s \n\n ...does not exists. Have you selected the correct sampling rate?',subjectSweepsPath));
    end

    
    %Load inverse sweep
    if fs==48
        inv = audioread('Audio/Sweeps/InvSweep_20to22050_48000_startPad0s_endPad0s.wav');
    else
        inv = audioread('Audio/Sweeps/InvSweep_20to22050_44100_startPad0s_endPad0s.wav');
    end

    decStereoOut=zeros(50,fileLength,2);

    % Create output directory
    mkdir(sprintf('Audio/%s/HRIR_Raw/%s',projectName,subjectName));
    mkdir(sprintf('Audio/%s/HRIR_Trim/%s',projectName,subjectName));

    % Display Info
    disp(sprintf('Saving Raw HRIRs to:Audio/%s/HRIR_Raw/%s',projectName,subjectName));
    disp(sprintf('Saving Trimmed HRIRs to:Audio/%s/HRIR_Trim/%s',projectName,subjectName));
    disp(sprintf('length(subjectDir) = %d',length(subjectDir)));


    for k = 1:length(subjectDir)

        file = sprintf('%s/%s',subjectSweepsPath,subjectDir(k).name);
        [pathstr,inputName,ext] = fileparts(file);
        fileName(k) = cellstr(char(inputName));
        %disp(strcat('path: ',pathstr, 'Name: ',fileName, 'ext: ',ext));

        sweep = audioread(file);

        % Check that the file is the correct length (48k = 144,000 Samples 44.1k = 132,300 Samples)
        %(48k = 144384 samples ,44.1k = 132653 samples)


        len = length(sweep);
        [r,c] = size(sweep);
        disp(sprintf('r: %i c: %i',r,c));

        if(len>samples)
            disp('Trimming');
            sweep = sweep(1:samples,:);
            disp(length(sweep))
        elseif(len<samples)
            disp('Padding');
            sweep = padarray(sweep,(samples-len),'post');
        end

        disp(sprintf('len: %i',len));
        disp(sprintf('sweep(:,1): %i',length(sweep(:,1))));
        disp(sprintf('sweep(:,2): %i',length(sweep(:,2))));

        % Deconvolve
        dec(k,:,:) = deconvolve(inv,sweep);
    end

    % Normalise all HRIRs with respoect to each other
    decNorm = normHRIR(dec);

    for n = 1:length(subjectDir)

        % Write Raw HRIR
        outputRaw(:,:) = decNorm(n,:,:);
        name = strcat('Audio/',projectName,'/HRIR_Raw/',subjectName,'/',fs,'/',char(fileName(n)),'_RawLong.wav');
        audiowrite(name,outputRaw,fs,'BitsPerSample', bits);

        %{
            To cut 0.05s off start of the IR
        
            48k = 2414 (This was the original value used in EAD)
            44.1k = 2218 (This is approximate equivalent to the previously
            used value)
        
            This value should be better determined.
        %}
        
        % Write Trimmed HRIR
        decStereoOut(n,:,1) = decNorm(n,trimStart:(trimStart+fileLength-1),1); % What number should this be for 44.1k??
        decStereoOut(n,:,2) = decNorm(n,trimStart:(trimStart+fileLength-1),2);
        name = strcat('Audio/HRIR_Trim/',subjectName,'/',fs,'/',char(fileName(n)),'_Raw.wav');

        output(:,:) = decStereoOut(n,:,:);
        audiowrite(name,output,fs,'BitsPerSample', bits);
    end


end
