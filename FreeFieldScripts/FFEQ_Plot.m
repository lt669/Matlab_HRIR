%{
    Script to plot the results of the HRIR EQs

    Lewis Thresh 06/01/2017
%}
clc;
clear;

Nfft = 4096;
Fs = 48000;
bit = 16;
fsFolder = int2str(round(Fs/1000));
projectName = 'KemarTest';
subjectName = 'Kemar';
microphone = {'Yellow','Green'};
speaker = 1;
user_in = 1;
isNorm = 0;
plotView = 1;
row = 2;
col = 3;

% Raw HRIR
raw_path = strcat('Audio/',projectName,'/HRIR_Trim/',subjectName,'/',fsFolder);
raw_hrir = dir(strcat('Audio/',projectName,'/HRIR_Trim/',subjectName,'/',fsFolder,'/*.wav'));

% Loudspeaker IR
speaker_path_left = strcat('Audio/Loudspeaker_Audio/IR_untrimmed/',fsFolder,'k_',int2str(bit),'bit/',microphone{:,1});
speaker_hrir_left = dir(strcat(speaker_path_left,'/*.wav'));
speaker_path_right = strcat('Audio/Loudspeaker_Audio/IR_untrimmed/',fsFolder,'k_',int2str(bit),'bit/',microphone{:,2});
speaker_hrir_right = dir(strcat(speaker_path_right,'/*.wav'));

% Free Field HRIR
ff_path = strcat('Audio/',projectName,'/HRIR_FFEQ/',subjectName,'/',fsFolder);
ff_hrir = dir(strcat('Audio/',projectName,'/HRIR_FFEQ/',subjectName,'/',fsFolder,'/*.wav'));

% DFC HRIR
%{
dfc_path = sprintf('EAD_HRIR/Audio/HRIR_DFC/48K_24bit/%s/',subjectName);
dfc_hrir = dir(sprintf('EAD_HRIR/Audio/HRIR_DFC/48K_24bit/%s/*.wav',subjectName));

% DFFC HRIR
dffc_path = sprintf('EAD_HRIR/Audio/HRIR_DFFEQ/48K_24bit/%s/',subjectName);
dffc_hrir = dir(sprintf('EAD_HRIR/Audio/HRIR_DFFEQ/48K_24bit/%s/*.wav',subjectName));
%}

% FF Inverse Filters
ffInv_path = strcat('Audio/',projectName,'/HRIR_InvFilters/',subjectName,'/',fsFolder);
ffInv_hrir = dir(strcat('Audio/',projectName,'/HRIR_InvFilters/',subjectName,'/',fsFolder,'/*.wav'));

