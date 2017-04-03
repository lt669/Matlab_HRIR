function [] = monoToStereoSweeps(subjectNumber)

    monoLeftFile = strcat('EAD_HRIR/Audio/SubjectSweeps_Raw/',subjectNumber,'/Left/');
    monoLeftdir = dir(strcat('EAD_HRIR/Audio/SubjectSweeps_Raw/',subjectNumber,'/Left/*.wav'));

    monoRightFile = strcat('EAD_HRIR/Audio/SubjectSweeps_Raw/',subjectNumber,'/Right/');
    monoRightdir = dir(strcat('EAD_HRIR/Audio/SubjectSweeps_Raw/',subjectNumber,'/Right/*.wav'));

    for k=1:50
        disp(k);
        monoLeft = audioread(sprintf('%s%s',monoLeftFile,monoLeftdir(k).name));
        monoRight = audioread(sprintf('%s%s',monoRightFile,monoRightdir(k).name));

        % Check that the file is the correct length (144384 samples)
        len = length(monoLeft);
        if(len>144384)
            disp('Trimming');
            monoLeft = monoLeft(1:144384,:);
            disp(length(monoLeft))
        elseif(len<144384)
            monoLeft = padarray(monoLeft,(144384-len));
        end
        
        len = length(monoRight);
        if(len>144384)
            disp('Trimming');
            monoRight = monoRight(1:144384,:);
            disp(length(monoRight))
        elseif(len<144384)
            monoRight = padarray(monoRight,(144384-len));
        end
        
        Stereo(:,1) = monoLeft(:,1);
        Stereo(:,2) = monoRight(:,1);
        

        

        name = strcat('EAD_HRIR/Audio/SubjectSweeps_Raw/',subjectNumber,'/',monoLeftdir(k).name);
        audiowrite(name,Stereo,48000,'BitsPerSample', 24);
    end

end

   