user_in = 3;
while user_in ~= 0
   
    %{
    if user_in == 'norm'
        isNorm = abs(isNorm - 1);
        disp(sprintf('Normalisation: %d',isNorm));
        user_in = inputTemp;
    end
    %}
    
    clf;
    raw_File = sprintf('%s/%s',raw_path,raw_hrir(user_in).name);
    
    speaker_File_Left = sprintf('%s/%s',speaker_path_left,speaker_hrir_left(user_in).name);
    speaker_File_Right = sprintf('%s/%s',speaker_path_right,speaker_hrir_right(user_in).name);
    
    ff_File = sprintf('%s/%s',ff_path,ff_hrir(user_in).name);
    ffInv_File = sprintf('%s/%s',ffInv_path,ffInv_hrir(user_in).name);
    
    raw = audioread(raw_File);
    speaker_left = audioread(speaker_File_Left);
    speaker_right = audioread(speaker_File_Right);
    ff = audioread(ff_File);
    ffInv = audioread(ffInv_File);
    
    
  
    % Applied Free Field EQ
    speakerResp(:,1) = conv(speaker_left,ffInv(:,1));
    speakerResp(:,2) = conv(speaker_right,ffInv(:,2));

    if plotView == 1
        row = 2;
        col = 1;
        range = [-30 30];
        
        % Free Field Speaker response, inverse and result
        subplot(row,col,1);
        hold on;
        GK_Freqplot(speaker_left,Fs, Nfft, 'k', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(speaker_right,Fs, Nfft, 'k:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(ffInv(:,1),Fs, Nfft, 'g', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(ffInv(:,2),Fs, Nfft, 'g:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(speakerResp(:,1),Fs, Nfft, 'r', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(speakerResp(:,2),Fs, Nfft, 'r:', 3, 16, 'Free Field Inverse Filter', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        legend('Speaker (L)', 'Speaker (R)','invFF (L)', 'invFF (R)','speakerEQ (L)','speakerEQ (R)','location', 'southeast');
 
        % Raw, Inv filter and FF eq
        subplot(row,col,2);
        hold on;
        GK_Freqplot(raw(:,1),Fs, Nfft, 'k', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(raw(:,2),Fs, Nfft, 'k:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(ff(:,1),Fs, Nfft, 'r', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(ff(:,2),Fs, Nfft, 'r:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(ffInv(:,1),Fs, Nfft, 'g', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(ffInv(:,2),Fs, Nfft, 'g:', 3, 16, 'Raw, FF Inverse and FF EQ', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        legend('Raw (L)', 'Raw (R)','FF (L)', 'FF (R)','ffInv (L)','ffInv (R)','location', 'southeast');

    elseif plotView ==2 
        row = 3;
        col = 1;
        range = [-20 15];

        % Diffuse Field Speaker response, inverse and result
        subplot(row,col,1);
        hold on;
        GK_Freqplot(diffuseFreeResponse(:,1),Fs, Nfft, 'k', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(diffuseFreeResponse(:,2),Fs, Nfft, 'k:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(dfFreeInv(:,1),Fs, Nfft, 'g', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(dfFreeInv(:,2),Fs, Nfft, 'g:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(diffFreeResp(:,1),Fs, Nfft, 'r', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(diffFreeResp(:,2),Fs, Nfft, 'r:', 3, 16, 'Diffuse Field Inverse Filter', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);        
        legend('diffuseFreeResponse (L)', 'diffuseFreeResponse (R)','invDiffFree (L)', 'invDiffFree (R)','DiffFreeEQ (L)','DiffFreeEQ (R)','location', 'southeast');

        % Diffuse Free Field Speaker response, inverse and result
        subplot(row,col,2);
        hold on;
        GK_Freqplot(diffuseResponse(:,1),Fs, Nfft, 'k', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(diffuseResponse(:,2),Fs, Nfft, 'k:', 3, 16, '', 'Frequency', 'Amplitude',range, [70 20000],  isNorm, 0);    
        GK_Freqplot(dfInv(:,1),Fs, Nfft, 'g', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(dfInv(:,2),Fs, Nfft, 'g:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(diffResp(:,1),Fs, Nfft, 'r', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(diffResp(:,2),Fs, Nfft, 'r:', 3, 16, 'Diffuse Field Inverse Filter', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        legend('diffuseResponse (L)', 'diffuseResponse (R)','invFF (L)', 'invFF (R)','speakerEQ (L)','speakerEQ (R)','location', 'southeast');

        % Free Field Speaker response, inverse and result
        subplot(row,col,3);
        hold on;
        GK_Freqplot(speaker(:,1),Fs, Nfft, 'k', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(speaker(:,2),Fs, Nfft, 'k:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(ffInv(:,1),Fs, Nfft, 'g', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(ffInv(:,2),Fs, Nfft, 'g:', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);
        GK_Freqplot(speakerResp(:,1),Fs, Nfft, 'r', 3, 16, '', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        GK_Freqplot(speakerResp(:,2),Fs, Nfft, 'r:', 3, 16, 'Free Field Inverse Filter', 'Frequency', 'Amplitude', range, [70 20000],  isNorm, 0);    
        legend('Speaker (L)', 'Speaker (R)','invFF (L)', 'invFF (R)','speakerEQ (L)','speakerEQ (R)','location', 'southeast');

    end
    user_in = input('Choose Speaker: ');
end